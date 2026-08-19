classdef SO3FunMLS < SO3Fun
  % A class representing a function on the rotation group SO(3).
  %
  % The function is not stored by coefficients, but by nodes and values. It is
  % evaluated by a moving least squares approximation: at every evaluation
  % point a small weighted least squares problem over a local polynomial
  % ansatz space is solved, using only the nodes in a compactly supported
  % neighborhood of that point.
  %
  % Syntax
  %   SO3F = SO3FunMLS(nodes, values);
  %   SO3F = SO3FunMLS(nodes, values, 'degree', 3, 'oF', 4);
  %   SO3F = SO3FunMLS(nodes, values, 'delta', 5*degree, 'weight', @(t)(...));
  %   SO3F = SO3FunMLS(nodes, values, 'centered', true, 'monomials', true, ...
  %     'subsample', 'tangent', true);
  %   SO3F = SO3FunMLS(nodes, values, 'detectOutliers', ...
  %     'use_vor_weights', 'use_smooth_delta');
  %
  % Input
  %  nodes  - @orientation, @rotation (data points)
  %  values - array of function values assigned to the nodes
  %
  % Output
  %  SO3F - @SO3FunMLS
  %
  % Options
  %  degree  - polynomial degree used for approximation
  %  oF      - oversampling factor; nn is SO3F.dim times this factor
  %  oF_max  - maximal oversampling factor for range search
  %  delta   - support radius of the weight function; delta = 0 uses KNN
  %
  %  monomials - ignored; the monomial basis is the only one implemented on
  %              SO(3) (the option exists for interface parity with S2FunMLS)
  %  centered  - evaluate the basis in local coordinates around the identity
  %  tangent   - use monomials on the tangent space (requires centered = true)
  %    (NOTE: in this case the local a-coordinate of the neighbors is ignored)
  %
  %  weight  - @function_handle (weight function)
  %          - predefined choices are 'auto' (default, a degree-dependent
  %            Wendland C6 variant), 'C1hat', 'const', 'cos', 'hat',
  %            'indicator', 'squared hat', 'wendland', 'wendlandC6',
  %            'wendlandSquared', and 'wendlandC6Squared'
  %  use_smooth_delta - use a smooth local support radius with about SO3F.nn
  %                     neighbors at each center
  %  candidateFactor  - KNN candidates fetched per center as a multiple of nn
  %                     (default 2, only used with use_smooth_delta)
  %  use_vor_weights  - multiply the local weights by Voronoi volumes,
  %                     as in 'Stable Moving Least Squares Approximation'
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
  % S2FunMLS SO3FunHarmonic SO3FunRBF SO3FunMLS/eval SO3FunMLS/approximate


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

    s = specimenSymmetry.default;  % symmetry

    monomials   = true;   % ignored, only the monomial basis is implemented
    centered    = true;   % use local coordinates centered at evaluation point?
    tangent     = false;  % ignore the local a-coordinate for monomials?

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

    bandwidth   = getMTEXpref('maxSO3Bandwidth');
  end

  properties (Dependent)
    dim                   % dimension of the ansatz space
    nn                    % number of neighbors
    antipodal             % inherited from the nodes
    isReal                % = isReal(SO3F.values)
    SLeft                 % left symmetry of the nodes
    SRight                % right symmetry of the nodes

    % properties of the underlying nodes
    fill_distance         % fill distance
    separation_distance   % separation distance
  end

  methods

    % initialize a SO(3)-function
    function SO3F = SO3FunMLS(nodes, values, varargin)

      if nargin == 0, return; end

      % convert arbitrary SO3Fun to SO3FunMLS
      if isa(nodes,'function_handle') || isa(nodes,'SO3Fun')
        if nargin == 1, values = []; end
        SO3F = SO3FunMLS.approximate(nodes, values, varargin{:});
        return
      end

      % MLS needs unique nodes (nothing to do for an SO3Grid)
      isGrid = isa(nodes, 'SO3Grid');
      if isa(nodes, 'rotation')
        nodes = orientation(nodes);
      end

      if (~isGrid) && ...
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
      SO3F.nodes = nodes;

      % set Voronoi weights
      SO3F.use_vor_weights = get_option(varargin, 'use_vor_weights', true);
      if SO3F.use_vor_weights
        SO3F.vor_weights = calcSO3VoronoiWeights(nodes);
      else
        SO3F.vor_weights = ones(size(nodes));
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
      SO3F.values = values;

      % regularization flag and center-amplification parameters
      SO3F.regularize = get_option(varargin, ...
        {'regularize','regularization'}, true, 'logical');
      SO3F.mincond = get_option(varargin, ...
        {'mincond', 'min cond', 'min_cond', 'min amplification'}, []);
      SO3F.maxcond = get_option(varargin, ...
        {'maxcond', 'max cond', 'max_cond', 'max amplification'}, []);

      targetcond = get_option(varargin, ...
        {'targetcond', 'target cond', 'target_cond', ...
         'target amplification', 'targetamp'}, []);
      if ~isempty(targetcond)
        SO3F.targetcond = targetcond;
      elseif isempty(SO3F.mincond)
        SO3F.targetcond = [];
      end

      % degree, oversampling factor, and support radius
      SO3F.degree = get_option(varargin, {'degree', 'deg'}, 4, 'double');
      SO3F.oF = get_option(varargin, {'oF','of', 'OF','oversamplingfactor',...
        'oversampling_factor','oversampling factor'}, 4, 'double');
      % half of SO(3) should already contain sufficiently many nodes
      if (SO3F.nn > numel(SO3F.nodes) / 2)
        error('Too few data points for the specified degree and oversampling factor.');
      end
      SO3F.oF_max = get_option(varargin, {'ofmax','of max', 'max of', 'maxof', ...
        'maximal oversampling factor', 'max oversampling factor'}, ...
        2 * SO3F.oF, 'double');
      SO3F.delta = get_option(varargin, ...
        {'delta', 'range', 'support radius'}, 0, 'double');

      % weight function, distance, and symmetry
      SO3F.w = get_option(varargin, 'weight', 'auto', ...
        {'string','function_handle','char'});
      SO3F.distance = get_option(varargin, 'distance', 'euclidean', 'char');
      SO3F.s = get_option(varargin, {'symmetry', 'cs', 's', 'ss'}, ...
        specimenSymmetry.default, 'crystalSymmetry');

      % optional explicit left/right symmetries
      SLeft = get_option(varargin, ...
        {'SLeft', 'sLeft', 'leftSymmetry', 'left symmetry'}, []);
      SRight = get_option(varargin, ...
        {'SRight', 'sRight', 'rightSymmetry', 'right symmetry'}, []);
      if ~isempty(SLeft), SO3F.SLeft = SLeft; end
      if ~isempty(SRight), SO3F.SRight = SRight; end

      % basis options
      SO3F.monomials = get_option(varargin, 'monomials', true, 'logical');
      SO3F.tangent = get_option(varargin, 'tangent', false, 'logical');
      SO3F.centered = get_option(varargin, 'centered', true, 'logical');
      if SO3F.tangent, SO3F.centered = true; end
      if SO3F.centered, SO3F.monomials = true; end

      % outlier detection
      SO3F.detectOutliers = check_option(varargin, ...
        {'detect outliers', 'detectoutliers', 'detect_outliers'});
      SO3F.outlierDetectionRange = round(get_option(varargin, ...
        {'outlierdetectionrange', 'outlier detection range', 'odr'}, ...
        SO3F.outlierDetectionRange, 'double'));
      if SO3F.detectOutliers
        SO3F.outlierIndicators = SO3F.compute_outlier_indicators;
      end

      % optimal subsampling (minimizes the Lebesgue constant)
      SO3F.subsample = check_option(varargin, {'subsampling', 'subsample'});
      if SO3F.subsample, SO3F.centered = true; end

      if SO3F.regularize && SO3F.centered && ...
          mod(SO3F.degree, 2) == 1 && ~SO3F.tangent && ...
          ~getMTEXpref('generatingHelpMode')
        warning(['For odd non-tangent ansatz spaces the first basis function is ' ...
          'only a local constant surrogate. Exact constant preservation is not ' ...
          'available. Tangent monomials are usually preferable.']);
      end

      SO3F.use_smooth_delta = get_option(varargin, {'use_smooth_delta', ...
        'use smooth delta', 'smooth_delta', 'smooth delta'}, true);

      % A smooth support radius is not tied to the neighbor ranking, so more
      % than nn candidates have to be fetched per center.
      SO3F.candidateFactor = get_option(varargin, {'candidateFactor', ...
        'candidatefactor', 'candidate factor', 'candidate_factor'}, ...
        2, 'double');

      % The two auxiliary grids have different jobs. Smooth delta uses a dense
      % equispaced grid; regularization calibration uses a much smaller random grid.
      needs_auto_regularization = SO3F.regularize && ...
        (isempty(SO3F.mincond) || isempty(SO3F.maxcond) || ...
         isempty(SO3F.targetcond));

      if SO3F.use_smooth_delta && (SO3F.delta == 0)
        SO3F = SO3F.init_auxgrid;
      end
      if needs_auto_regularization
        SO3F = SO3F.init_reg_auxgrid;
        SO3F = SO3F.init_reg_params;
      end
    end

    function SO3F = set.w(SO3F, weightfun)
      if isa(weightfun, 'function_handle')
        SO3F.w = weightfun;
        return;
      end

      % Wendland C6 in Horner form. The weight is evaluated once per center and
      % neighbor, so avoiding the repeated powers of t is worth the detour.
      wendlandC6 = @(t)(max(1-t, 0).^8 .* (((32*t + 25).*t + 8).*t + 1));

      switch lower(char(weightfun))
        case 'hat'
          SO3F.w = @(t)(max(1-t, 0));
        case 'squared hat'
          SO3F.w = @(t)(max(1-t, 0).^2);
        case {'indicator','const'}
          SO3F.w = @(t)(t <= 1);
        case 'cos'
          SO3F.w = @(t)(((1+cos(pi*t))/2) .* (t <= 1));
        case 'auto'
          % Degree-dependent localization, identical to S2FunMLS:
          % higher degrees use a narrower effective neighborhood.
          % Wendland C6 evaluated at t^alpha and subsequently raised to beta.
          alpha = max(1, 2 - (SO3F.degree - 1) / 3);
          beta = 1 + max(SO3F.degree - 2, 0) / 3;

          if alpha == 1
            SO3F.w = @(t)(wendlandC6(t).^beta);
          elseif beta == 1
            SO3F.w = @(t)(wendlandC6(t.^alpha));
          else
            SO3F.w = @(t)(wendlandC6(t.^alpha).^beta);
          end

        case 'c1hat'
          % Fixed broad weight for explicit comparisons.
          SO3F.w = @(t)(max(1-t.^2, 0).^2);
        case 'wendland'
          SO3F.w = @(t)(max(1-t, 0).^4 .* (4*t+1));
        case 'wendlandc6'
          SO3F.w = wendlandC6;
        case 'wendlandsquared'
          SO3F.w = @(t)((max(1-t, 0).^4 .* (4*t+1)).^2);
        case 'wendlandc6squared'
          SO3F.w = @(t)(wendlandC6(t).^2);
        otherwise
          error('Unknown MLS weight function.');
      end
    end

    % choose delta such that factor-oF oversampling is expected for iid nodes
    function d = compute_delta(SO3F)
      % the surface area of a spherical cap with angular radius phi in 4D is
      %   1 / pi * (phi - sin(phi) * cos(phi))
      % the surface area of one hemisphere is pi^2
      % for N nodes on one hemisphere, the expected number of nodes in this
      %   spherical cap is N / pi * (phi - sin(phi) * cos(phi))
      % assuming uiid nodes, we compute delta such that the expected number of
      %   nodes in a spherical cap with radius phi is nn
      % NOTE:
      %   1 - the sphere covers SO(3) twice
      %         (N nodes on SO(3) are like 2N nodes on S^3)
      %   2 - take into account symmetries
      %         (each node in the fundamentalRegion corresponds to
      %           <symmetry_factor> many nodes on SO(3))
      symmetry_factor = numProper(SO3F.SLeft) * numProper(SO3F.SRight);
      target = pi / 2 * SO3F.nn / numel(SO3F.nodes) / symmetry_factor;

      % phi - sin(phi)*cos(phi) increases monotonically from 0 to pi/2 on
      % [0, pi/2], so bisection is both safe and accurate to machine precision
      target = min(max(target, 0), pi/2);
      lower = 0;
      upper = pi/2;
      for iter = 1 : 60
        middle = (lower + upper) / 2;
        if (middle - sin(middle) * cos(middle)) < target
          lower = middle;
        else
          upper = middle;
        end
      end
      phi = (lower + upper) / 2;

      % the quaterion distance is twice the spherical distance
      d = 2 * phi;
    end

    function dimension = get.dim(SO3F)
      dimension = nchoosek(SO3F.degree + 3, 3);
    end

    function antipodal = get.antipodal(SO3F)
      antipodal = SO3F.nodes.antipodal;
    end

    function SO3F = set.antipodal(SO3F, value)
      SO3F.nodes.antipodal = value;
    end

    function SO3F = set.SRight(SO3F, S)
      SO3F.nodes.CS = S;
    end

    function S = get.SRight(SO3F)
      S = SO3F.nodes.CS;
    end

    function SO3F = set.SLeft(SO3F, S)
      SO3F.nodes.SS = S;
    end

    function S = get.SLeft(SO3F)
      S = SO3F.nodes.SS;
    end

    function SO3F = set.detectOutliers(SO3F, value)
      SO3F.detectOutliers = value;
      if value
        % set standard value of the outlier detection range
        % should be at least 4, since this is the dimension of the basis which
        % is used for computing the outlier indicators
        SO3F.outlierDetectionRange = max(round(SO3F.dim * .7), 4);
      end
    end

    % subsampling needs a real monomial sampling matrix, since linprog does
    % not accept a complex one
    function SO3F = set.subsample(SO3F, value)
      SO3F.subsample = value;
      if value
        SO3F.monomials = true;
      end
    end

    % tangent monomials require centered coordinates
    function SO3F = set.tangent(SO3F, value)
      SO3F.tangent = value;
      if value
        SO3F.centered = true;
      end
    end

    function out = get.isReal(f)
      out = isreal(f.values);
    end

    function F = set.isReal(F,value)
      if ~value, return; end
      F.values = real(F.values);
    end

    function SO3F = set.oF(SO3F, value)
      first_call = isempty(SO3F.oF);
      if (value < 1)
        warning('Oversampling factor was too small and has been set to 2.');
        value = 2;
      end
      SO3F.oF = value;
      if ~isempty(SO3F.delta) && (SO3F.delta > 0)
        warning('The support radius delta has been adopted to the new oversampling Factor');
        SO3F.delta = SO3F.compute_delta;
      end
      SO3F.oF_max = 2 * SO3F.oF;
      if ~first_call && ~isempty(SO3F.auxgrid)
        SO3F = SO3F.update_auxgrid_dn;
      end
    end

    function SO3F = set.candidateFactor(SO3F, value)
      if (value < 1)
        warning(['The candidate buffer cannot be smaller than the ' ...
          'neighborhood and has been set to 1.']);
        value = 1;
      end
      SO3F.candidateFactor = value;
    end

    % make sure nn is an integer value
    function nn = get.nn(SO3F)
      nn = ceil(SO3F.dim * SO3F.oF);
    end

    % Assigning mincond also updates the target for backward compatibility.
    % Set targetcond afterwards when onset and target should be different.
    function SO3F = set.mincond(SO3F, value)
      SO3F.mincond = value;
      SO3F.targetcond = value;
    end

    function SO3F = set.degree(SO3F, deg)
      first_call = isempty(SO3F.degree);
      SO3F.degree = deg;
      if (SO3F.degree == 0)
        SO3F.regularize = false;
      end
      if ~first_call && ~isempty(SO3F.auxgrid)
        SO3F = SO3F.update_auxgrid_dn;
      end
    end

    % print the calibrated goal-oriented regularization parameters
    function reg_params = show_reg_params(SO3F)
      reg_params = struct;
      reg_params.mincond = SO3F.mincond;
      reg_params.maxcond = SO3F.maxcond;
      reg_params.targetcond = SO3F.targetcond;
      reg_params.numericalCondMax = 1e10;
      reg_params.degreeExponent = 1;
      reg_params.degreeLaplaceShift = 2;
    end


    % create the auxiliary grid and precompute the distance to the n-th
    % neighbor; it is used for smoothing the support radius only
    function SO3F = init_auxgrid(SO3F)
      [nAux, auxInfo] = SO3F.estimate_auxgrid_points;

      SO3F.auxgrid = equispacedSO3Grid( ...
        SO3F.nodes.CS, SO3F.nodes.SS, 'points', nAux);

      % store diagnostics on the grid itself, without adding class properties
      SO3F.auxgrid.opt.requestedPoints = nAux;
      SO3F.auxgrid.opt.denseSupportRadius = auxInfo.denseSupportRadius;
      SO3F.auxgrid.opt.densityContrast = auxInfo.densityContrast;

      SO3F = SO3F.update_auxgrid_dn;
    end

    % choose the auxiliary grid size from the smallest robust local support volume
    function [nAux, info] = estimate_auxgrid_points(SO3F)
      N = numel(SO3F.nodes);

      % resolve the actual SO3F.nn-th-neighbor distance field
      nfind = min(SO3F.nn, N - 1);

      % probe at data nodes, since densely sampled regions require the finest
      %   auxiliary grid resolution; a one percent quantile is still well
      %   determined by a couple of thousand probes
      nProbe = min(N, 2000);
      probeId = unique(round(linspace(1, N, nProbe))).';

      % the first neighbor is the query node itself
      [~, dProbe] = SO3F.nodes.find(SO3F.nodes.subSet(probeId), nfind + 1);
      supportRadius = dProbe(:,end);

      % use a robust dense-region radius instead of the absolute minimum
      denseSupportRadius = getQuantile(supportRadius, .01);

      % relative volume of an SO(3) ball with rotation-angle radius d
      phi = denseSupportRadius / 2;
      ballFraction = 2 / pi * (phi - sin(phi) * cos(phi));

      % relative to the fundamental region, the same ball occupies a larger fraction
      symmetryFactor = numProper(SO3F.SLeft) * numProper(SO3F.SRight);
      domainFraction = symmetryFactor * ballFraction;
      domainFraction = min(max(domainFraction, realmin), 1);

      % The degree-zero helper MLS uses oF = 20. Resolve roughly that many
      % auxiliary nodes inside the smallest robust data-support volume.
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

    function SO3F = update_auxgrid_dn(SO3F)
      if isempty(SO3F.auxgrid), return; end

      nfind = min(SO3F.nn, numel(SO3F.nodes));
      [~, dn] = SO3F.nodes.find(SO3F.auxgrid, nfind);
      SO3F.auxgrid.opt.dn = dn(:,end);
    end

    % small reproducible random grid used only for regularization calibration
    function SO3F = init_reg_auxgrid(SO3F)
      % A slightly larger minimum improves the sampling of localized bad tails,
      % while remaining much smaller than the smooth-delta auxiliary grid.
      n = min(3000, max(1500, 30 * SO3F.dim));
      stream = RandStream('mt19937ar', 'Seed', 1741 + 97 * SO3F.degree);

      % normalized Gaussians are uniformly distributed on the sphere S^3
      q = randn(stream, n, 4);
      q = q ./ sqrt(sum(q.^2, 2));
      SO3F.reg_auxgrid = orientation(q(:,1), q(:,2), q(:,3), q(:,4), ...
        SO3F.SRight, SO3F.SLeft);
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
    function chi0 = baseline_amplification(SO3F)

      persistent cache
      if isempty(cache), cache = containers.Map; end

      key = sprintf('%d|%g|%s|%d%d%d|%d|%d', SO3F.degree, SO3F.oF, ...
        func2str(SO3F.w), SO3F.centered, SO3F.tangent, SO3F.monomials, ...
        SO3F.SLeft.id, SO3F.SRight.id);
      if isKey(cache, key)
        chi0 = cache(key);
        return;
      end

      ref = SO3F;
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

      refnodes = equispacedSO3Grid(SO3F.SRight, SO3F.SLeft, ...
        'points', max(4000, 8 * SO3F.nn));
      refnodes = reshape(refnodes, [], 1);
      ref.nodes = refnodes;
      ref.values = zeros(numel(refnodes), 1);
      ref.vor_weights = ones(numel(refnodes), 1);

      % On well-distributed nodes the amplification is almost constant, so a
      % few hundred centers resolve its median to well within one percent.
      stream = RandStream('mt19937ar', 'Seed', 1741 + 97 * SO3F.degree);
      q = randn(stream, 250, 4);
      q = q ./ sqrt(sum(q.^2, 2));
      centers = orientation(q(:,1), q(:,2), q(:,3), q(:,4), ...
        SO3F.SRight, SO3F.SLeft);

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

    % compute expected number of neighbors with given SO3F.nodes and SO3F.delta
    function nn = guess_nn(SO3F, varargin)
      if (SO3F.delta == 0)
        nn = SO3F.nn;
        warning(['Calling this function only makes sense if range-search is activated. ' ...
          'You can achieve this for example via SO3F.delta = SO3F.compute_delta. ' ...
          'I just returned SO3F.nn for now.']);
        return;
      end

      ori = equispacedSO3Grid(SO3F.nodes.CS, SO3F.nodes.SS, 'points', 10000);
      nns = SO3F.count_neighbors(ori);

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

    % return number of neighbors for given ori (use for identifying 'bad regions')
    function nns = count_neighbors(SO3F, ori)
      if (SO3F.delta == 0)
        nns = repmat(SO3F.nn, size(ori));
        warning(['Calling this function only makes sense if range-search is activated. ' ...
          'You can achieve this for example via SO3F.delta = SO3F.compute_delta. ' ...
          'I just returned SO3F.nn for now.']);
        return;
      end

      ind = SO3F.nodes.find(ori, SO3F.delta);
      nns = full(sum(ind, 2));
    end

    % important for subsref to function properly
    function n = numArgumentsFromSubscript(varargin)
      n = 0;
    end

    function fd = get.fill_distance(SO3F)
      f = SO3FunHandle(@(r) funDist(r,SO3F),SO3F.CS,SO3F.SS);
      acc = 0.25*degree;
      d = max(f,'accuracy',acc,'numLocal',20,'resolution',3*degree);
      fd = max(d);
    end

    function sd = get.separation_distance(SO3F)
      [~, d] = SO3F.nodes.find(SO3F.nodes, 2);
      d = d(:,2);
      sd = min(d);
    end
  end

  methods (Static = true)
    SO3F = interpolate(varargin);
    SO3F = approximate(f, varargin);
    SO3F = example(varargin)
  end

end


% Additional Functions
function d = funDist(modes, mls)
  [~, d] = mls.nodes.find(modes(:), 1);
  d = reshape(d,size(modes));
end

function w = calcSO3VoronoiWeights(nodes)
  if ismethod(nodes, 'calcVoronoiVolume')
    w = nodes.calcVoronoiVolume;
  elseif ismethod(nodes, 'calcVoronoiArea')
    w = nodes.calcVoronoiArea;
  else
    w = ones(size(nodes));
  end
end
