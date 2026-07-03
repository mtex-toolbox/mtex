classdef S2FunMLS < S2Fun
  % A class representing a function on the 2-sphere S^2.
  %
  % Syntax
  %   S2F = S2FunMLS(nodes, values);
  %   S2F = S2FunMLS(nodes, values, 'degree', 3, 'oF', 4);
  %   S2F = S2FunMLS(nodes, values, 'delta', 5*degree, 'weight', @(t)(...));
  %   S2F = S2FunMLS(nodes, values, 'centered', true, 'monomials', true, 'subsample', 'tangent', true);
  %   S2F = S2FunMLS(nodes, values, 'detectOutliers', 'use_vor_weights', 'use_smooth_delta');
  %
  % Input
  %  nodes  - @vector3d (data points)
  %  values - array of function values assigned to the nodes
  %
  % Output
  %  S2F - @S2FunMLS
  %
  % Options
  %  degree  - the polynomial degree used for approximation
  %  oF      - oversampling Factor. the number of neighbors nn (dependent) is the
  %              dimension of the ansatz space, times this factor
  %  oF_max  - maximum oversampling factor in case of range search. At most the
  %              closest S2F.dim * S2F.oF_max neighbors will be used.
  %  delta   - support radius of the weight function
  %              when searching for outliers
  %
  %  monomials- use monomial basis if true, otherwise use spherical harmonics
  %  centered - evaluate the basis functions only around the north pole, if true
  %  tangent  - use monomials on the tangent space (only if centered == true)
  %              (in this case the z-coordinate of the neighbors is ignored)
  %    (NOTE: 'centered' and 'tangent' trigger the monomial-option to be true)
  %
  %  w       - @function_handle (weight function)
  %          - predefined weight function can be chosen via the following strings:
  %             'C1hat', 'const', 'cos', 'hat', 'indicator', 'squared hat',
  %             'wendland' (default)
  %  use_smooth_delta - make the support radius delta(x) a smooth function with
  %                     close to S2F.nn neighbors at each center
  %  use_vor_weights -  additionally multiply w(x,x_i) by the Voronoi Volumne of
  %                     x_i, as in 'Stable Moving Least Squares Approximation'
  % 
  %  distance- specify which metric to use (default: 'euclidean')
  %          - run 'help rangesearch' for available options
  %  s       - symmetry of the nodes
  %
  %  regularize    - use regularization for solving the lsq-systems
  %  maxcond       - max regularization threshold of condition of the gram matrix
  %  mincond       - start regularizing threshold of condition of the gram matrix
  %  basis_weights -  regularization weights of basis coefficients,
  %                    should punish higher degrees (Sobolev-like)
  %  basis_weights_scale - application strength of basis_weights
  %  lambda_geom_rel - relative application strength of geometrical regularization
  %
  %  outlierDetectionRange - specify how many neighbors are taken into account
  %
  % Flags
  %  detectOutliers - find outliers in the data and reduce their weight in the local least squares problems
  %                   depending on how bad they are
  %  subsample      - use subset of neighbors that minimizes the lebesgue constant
  %


  properties
    nodes       = [];     % points where the function values are known
    values      = [];     % the corresponding values

    vor_weights = [];     % voronoi weights for the weight function, 
                          %   as described in 'stable MLS' by Lipman
    use_vor_weights = true; 

    degree      = 3;      % the polynomial degree used for approximation
    oF          = 4;      % oversampling factor (nn / dim)
    oF_max      = 5;      % upper bound for oF when using rangesearch
    delta       = 0;      % support radius of the weight function

    use_smooth_delta = true; % delta(x) is smooth, with close to S2F.nn neighbors everywhere

    w           = @(t)(max(1-t, 0).^4 .* (4*t+1)); % Wendland weight function
    distance    = 'euclidean'; % specify metric for neighbor search

    s = specimenSymmetry.default;  % symmetry

    monomials   = true;   % use monomial basis? (much more stable than harmonic)
    centered    = true;   % center the basis function evaluation around the north pole?
    tangent     = false;  % if monomials, use monomials on the tangent space?

    regularize;           % regularize?
    maxcond = [];         % condition threshold of Gram matrix that triggers maximal regularization
    mincond = [];         % start regularizing threshold of condition of the gram matrix
    basis_weights = [];   % regularization weights of basis coefficients,
                          %   should punish higher degrees (Sobolev-like)
    basis_weights_scale = []; % basis_weights are in [0,1]. The solver applies 
                              %   1 + basis_weights_scale * basis_weights
    lambda_geom_rel = []; % geometrical regularization strength relative to the
                          %   local Gram scale after column normalization

    detectOutliers = false; % specify if we should search for outliers, and reduce their weight
    outlierDetectionRange = 10; % number of neighbors to take into account for outlier detection

    subsample   = false;  % perform optimal subsampling?

    auxgrid = [];         % auxiallary grid for evaluation-related computations
  end

  properties (Dependent)
    dim                   % dimension of the ansatz space
    nn                    % number of neighbors to take into account
    antipodal             % inherited from the nodes
    isReal                % = isReal(S2F.values)
    outlierIndicators     % same size as S2F.values, contains for each node a
    %   number that is bigger, if the value is an outlier

    % properties of the underlying nodes
    fill_distance         % fill distance
    separation_distance   % separation distance
  end

  methods
    % initialize a spherical function
    function S2F = S2FunMLS(nodes, values, varargin)

      if nargin == 0, return; end

      % convert arbitrary S2Fun to S2FunHarmonic
      if isa(nodes,'function_handle') || isa(nodes,'S2Fun')
        if nargin == 1, values=[]; end
        S2F = S2FunMLS.approximate(nodes,values,varargin{:});
        return
      end

      % MLS needs unique nodes (nothing to do if nodes are a fibonacciS2Grid)
      if (~isa(nodes, 'fibonacciS2Grid')) && ...
          (numel(unique(nodes, 'stable', 'tolerance', .001 * degree)) < numel(nodes))
        nodes = nodes(:);
        values = reshape(values, numel(nodes), []);
        [nodes, values] = uniqueData(nodes, values, 'mean','tolerance', .001 * degree);
        if ~getMTEXpref('generatingHelpMode')
          warning(['Some duplicate Nodes have been removed. ' ...
            'The remaining nodes have been reshaped into a vector.']); 
        end
      end

      % goal of reshaping:
      %   - nodes is nx1 or 1xn ==> make nx1, and reshape values to n x ...
      %   - nodes is at least 2d ==> values is size(nodes) x ...
      if isrow(nodes)
        nodes = reshape(nodes, numel(nodes), 1);
      end
      S2F.nodes = nodes;
      if ~isfield(nodes.opt, 'searcher')
        S2F.nodes.opt.searcher = createns(nodes.xyz);
      end

      % set voronoi weights
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

      % set degree, (maximal) oversampling factor, support radius delta
      S2F.regularize = get_option(varargin, {'regularize','regularization'}, true, 'logical');
      S2F.degree = get_option(varargin, {'degree', 'deg'}, 4, 'double');
      S2F.oF = get_option(varargin, {'oF','of', 'OF','oversamplingfactor',...
        'oversampling_factor','oversampling factor'}, 4, 'double');
      % half of the sphere should already contain sufficiently many nodes
      if (S2F.nn > numel(S2F.nodes) / 2)
        error('Too few data points for the specified degree and oversampling factor.');
      end
      S2F.oF_max = get_option(varargin, {'ofmax','of max', 'max of', 'maxof', ...
        'maximal oversampling factor', 'max oversampling factor'}, 2 * S2F.oF, 'double');
      S2F.delta = get_option(varargin, {'delta', 'range', 'support radius'}, 0, 'double');

      % weight function, distance, symmetry
      S2F.w = get_option(varargin, 'weight', 'wendlandC6squared', {'string','function_handle','char'});
      S2F.distance = get_option(varargin, 'distance', 'euclidean', 'char');
      S2F.s = get_option(varargin, {'symmetry', 'cs', 's', 'ss'}, ...
        specimenSymmetry.default, 'crystalSymmetry');

      % basis stuff
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

      % optimal subsampling (minimizes Lebesgue constant)
      S2F.subsample = check_option(varargin, {'subsampling', 'subsample'});
      if S2F.subsample, S2F.centered = true; end

      S2F.use_smooth_delta = get_option(varargin, {'use_smooth_delta', ...
        'use smooth delta', 'smooth_delta', 'smooth delta'}, true);

      % regularization parameters
      S2F.basis_weights = get_option(varargin, {'basis_weights', 'basisweights', ...
        'basis weights'}, S2F.compute_basis_weights, 'double');

      % create auxilliary grid if it is needed
      needs_auto_regularization = S2F.regularize && ...
        (isempty(S2F.mincond) || isempty(S2F.maxcond) || ...
         isempty(S2F.basis_weights_scale) || isempty(S2F.lambda_geom_rel));
      if S2F.use_smooth_delta || needs_auto_regularization
        S2F = S2F.init_auxgrid;
      end

      % initialize missing regularization parameters from auxilliary grid
      if needs_auto_regularization
        S2F = S2F.init_reg_params;
      end

      S2F.s.how2plot = nodes.how2plot;
    end

    function S2F = set.w(S2F, weightfun)
      if (isa(weightfun, 'function_handle'))
        S2F.w = weightfun;
      else
        switch weightfun
          case 'hat';         S2F.w = @(t)(max(1-t, 0));
          case 'squared hat'; S2F.w = @(t)(max(1-t, 0).^2);
          case 'indicator';   S2F.w = @(t)(t <= 1);
          case 'const';       S2F.w = @(t)(t <= 1);
          case 'cos';         S2F.w = @(t)((1+cos(pi*t))/2);
          case 'C1hat';       S2F.w = @(t)((1-t.^2).^2);
          case 'wendland';    S2F.w = @(t)(max(1-t, 0).^4 .* (4*t+1));
          case 'wendlandC6';  S2F.w = @(t)((max(1-t,0).^8) .* (32*t.^3 + 25*t.^2 + 8*t + 1));
          case 'wendlandsquared';   S2F.w = @(t)((max(1-t, 0).^4 .* (4*t+1)) .^2);
          case 'wendlandC6squared'; S2F.w = @(t)(((max(1-t,0).^8) .* (32*t.^3 + 25*t.^2 + 8*t + 1)) .^2);
          otherwise;          S2F.w = @(t)((max(1-t,0).^8) .* (32*t.^3 + 25*t.^2 + 8*t + 1).^2);
        end
      end
    end

  % choose delta such that we get can expect factor-oF-oversampling for uiid
  %   points
  function d = compute_delta(S2F)
    antipodal_factor = 1 + S2F.antipodal;
    d = acos(1 - 2 * S2F.dim * S2F.oF / numel(S2F.nodes) / antipodal_factor);
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
    if (value)
      % set standard value of outlier detection range
      % should be at least 3, since this is the dim of the basis which is used
      % for computing the outlier indicators
      S2F.outlierDetectionRange = max(round(S2F.dim * .7), 3);
    end
  end

  % subsampling needs monomial basis, since linprog need real sampling matrix
  function S2F = set.subsample(S2F, value)
    S2F.subsample = value;
    if (value == true)
      S2F.monomials = true;
    end
  end

  % tangent needs centered
  function S2F = set.tangent(S2F, value)
    S2F.tangent = value;
    if (value == true)
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
    if (value < 1)
      warning('Oversampling factor was too small and has been set to 2.');
      value = 2;
    end
    S2F.oF = value;
    if (S2F.delta > 0)
      warning('The support radius delta has been adopted to the new oversampling Factor');
      S2F.delta = S2F.compute_delta;
    end
    S2F.oF_max = 2 * S2F.oF;
  end

  % make sure nn is an integer value
  function nn = get.nn(S2F)
    nn = ceil(S2F.dim * S2F.oF);
  end

  function S2F = set.degree(S2F, deg)
    S2F.degree = deg;
    if S2F.regularize
      S2F.basis_weights = S2F.compute_basis_weights;
    end
  end

  % compute weights for basis functions for regularization of lsq systems
  %   (punish higher degrees, see tools/mathtools/solve_lsq_book_constsize.m)
  % weights are between 0 (lowest degree) and 1 (highest degree)
  % they get applied in tools/math_tools/solve_lsq_book_constsize.m
  function basis_weights = compute_basis_weights(S2F)
    degrees = (0 : S2F.degree)';
    basis_weights = repelem(degrees.^2, degrees+1, 1);

    % avoid division by empty mean for degree zero
    m = mean(nonzeros(basis_weights));
    if isempty(m) || ~isfinite(m) || (m == 0)
      basis_weights = zeros(size(basis_weights));
    else
      basis_weights = basis_weights / m;
    end
  end

  function S2F = set.basis_weights(S2F, value)
    if (numel(value) ~= S2F.dim)
      error(['The number of elements in the basis_weights must match' ...
        'the dimension of the ansatz space.']);
    end
    value = value(:);
    value = max(real(value), 0);
    pos = value > 0;
    value(pos) = value(pos) / mean(value(pos));
    S2F.basis_weights = value;
  end

  % print reg parameters and diagnostic if desired
  function reg_params = show_reg_params(S2F)
    reg_params = struct;
    reg_params.mincond = S2F.mincond;
    reg_params.maxcond = S2F.maxcond;
    reg_params.lambda_geom_rel = S2F.lambda_geom_rel;
    reg_params.basis_weights_scale = S2F.basis_weights_scale;
    reg_params.basis_weights = S2F.basis_weights;
  end


  % create auxilliary grid and precompute distance to n-th neighbor
  function S2F = init_auxgrid(S2F)
    S2F.auxgrid = fibonacciS2Grid(10001);
    S2F.auxgrid.opt.searcher = createns(S2F.auxgrid.xyz);

    % slight overshoot later ensures that mostly n neighbors are found
    nfind = max(round(1.3*S2F.nn), S2F.nn+10);
    [~, dn] = S2F.nodes.find(S2F.auxgrid, nfind);
    S2F.auxgrid.opt.dn = dn(:,end);
  end

  % compute expected number of neighbors with given sF.nodes and sF.delta
  function nn = guess_nn(S2F, varargin)
    if (S2F.delta == 0)
      nn = S2F.nn;
      warning(['Calling this function only makes sense if range-search is acitvated. ' ...
        'You can achieve this for example via S2F.delta = S2F.compute_delta. ' ...
        'I just returned S2F.nn for now.']);
      return;
    end

    v = vector3d.rand(1e4, 1);
    ind = S2F.nodes.find(v, S2F.delta);
    nns = full(sum(ind, 2));

    if (numel(varargin) == 0)
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
      warning(['Calling this function only makes sense if range-search is acitvated. ' ...
        'You can achieve this for example via S2F.delta = S2F.compute_delta. ' ...
        'I just returned S2F.nn for now.']);
      return;
    end

    ind = S2F.nodes.find(v, S2F.delta);
    nns = full(sum(ind, 2));
  end

  function oI = get.outlierIndicators(S2F)
    oI = computeOutlierIndicators(S2F);
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