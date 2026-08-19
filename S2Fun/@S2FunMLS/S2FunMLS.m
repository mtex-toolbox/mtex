classdef S2FunMLS < S2Fun
  % A class representing a function on the 2-sphere S^2.
  %
  % The function is not stored by coefficients, but by nodes and values. It is
  % evaluated by a moving least squares approximation: at every evaluation
  % point a small weighted least squares problem over a local polynomial
  % ansatz space is solved, using only the nodes in a compactly supported
  % neighborhood of that point.
  %
  % Syntax
  %   S2F = S2FunMLS(nodes, values);
  %   S2F = S2FunMLS(nodes, values, 'degree', 3, 'oF', 4);
  %   S2F = S2FunMLS(nodes, values, 'delta', 5*degree, 'weight', @(t)(...));
  %   S2F = S2FunMLS(nodes, values, 'centered', true, 'monomials', true, ...
  %     'subsample', 'tangent', true);
  %   S2F = S2FunMLS(nodes, values, 'detectOutliers', ...
  %     'use_vor_weights', 'use_smooth_delta');
  %
  % Input
  %  nodes  - @vector3d (data points)
  %  values - array of function values assigned to the nodes
  %
  % Output
  %  S2F - @S2FunMLS
  %
  % Options
  %  degree  - polynomial degree used for approximation
  %  oF      - oversampling factor; nn is S2F.dim times this factor
  %  oF_max  - maximal oversampling factor for range search
  %  delta   - support radius of the weight function; delta = 0 uses KNN
  %
  %  monomials - use a monomial basis, otherwise spherical harmonics
  %  centered  - evaluate the basis in local coordinates around the north pole
  %  tangent   - use monomials on the tangent plane (requires centered = true)
  %    (NOTE: centered and tangent automatically enable the monomial basis)
  %
  %  weight  - @function_handle (weight function)
  %          - predefined choices are 'auto' (default, a degree-dependent
  %            Wendland C6 variant), 'C1hat', 'const', 'cos', 'hat',
  %            'indicator', 'squared hat', 'wendland', 'wendlandC6',
  %            'wendlandSquared', and 'wendlandC6Squared'
  %  use_smooth_delta - use a smooth local support radius with about S2F.nn
  %                     neighbors at each center
  %  candidateFactor  - KNN candidates fetched per center as a multiple of nn
  %                     (default 2, only used with use_smooth_delta)
  %  use_vor_weights  - multiply the local weights by Voronoi areas
  %
  %  distance - metric for neighbor search (default: 'euclidean')
  %           - run 'help rangesearch' for the available options
  %  s        - symmetry of the nodes
  %
  %  regularize - use goal-oriented regularization of the local systems
  %  mincond    - center-amplification threshold where regularization starts
  %  maxcond    - center-amplification threshold where full correction is used
  %  targetcond - inverse-amplification bound at full correction;
  %               one is the minimum-norm constant-preserving limit
  %    (The property names are retained for compatibility. They no longer refer
  %     to the ordinary condition number of the Gram matrix.)
  %
  %  outlierDetectionRange - number of neighbors used for outlier detection
  %
  % Flags
  %  detectOutliers - detect local outliers and reduce their MLS weights
  %  subsample      - select a subset that minimizes the Lebesgue constant
  %
  % See also
  % SO3FunMLS S2FunHarmonic S2FunTri S2FunMLS/eval S2FunMLS/approximate


  properties
    nodes       = [];     % points where the function values are known
    values      = [];     % corresponding function values

    vor_weights = [];     % Voronoi weights as in stable MLS
    use_vor_weights = true;

    degree      = [];     % polynomial degree
    oF          = [];     % oversampling factor (nn / dim)
    oF_max      = [];     % upper bound for oF in range search
    delta       = [];     % support radius; zero activates KNN search

    use_smooth_delta = true; % use a smooth local support radius
    candidateFactor = 2;  % KNN candidates per center as a multiple of nn

    w           = [];     % compactly supported weight function
    distance    = 'euclidean'; % metric for neighbor search

    % the symmetry used by the approximation machinery (grids, bandwidth
    % choice) - not frame data; the frame this function is expressed in
    % is s.frame, see getFrame below
    s = specimenSymmetry.default;

    monomials   = true;   % use monomial basis?
    centered    = true;   % use local coordinates centered at evaluation point?
    tangent     = false;  % ignore the local z-coordinate for monomials?

    regularize = true;    % use goal-oriented regularization?
    mincond = [];         % start threshold for normalized center amplification
    maxcond = [];         % full threshold for normalized center amplification
    targetcond = [];      % full-strength target; one is the limiting minimum

    detectOutliers = false; % reduce the weight of detected outliers?
    outlierDetectionRange = 10; % neighbors used for outlier detection
    outlierIndicators = []; % bigger numbers (one per node) indicate outliers

    subsample   = false;  % perform optimal subsampling?

    auxgrid = [];         % equispaced grid used only for smooth delta
    reg_auxgrid = [];     % small random grid used only for reg calibration
  end

  properties (Dependent)
    dim                   % dimension of the ansatz space
    nn                    % number of neighbors
    antipodal             % inherited from the nodes
    isReal                % = isReal(S2F.values)

    % properties of the underlying nodes
    fill_distance         % fill distance
    separation_distance   % separation distance
  end

  methods

    function fr = getFrame(S2F)
      % the frame of an MLS function is the frame of its symmetry; an
      % own frame, set internally, wins
      if ~isempty(S2F.framePrivate)
        fr = S2F.framePrivate;
      elseif isempty(S2F.s)
        fr = [];
      else
        fr = S2F.s.frame;
      end
    end

    function s = getSym(S2F)
      s = S2F.s;
    end

    % initialize a spherical function
    function S2F = S2FunMLS(nodes, values, varargin)

      if nargin == 0, return; end

      % convert arbitrary S2Fun to S2FunMLS
      if isa(nodes,'function_handle') || isa(nodes,'S2Fun')
        if nargin == 1, values = []; end
        S2F = S2FunMLS.approximate(nodes, values, varargin{:});
        return
      end

      % MLS needs unique nodes (nothing to do for a fibonacciS2Grid)
      if (~isa(nodes, 'fibonacciS2Grid')) && ...
          (numel(unique(nodes, 'stable', 'tolerance', .001 * degree)) < numel(nodes))
        nodes = nodes(:);
        values = reshape(values, numel(nodes), []);
        [nodes, values] = uniqueData(nodes, values, 'mean', ...
          'tolerance', .001 * degree);
        if ~getMTEXpref('generatingHelpMode')
          warning(['Some duplicate Nodes have been removed. ' ...
            'The remaining nodes have been reshaped into a vector.']);
        end
      end

      % nodes is stored as a column; the remaining dimensions belong to values
      if isrow(nodes)
        nodes = reshape(nodes, numel(nodes), 1);
      end
      S2F.nodes = nodes;

      % @vector3d.find picks the searcher up from the nodes themselves
      if ~isfield(nodes.opt, 'searcher')
        S2F.nodes.opt.searcher = createns(nodes.xyz);
      end

      % set Voronoi weights
      S2F.use_vor_weights = get_option(varargin, 'use_vor_weights', true);
      if S2F.use_vor_weights
        S2F.vor_weights = nodes.calcVoronoiArea;
      else
        S2F.vor_weights = ones(size(nodes));
      end

      % reshape values according to nodes
      values_size = size(values);
      id = find(cumprod(values_size) == numel(nodes), 1, 'first');
      if (id < numel(values_size))
        remaining_sizes = values_size(id+1 : end);
        values = reshape(values, [numel(nodes), remaining_sizes]);
      else
        values = reshape(values, [numel(nodes), 1]);
      end
      S2F.values = values;

      % regularization flag and center-amplification parameters
      S2F.regularize = get_option(varargin, ...
        {'regularize','regularization'}, true, 'logical');
      S2F.mincond = get_option(varargin, ...
        {'mincond', 'min cond', 'min_cond', 'min amplification'}, []);
      S2F.maxcond = get_option(varargin, ...
        {'maxcond', 'max cond', 'max_cond', 'max amplification'}, []);

      targetcond = get_option(varargin, ...
        {'targetcond', 'target cond', 'target_cond', ...
         'target amplification', 'targetamp'}, []);
      if ~isempty(targetcond)
        S2F.targetcond = targetcond;
      elseif isempty(S2F.mincond)
        S2F.targetcond = [];
      end

      % degree, oversampling factor, and support radius
      S2F.degree = get_option(varargin, {'degree', 'deg'}, 4, 'double');
      S2F.oF = get_option(varargin, {'oF','of', 'OF','oversamplingfactor', ...
        'oversampling_factor','oversampling factor'}, 4, 'double');
      % half of the sphere should already contain sufficiently many nodes
      if (S2F.nn > numel(S2F.nodes) / 2)
        error('Too few data points for the specified degree and oversampling factor.');
      end
      S2F.oF_max = get_option(varargin, {'ofmax','of max', 'max of', 'maxof', ...
        'maximal oversampling factor', 'max oversampling factor'}, ...
        2 * S2F.oF, 'double');
      S2F.delta = get_option(varargin, ...
        {'delta', 'range', 'support radius'}, 0, 'double');

      % weight function, distance, and symmetry
      S2F.w = get_option(varargin, 'weight', 'auto', ...
        {'string','function_handle','char'});
      S2F.distance = get_option(varargin, 'distance', 'euclidean', 'char');
      S2F.s = get_option(varargin, {'symmetry', 'cs', 's', 'ss'}, ...
        specimenSymmetry.default, 'crystalSymmetry');

      % basis options
      S2F.monomials = get_option(varargin, 'monomials', true, 'logical');
      S2F.tangent = get_option(varargin, 'tangent', false, 'logical');
      S2F.centered = get_option(varargin, 'centered', true, 'logical');
      if S2F.tangent, S2F.centered = true; end
      if S2F.centered, S2F.monomials = true; end

      % outlier detection
      S2F.detectOutliers = check_option(varargin, ...
        {'detect outliers', 'detectoutliers', 'detect_outliers'});
      S2F.outlierDetectionRange = round(get_option(varargin, ...
        {'outlierdetectionrange', 'outlier detection range', 'odr'}, ...
        S2F.outlierDetectionRange, 'double'));
      if S2F.detectOutliers
        S2F.outlierIndicators = S2F.compute_outlier_indicators;
      end

      % optimal subsampling (minimizes the Lebesgue constant)
      S2F.subsample = check_option(varargin, {'subsampling', 'subsample'});
      if S2F.subsample, S2F.centered = true; end

      if S2F.regularize && S2F.centered && ...
          mod(S2F.degree, 2) == 1 && ~S2F.tangent && ...
          ~getMTEXpref('generatingHelpMode')
        warning(['For odd non-tangent ansatz spaces the first basis function is ' ...
          'only a local constant surrogate. Exact constant preservation is not ' ...
          'available. Tangent monomials are usually preferable.']);
      end

      S2F.use_smooth_delta = get_option(varargin, {'use_smooth_delta', ...
        'use smooth delta', 'smooth_delta', 'smooth delta'}, true);

      % A smooth support radius is not tied to the neighbor ranking, so more
      % than nn candidates have to be fetched per center.
      S2F.candidateFactor = get_option(varargin, {'candidateFactor', ...
        'candidatefactor', 'candidate factor', 'candidate_factor'}, ...
        2, 'double');

      % The two auxiliary grids have different jobs. Smooth delta uses a dense
      % equispaced grid; regularization calibration uses a much smaller random grid.
      needs_auto_regularization = S2F.regularize && ...
        (isempty(S2F.mincond) || isempty(S2F.maxcond) || ...
         isempty(S2F.targetcond));

      if S2F.use_smooth_delta && (S2F.delta == 0)
        S2F = S2F.init_auxgrid;
      end
      if needs_auto_regularization
        S2F = S2F.init_reg_auxgrid;
        S2F = S2F.init_reg_params;
      end

      S2F.frame = nodes.frame;
    end

    function S2F = set.w(S2F, weightfun)
      if isa(weightfun, 'function_handle')
        S2F.w = weightfun;
        return;
      end

      % Wendland C6 in Horner form. The weight is evaluated once per center and
      % neighbor, so avoiding the repeated powers of t is worth the detour.
      wendlandC6 = @(t)(max(1-t, 0).^8 .* (((32*t + 25).*t + 8).*t + 1));

      switch lower(char(weightfun))
        case 'hat'
          S2F.w = @(t)(max(1-t, 0));
        case 'squared hat'
          S2F.w = @(t)(max(1-t, 0).^2);
        case {'indicator','const'}
          S2F.w = @(t)(t <= 1);
        case 'cos'
          S2F.w = @(t)(((1+cos(pi*t))/2) .* (t <= 1));
        case 'auto'
          % Degree-dependent localization:
          % higher degrees use a narrower effective neighborhood.
          % Wendland C6 evaluated at t^alpha and subsequently raised to beta.
          alpha = max(1, 2 - (S2F.degree - 1) / 3);
          beta = 1 + max(S2F.degree - 2, 0) / 3;

          if alpha == 1
            S2F.w = @(t)(wendlandC6(t).^beta);
          elseif beta == 1
            S2F.w = @(t)(wendlandC6(t.^alpha));
          else
            S2F.w = @(t)(wendlandC6(t.^alpha).^beta);
          end

        case 'c1hat'
          % Fixed broad weight for explicit comparisons.
          S2F.w = @(t)(max(1-t.^2, 0).^2);
        case 'wendland'
          S2F.w = @(t)(max(1-t, 0).^4 .* (4*t+1));
        case 'wendlandc6'
          S2F.w = wendlandC6;
        case 'wendlandsquared'
          S2F.w = @(t)((max(1-t, 0).^4 .* (4*t+1)).^2);
        case 'wendlandc6squared'
          S2F.w = @(t)(wendlandC6(t).^2);
        otherwise
          error('Unknown MLS weight function.');
      end
    end

    % choose delta such that factor-oF oversampling is expected for iid nodes
    function d = compute_delta(S2F)
      % the relative area of a spherical cap with angular radius phi is
      %   (1 - cos(phi)) / 2
      % antipodal nodes represent two points each, so for N nodes the expected
      % number of nodes in such a cap is (1 + antipodal) * N * (1-cos(phi))/2
      antipodal_factor = 1 + S2F.antipodal;
      d = acos(1 - 2 * S2F.dim * S2F.oF / ...
        numel(S2F.nodes) / antipodal_factor);
    end

    function dimension = get.dim(S2F)
      dimension = (S2F.degree + 1) * (S2F.degree + 2) / 2;
    end

    function antipodal = get.antipodal(S2F)
      antipodal = S2F.nodes.antipodal;
    end

    function S2F = set.antipodal(S2F, value)
      S2F.nodes.antipodal = value;
    end

    function S2F = set.detectOutliers(S2F, value)
      S2F.detectOutliers = value;
      if value
        % set standard value of the outlier detection range
        % should be at least 3, since this is the dimension of the basis which
        % is used for computing the outlier indicators
        S2F.outlierDetectionRange = max(round(S2F.dim * .7), 3);
      end
    end

    % subsampling needs a real monomial sampling matrix, since linprog does
    % not accept a complex one
    function S2F = set.subsample(S2F, value)
      S2F.subsample = value;
      if value
        S2F.monomials = true;
      end
    end

    % tangent monomials require centered coordinates
    function S2F = set.tangent(S2F, value)
      S2F.tangent = value;
      if value
        S2F.centered = true;
      end
    end

    function out = get.isReal(f)
      out = isreal(f.values);
    end

    function F = set.isReal(F,value)
      if ~value, return; end
      F.values = real(F.values);
    end

    function S2F = set.oF(S2F, value)
      first_call = isempty(S2F.oF);
      if (value < 1)
        warning('Oversampling factor was too small and has been set to 2.');
        value = 2;
      end
      S2F.oF = value;
      if ~isempty(S2F.delta) && (S2F.delta > 0)
        warning('The support radius delta has been adopted to the new oversampling Factor');
        S2F.delta = S2F.compute_delta;
      end
      S2F.oF_max = 2 * S2F.oF;
      if ~first_call && ~isempty(S2F.auxgrid)
        S2F = S2F.update_auxgrid_dn;
      end
    end

    function S2F = set.candidateFactor(S2F, value)
      if (value < 1)
        warning(['The candidate buffer cannot be smaller than the ' ...
          'neighborhood and has been set to 1.']);
        value = 1;
      end
      S2F.candidateFactor = value;
    end

    % make sure nn is an integer value
    function nn = get.nn(S2F)
      nn = ceil(S2F.dim * S2F.oF);
    end

    % Assigning mincond also updates the target for backward compatibility.
    % Set targetcond afterwards when onset and target should be different.
    function S2F = set.mincond(S2F, value)
      S2F.mincond = value;
      S2F.targetcond = value;
    end

    function S2F = set.degree(S2F, deg)
      first_call = isempty(S2F.degree);
      S2F.degree = deg;
      if (S2F.degree == 0)
        S2F.regularize = false;
      end
      if ~first_call && ~isempty(S2F.auxgrid)
        S2F = S2F.update_auxgrid_dn;
      end
    end

    % print the calibrated goal-oriented regularization parameters
    function reg_params = show_reg_params(S2F)
      reg_params = struct;
      reg_params.mincond = S2F.mincond;
      reg_params.maxcond = S2F.maxcond;
      reg_params.targetcond = S2F.targetcond;
      reg_params.numericalCondMax = 1e10;
      reg_params.degreeExponent = 1;
      reg_params.degreeLaplaceShift = 1;
    end


    % create the auxiliary grid and precompute the distance to the n-th
    % neighbor; it is used for smoothing the support radius only
    function S2F = init_auxgrid(S2F)
      [nAux, auxInfo] = S2F.estimate_auxgrid_points;

      S2F.auxgrid = fibonacciS2Grid(nAux);
      S2F.auxgrid.opt.searcher = createns(S2F.auxgrid.xyz);

      % store diagnostics on the grid itself, without adding class properties
      S2F.auxgrid.opt.requestedPoints = nAux;
      S2F.auxgrid.opt.denseSupportRadius = auxInfo.denseSupportRadius;
      S2F.auxgrid.opt.densityContrast = auxInfo.densityContrast;

      S2F = S2F.update_auxgrid_dn;
    end

    % choose the auxiliary grid size from the smallest robust local support area
    function [nAux, info] = estimate_auxgrid_points(S2F)
      N = numel(S2F.nodes);

      % resolve the actual S2F.nn-th-neighbor distance field
      nfind = min(S2F.nn, N - 1);

      % probe at data nodes, since densely sampled regions require the finest
      %   auxiliary grid resolution; a one percent quantile is still well
      %   determined by a couple of thousand probes
      nProbe = min(N, 2000);
      probeId = unique(round(linspace(1, N, nProbe))).';

      % the first neighbor is the query node itself
      [~, dProbe] = S2F.nodes.find(S2F.nodes.subSet(probeId), nfind + 1);
      supportRadius = dProbe(:,end);

      % use a robust dense-region radius instead of the absolute minimum
      denseSupportRadius = getQuantile(supportRadius, .01);

      % relative area of a spherical cap with angular radius d
      capFraction = (1 - cos(denseSupportRadius)) / 2;

      % antipodal nodes represent two points each and hence cover twice as much
      domainFraction = (1 + S2F.antipodal) * capFraction;
      domainFraction = min(max(domainFraction, realmin), 1);

      % The degree-zero helper MLS uses oF = 20. Resolve roughly that many
      % auxiliary nodes inside the smallest robust data-support area.
      targetAuxNeighbors = 20;
      nAux = ceil(targetAuxNeighbors / domainFraction);

      % round up for reproducible grid sizes and apply practical bounds
      nAux = 1000 * ceil(nAux / 1000);
      nAux = min(max(nAux, 10000), 200000);

      % density contrast relative to a uniform node set with the same nfind
      uniformFraction = nfind / N;
      densityContrast = uniformFraction / domainFraction;

      info = struct;
      info.denseSupportRadius = denseSupportRadius;
      info.densityContrast = densityContrast;
    end

    function S2F = update_auxgrid_dn(S2F)
      if isempty(S2F.auxgrid), return; end

      nfind = min(S2F.nn, numel(S2F.nodes));
      [~, dn] = S2F.nodes.find(S2F.auxgrid, nfind);
      S2F.auxgrid.opt.dn = dn(:,end);
    end

    % healthy baseline amplification chi0 of the ansatz space
    %
    % chi0 is the center amplification that a perfectly distributed node cloud
    % produces with this degree, weight function and oversampling factor. It is
    % a property of the ansatz space and of the dimension of the manifold, not
    % of the nodes, so it is measured once on a small equispaced reference grid
    % rather than estimated from a quantile of the user's own nodes. A quantile
    % of the actual amplifications would mix this floor with the badly
    % distributed neighborhoods that the regularization is meant to detect.
    %
    % Because chi0 does not depend on the nodes, the measurement is cached for
    % the ansatz space it belongs to and costs nothing after the first call.
    function chi0 = baseline_amplification(S2F)

      persistent cache
      if isempty(cache), cache = containers.Map; end

      key = sprintf('%d|%g|%s|%d%d%d|%d', S2F.degree, S2F.oF, ...
        func2str(S2F.w), S2F.centered, S2F.tangent, S2F.monomials, ...
        S2F.antipodal);
      if isKey(cache, key)
        chi0 = cache(key);
        return;
      end

      ref = S2F;
      if ~isscalar(ref), ref = ref.subSet(1); end
      ref.regularize = false;
      ref.subsample = false;
      ref.detectOutliers = false;
      ref.outlierIndicators = [];

      % The floor is independent of the number of nodes, so a small reference
      % grid is enough. Uniform weights and a plain KNN support keep it cheap;
      % on equispaced nodes neither choice changes the result noticeably.
      ref.use_vor_weights = false;
      ref.use_smooth_delta = false;
      ref.delta = 0;
      ref.auxgrid = [];

      refnodes = reshape(fibonacciS2Grid(max(4000, 8 * S2F.nn)), [], 1);
      refnodes.antipodal = S2F.antipodal;
      ref.nodes = refnodes;
      ref.values = zeros(numel(refnodes), 1);
      ref.vor_weights = ones(numel(refnodes), 1);

      % On well-distributed nodes the amplification is almost constant, so a
      % few hundred centers resolve its median to well within one percent.
      stream = RandStream('mt19937ar', 'Seed', 1741 + 97 * S2F.degree);
      z = 2 * rand(stream, 250, 1) - 1;
      phi = 2*pi * rand(stream, 250, 1);
      r = sqrt(max(1 - z.^2, 0));
      centers = vector3d(r .* cos(phi), r .* sin(phi), z);

      [~, ~, info, ~] = ref.eval(centers);

      amp = real(info.centerAmplification(:));
      amp = amp(isfinite(amp) & amp >= 1);
      if isempty(amp)
        chi0 = 1;
      else
        chi0 = max(getQuantile(amp, .5), 1);
      end

      cache(key) = chi0;

    end

    % small reproducible random grid used only for regularization calibration
    function S2F = init_reg_auxgrid(S2F)
      % A slightly larger minimum improves the sampling of localized bad tails,
      % while remaining much smaller than the smooth-delta auxiliary grid.
      n = min(3000, max(1500, 30 * S2F.dim));
      stream = RandStream('mt19937ar', 'Seed', 1741 + 97 * S2F.degree);
      z = 2 * rand(stream, n, 1) - 1;
      phi = 2*pi * rand(stream, n, 1);
      r = sqrt(max(1 - z.^2, 0));
      S2F.reg_auxgrid = vector3d(r .* cos(phi), r .* sin(phi), z);
    end

    % compute expected number of neighbors with given S2F.nodes and S2F.delta
    function nn = guess_nn(S2F, varargin)
      if (S2F.delta == 0)
        nn = S2F.nn;
        warning(['Calling this function only makes sense if range-search is activated. ' ...
          'You can achieve this for example via S2F.delta = S2F.compute_delta. ' ...
          'I just returned S2F.nn for now.']);
        return;
      end

      v = vector3d.rand(1e4, 1);
      nns = S2F.count_neighbors(v);

      if isempty(varargin)
        nn = ceil(mean(nns));
        return;
      end

      switch lower(string(varargin{1}))
        case "min"
          % expected minimal number of neighbors
          nn = min(nns);
        case "max"
          % expected maximal number of neighbors
          nn = max(nns);
        otherwise
          nn = ceil(mean(nns));
      end

      nn = full(nn);
    end

    % return number of neighbors for given v (use for identifying 'bad regions')
    function nns = count_neighbors(S2F, v)
      if (S2F.delta == 0)
        nns = repmat(S2F.nn, size(v));
        warning(['Calling this function only makes sense if range-search is activated. ' ...
          'You can achieve this for example via S2F.delta = S2F.compute_delta. ' ...
          'I just returned S2F.nn for now.']);
        return;
      end

      ind = S2F.nodes.find(v, S2F.delta);
      nns = full(sum(ind, 2));
    end

    % important for subsref to function properly
    function n = numArgumentsFromSubscript(varargin)
      n = 0;
    end

    function fd = get.fill_distance(S2F)
      f = S2FunHandle(@(r) funDist(r,S2F));
      d = max(f,'numLocal',20,'maxStepSize',1*degree);
      fd = max(d);
    end

    function sd = get.separation_distance(S2F)
      [~, d] = S2F.nodes.find(S2F.nodes, 2);
      d = d(:,2);
      sd = min(d);
    end
  end

  methods (Static = true)
    S2F = interpolate(varargin);
    S2F = approximate(f, varargin);
    S2F = example(varargin)
  end

end


% Additional Functions
function d = funDist(modes, mls)
  [~, d] = mls.nodes.find(modes(:), 1);
  d = reshape(d,size(modes));
end
