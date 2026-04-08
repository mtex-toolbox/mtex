classdef S2FunMLS < S2Fun
  % a class representing a function on the rotation group
  %
  % TODO: - also regulrize when nodes are almost on zero set of ansatz function
  %       - locally adapt delta via density estimation and integration on balls or
  %           via shepard on the distance of the k-th nearest neighbor
  %
  % Syntax
  %   S2F = S2FunMLS(nodes, values);
  %   S2F = S2FunMLS(nodes, values, 'degree', 3, 'oF', 2);
  %   S2F = S2FunMLS(nodes, values, 'delta', 5*degree);
  %   S2F = S2FunMLS(nodes, values, 'delta', 5*degree, w, @(t)(__));
  %   S2F = S2FunMLS(nodes, values, 'centered', true, 'monomials', true, 'subsample', 'tangent', true);
  %   S2F = S2FunMLS(nodes, values, 'regularize', false, 'stablefind', true, 'detectOutliers');
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
  %  distance- specify which metric to use (default: 'euclidean')
  %          - run 'help rangesearch' for available options
  %  s       - symmetry of the nodes
  %
  %  regularize    - use regularization for solving the lsq-systems
  %  maxcond       - max regularization threshold of condition of the gram matrix
  %  mincond       - start regularizing threshold of condition of the gram matrix
  %  basis_weights -  regularization weights of basis coefficients,
  %                    should punish higher degrees (Sobolev-like)
  %
  %  outlierDetectionRange - specify how many neighbors are taken into account
  %
  % Flags
  %  detectOutliers - find outliers in the data and reduce their weight in the local least squares problems
  %                   depending on how bad they are
  %  stableFind     - perform stable variant of find (can help with non-uniform data)
  %  subsample      - use subset of neighbors that minimizes the lebesgue constant
  %


  properties
    nodes       = [];     % points where the function values are known
    values      = [];     % the corresponding values

    searcher    = [];     % kdTreeSearcher object for neighbor search on nodes

    degree      = 3;      % the polynomial degree used for approximation
    oF          = 4;      % oversampling factor (nn / dim)
    oF_max      = 5;      % upper bound for oF when using rangesearch
    delta       = 0;      % support radius of the weight function

    w           = @(t)(max(1-t, 0).^4 .* (4*t+1)); % Wendland weight function
    distance    = 'euclidean'; % specify metric for neighbor search

    s = specimenSymmetry;  % symmetry

    monomials   = true;   % use monomial basis? (much more stable than harmonic)
    centered    = true;   % center the basis function evaluation around the north pole?
    tangent     = false;  % if monomials, use monomials on the tangent space?

    regularize = true;    % regularize?
    maxcond = 1e5;        % condition threshold of Gram matrix that triggers maximal regularization
    mincond = 1e2;        % start regularizing threshold of condition of the gram matrix
    basis_weights;        % regularization weights of basis coefficients,
                          %   should punish higher degrees (Sobolev-like)

    detectOutliers = false; % specify if we should search for outliers, and recude their weight
    outlierDetectionRange = 10; % number of neighbors to take into account for outlier detection

    subsample   = false;  % perform optimal subsampling?

    stableFind = false;   % use stable find algorithm?
    % voronoi cells for stable version of neighbor search
    voronoiCenters = [];  % centers of voronoi decomposition of nodes
    voronoiCounts  = [];  % number of nodes per voronoi center
    voronoiIndices = [];  % inidice of nodes per center as sparse logical array
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

      % MLS needs unique nodes
      if (numel(unique(nodes, 'stable', 'tolerance', .001 * degree)) < numel(nodes))
        nodes = nodes(:);
        values = reshape(values, numel(nodes), []);
        [nodes, values] = uniqueData(nodes, values, 'median','tolerance', .001 * degree);
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

      S2F.searcher = createns(nodes.xyz);

      % reshape values accordingly
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
      S2F.degree = get_option(varargin, {'degree', 'deg'}, 3, 'double');
      S2F.oF = get_option(varargin, {'oF','of', 'OF','oversamplingfactor',...
        'oversampling_factor','oversampling factor'}, 3, 'double');
      S2F.oF_max = get_option(varargin, {'ofmax','of max', 'max of', 'maxof', ...
        'maximal oversampling factor', 'max oversampling factor'}, 5, 'double');
      S2F.delta = get_option(varargin, {'delta', 'range', 'support radius'}, 0, 'double');

      % weight function, distance, symmetry
      S2F.w = get_option(varargin, 'weight', 'wendland', {'string','function_handle','char'});
      S2F.distance = get_option(varargin, 'distance', 'euclidean', 'char');
      S2F.s = get_option(varargin, {'symmetry', 'cs', 's', 'ss'}, ...
        specimenSymmetry.default, 'crystalSymmetry');

      % basis stuff
      S2F.monomials = get_option(varargin, 'monomials', true, 'logical');
      S2F.tangent = get_option(varargin, 'tangent', false, 'logical');
      S2F.centered = get_option(varargin, 'centered', true, 'logical');
      if S2F.tangent, S2F.centered = true; end
      if S2F.centered, S2F.monomials = true; end

      % regularization
      S2F.regularize = get_option(varargin, 'regularize', true, 'logical');
      S2F.maxcond = get_option(varargin, {'maxcond', 'max cond'}, 10^(S2F.degree * 6/5), 'double');
      S2F.mincond = get_option(varargin, {'mincond', 'min cond'}, 10^(S2F.degree * 1/2), 'double');
      if (S2F.degree == 0)
        S2F.maxcond = 10;
        S2F.mincond = 1;
      end
      S2F.basis_weights = get_option(varargin, {'basis_weights', 'basisweights', ...
        'basis weights'}, S2F.compute_basis_weights, 'double');

      % outlier detection
      S2F.detectOutliers = check_option(varargin, ...
        {'detect outliers', 'detectoutliers, detect_outliers'});
      S2F.outlierDetectionRange = round(get_option(varargin, ...
        {'outlierdetectionrange', 'outlier detection range', 'odr'}, 10, 'double'));

      % optimal subsampling (minimizes Lebesgue constant)
      S2F.subsample = check_option(varargin, {'subsampling', 'subsample'});
      if S2F.subsample, S2F.centered = true; end

      % stable find stuff
      S2F.stableFind = get_option(varargin, {'stablefind', 'stable find', 'stable_find'}, ...
        false, 'logical');
      % create voronoi structure to help finding neighbors in sparse regions

      % calcVoronoi may take some time, only do it if necessary
      if (S2F.stableFind)
        S2F = calcVoronoi(S2F);
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
          otherwise;          S2F.w = @(t)(max(1-t, 0).^4 .* (4*t+1));
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
  end

  % make sure nn is an integer value
  function nn = get.nn(S2F)
    nn = ceil(S2F.dim * S2F.oF);
  end

  function S2F = set.degree(S2F, deg)
    S2F.degree = deg;
    S2F.basis_weights = S2F.compute_basis_weights;
  end

  % compute weights for basis functions for regularization of lsq systems
  %   (punish higher degrees, see tools/mathtools/solve_lsq_book_constsize.m)
  % weights are between 0 (lowest degree) and 1 (highest degree)
  % they get applied in tools/math_tools/solve_lsq_book_constsize.m
  function basis_weights = compute_basis_weights(S2F)
    degrees = (0 : S2F.degree)';
    basis_weights = repelem(degrees.^2, degrees+1, 1);
    basis_weights = basis_weights / max([basis_weights; 1]) / 10;
  end

  function S2F = set.basis_weights(S2F, value)
    if (numel(value) ~= S2F.dim)
      error(['The number of elements in the basis_weights must match' ...
        'the dimension of the ansatz space.']);
    end
    value = value(:);
    % if ~(min(value) == 0 && max(value) == 1)
    % warning('The basis_weights have been shifted and scaled to [0,1]');
    % value = value - min(value);
    % value = value / max(value);
    % end
    S2F.basis_weights = value;
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

    if (numel(varargin) == 0)
      nn = full(ceil(mean(sum(ind, 2))));
      return;
    end

    if (varargin{1} == "min")
      % expected minimal number of neighbors
      nn = full(min(sum(ind,2)));
    elseif (varargin{1} == "max")
      % expected maximal number of neighbors
      nn = full(max(sum(ind,2)));
    else
      nn = full(ceil(mean(sum(ind, 2))));
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

    if (S2F.delta == 0)
      S2F.delta = S2F.compute_delta();
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

  % if stableFind option is set to true after construction, we have to construct
  %   the necessary voronoi structure for it
  function S2F = set.stableFind(S2F, value)
    if value
      S2F.stableFind = true;
      S2F.calcVoronoi;
    end
  end

  % compute voronoi structure for S2F.nodes
  function S2F = calcVoronoi(S2F, varargin)
    % numel(S2F.nodes) / N_voronoi is expected mean of nodes per voronoi cell
    % actual number of nodes per cell deviates more from this expected mean as
    %   S2F.nodes becomes non-uniformly distributed
    if (nargin == 1)
      N_voronoi = round(numel(S2F.nodes) / S2F.dim);
    else
      N_voronoi = varargin{1};
    end

    % create initial set of voronoi centers
    S2F.voronoiCenters = fibonacciS2Grid('points', N_voronoi);
    N_voronoi = numel(S2F.voronoiCenters);
    center_id = S2F.voronoiCenters.find(S2F.nodes);

    % get the centers, compute numer of neighbors per center
    N = numel(S2F.nodes);
    S2F.voronoiCounts = accumarray(center_id, 1, [N_voronoi, 1]);

    % remove unneeded voronoi centers
    empty = S2F.voronoiCounts == 0;
    N_voronoi = sum(~empty);
    S2F.voronoiCounts(empty) = [];
    S2F.voronoiCenters(empty) = [];

    % create sparse matrix where each column represents a voronoi cell and
    %   contains the indices of the nodes from S2F.nodes in this cell
    [~, idx] = sort(center_id);
    [row_idx, col_idx] = sizes2sub(S2F.voronoiCounts);
    maxcount = max(S2F.voronoiCounts);
    S2F.voronoiIndices = sparse(row_idx, col_idx, idx, ...
      maxcount, N_voronoi, sum(S2F.voronoiCounts));

    % perform lloyd centering
    S2F = lloydVoronoiCentering(S2F, 3);
  end

  % actually center the voronoiCenters within their Voronoi cell (via lloyd)
  function S2F = lloydVoronoiCentering(S2F, maxIter)
    N_voronoi = numel(S2F.voronoiCenters);
    for i = 1 : maxIter

      % 0 - assign each point to nearest center (Voronoi cell on S2)
      center_id = S2F.voronoiCenters.find(S2F.nodes);

      % 1 - choose mean of nodes of same voronoi cell as new voronoi center
      v = vector3d.zeros(N_voronoi, 1);
      v.x = accumarray(center_id, S2F.nodes.x(:), [N_voronoi, 1], @sum, 0);
      v.y = accumarray(center_id, S2F.nodes.y(:), [N_voronoi, 1], @sum, 0);
      v.z = accumarray(center_id, S2F.nodes.z(:), [N_voronoi, 1], @sum, 0);
      S2F.voronoiCenters = v.normalize;

      % 3 - remove unndeeded voronoi centers
      S2F.voronoiCounts = accumarray(center_id, 1, [N_voronoi, 1]);
      S2F.voronoiCenters(S2F.voronoiCounts == 0) = [];
      S2F.voronoiCounts(S2F.voronoiCounts == 0) = [];
      N_voronoi = numel(S2F.voronoiCenters);

      % X - re-seed empty voronoi centers to dense regions (probabilistic)
      % if any(empty)
      %   ridx = randi(N_voronoi, nnz(empty), 1);
      %   centers_new.subSet(empty) = S2F.nodes.subSet(ridx);
      % end
    end
    % create sparse matrix where each column represents a voronoi cell and
    %   contains the indices of the nodes from S2F.nodes in this cell
    center_id = S2F.voronoiCenters.find(S2F.nodes);
    [~, idx] = sort(center_id);
    [row_idx, col_idx] = sizes2sub(S2F.voronoiCounts);
    maxcount = max(S2F.voronoiCounts);
    S2F.voronoiIndices = sparse(row_idx, col_idx, idx, ...
      maxcount, N_voronoi, sum(S2F.voronoiCounts));
  end

  function fd = get.fill_distance(S2F)
    fg = fibonacciS2Grid('points', 1e6);
    [~, d] = S2F.nodes.find(fg(:), 1, 'searcher', S2F.searcher);
    fd = max(d);
  end

  function sd = get.separation_distance(S2F)
    [~, d] = S2F.nodes.find(S2F.nodes, 2, 'searcher', S2F.searcher);
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
