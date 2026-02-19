classdef S2FunMLS < S2Fun
% a class representing a function on the rotation group
% 
% Syntax
%   S2F = S2FunMLS(nodes,values);
%   S2F = S2FunMLS(nodes,values, oF, 2);
%   S2F = S2FunMLS(nodes,values, delta, __);
%   S2F = S2FunMLS(nodes,values, delta, w, @(t)(__));
%   S2F = S2FunMLS(nodes,values, 'centered', 'monomials', 'subsample', 'tangent');
%   S2F = S2FunMLS(nodes, values, 'degree', 3);
%   S2F = S2FunMLS(nodes, values, 'regularize', 'stablefind', 'detectOutliers');
%
% Input
%  nodes  - @vector3d (data points)
%  values - array of function values
%
% Output
%  S2F - @S2FunMLS
%
% Options
%  degree  - the polynomial degree used for approximation
%  delta   - support radius of the weight function
%  oF      - oversampling Factor. the number of neighbors nn (dependent) is the
%              dimension of the ansatz space, times this factor
%  outlierDetectionRange - specify how many neighbors are taken into account
%                          when searching for outliers
%  w       - @function_handle (weight function)
%          - predefined weight function can be chosen via the following strings:
%             'C1hat', 'const', 'cos', 'hat', 'indicator', 'squared hat', 
%             'wendland' (default)
% distance - specify which metric to use (default: 'euclidean')
%          - run 'help rangesearch' for available options
% regularizationOptions - parameters for regularization of the lsq-systems
%                           (see /tools/math_tools/solve_lsq_book_constsize.m
%                            for more details)
% stableFindOptions     - parameters for a more stable version of find, that can
%                           deal better with highly non-uniform data
%                           (see private/find_stable.m for more details)
% 
%
% Flags
%  centered       - only evaluate the basis near the pole if true
%  detectOutliers - find outliers in the data and reduce their weight in the local least squares problems 
%                   depending on how bad they are
%  monomials      - use monomial basis isntead of spherical harmonics
%  regularize     - use regularization for solving the lsq-systems
%  stableFind     - perform stable variant of find (good for non-uniform data)
%  subsample      - use a subset of the local nodes that minimizes the lebesgue
%                   constant 
%  tangent        - use polynomials on the tangent space
%


  properties
    nodes       = []      % points where the function values are known
    values      = []      % the corresponding values

    degree      = 3       % the polynomial degree used for approximation
    delta       = 0       % support radius of the weight function
    distance    = 'euclidean'; % specify metric for neighbor search
    oF          = 2       % oversampling factor (nn / dim)
    s = crystalSymmetry;  % crystal symmetry
    w           = @(t)(max(1-t, 0).^4 .* (4*t+1)) % Wendland weight function

    oF_max      = 5;      % upper bound for oF when using rangesearch

    monomials   = true    % use monomials instead of sph. harm. if true
    centered    = false   % only evaluate the basis near the pole (0,0,1) if true
    tangent     = false   % use polynomials on the tangent space
    subsample   = false   % perform optimal subsampling, or not

    detectOutliers = false; % specify if we should search for outliers, and recude their weight
    outlierDetectionRange = 10; % number of neighbors to take into account for outlier detection

    % voronoi cells for stable version of neighbor search
    voronoiCenters = [];  % centers of voronoi decomposition of nodes
    voronoiCounts  = [];  % number of nodes per voronoi center
    voronoiIndices = [];  % inidice of nodes per center as sparse logical array

    % options and option lists
    regularize = true;
    regularizationOptions = {};
    stableFind = true;
    stableFindOptions = {};
  end

  properties (Dependent)
    antipodal   
    dim                   % dimension of the ansatz space
    nn                    % number of neighbors to take into account
    isReal
    outlierIndicators     % size as S2F.values, assigns to each node a number   
                          %   that is bigger, if the value is an outlier
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

      nodes = squeeze(nodes);
      values = squeeze(values);

      % MLS needs unique nodes
      if (numel(unique(nodes, 'stable')) < numel(nodes))
        nodes = nodes(:);
        values = reshape(values, numel(nodes), []);
        [nodes, values] = uniqueData(nodes, values, 'median');
      end

      % adapt the sizes of nodes and values to each other
      values_size = size(values);
      id = find(cumprod(size(values)) == numel(nodes), 1, 'first');
      if (id < numel(values_size))
        remaining_sizes = values_size(id+1 : end);
        values = reshape(values, [size(nodes), remaining_sizes]);
      else
        values = reshape(values, size(nodes));
      end

      % remove dimensions of size 1
      nodes = squeeze(nodes);
      % if nodes is 2D and the first dim is 1, transpose it 
      if (size(nodes, 1) == 1), nodes = transpose(nodes); end
      % assign
      S2F.nodes = nodes;

      % same as for nodes
      values = squeeze(values);
      if (size(values, 1) == 1), values = values.'; end
      S2F.values = squeeze(values);

      % set degree, number of neighbors, support radius delta,
      %   outlierDetectionRange, weight function
      S2F.degree = get_option(varargin, {'degree', 'deg'}, 3, 'double');
      S2F.oF = get_option(varargin, {'oF','of', 'OF','oversamplingfactor',...
        'oversampling_factor','oversampling factor'}, 2, 'double');

      S2F.delta = get_option(varargin, {'delta', 'range', 'support radius'}, 0, 'double');
      S2F.outlierDetectionRange = round(get_option(varargin, ...
        {'outlierdetectionrange', 'outlier detection range', 'odr'}, 10, 'double'));
      S2F.s = get_option(varargin, {'symmetry', 'cs', 's', 'ss'}, specimenSymmetry.default, 'crystalSymmetry');
      
      weightfun = get_option(varargin, 'weight', 'wendland', {'string','function_handle'});
      if (isa(weightfun, 'function_handle'))
        S2F.w = weightfun;
      else
        switch weightfun
          case 'hat';         S2F.w = @(t)(max(1-t, 0));
          case 'squared hat'; S2F.w = @(t)(max(1-t, 0).^2);
          case 'indicator';   S2F.w = @(t)(t .* (t <= 1));
          case 'const';       S2F.w = @(t)(t .* (t <= 1));
          case 'cos';         S2F.w = @(t)((1+cos(pi*t))/2);
          case 'C1hat';       S2F.w = @(t)((1-t.^2).^2);
          case 'wendland';    S2F.w = @(t)(max(1-t, 0).^4 .* (4*t+1));
          otherwise;          S2F.w = @(t)(max(1-t, 0).^4 .* (4*t+1));
        end
      end

      S2F.distance = get_option(varargin, 'distance', 'euclidean', 'char');

      % apply boolean flag arguments
      S2F.monomials = check_option(varargin, 'monomials');
      S2F.centered = check_option(varargin, 'centered');
      S2F.tangent = check_option(varargin, 'tangent');
      S2F.subsample = check_option(varargin, {'subsampling', 'subsample'});
      S2F.detectOutliers = check_option(varargin, ...
        {'detect outliers', 'detectoutliers, detect_outliers'});

      % if tangent is set to true, we must use monomials
      if (S2F.tangent == true)
        S2F.monomials = true;
      end

      S2F.s.how2plot = nodes.how2plot;

      % create voronoi structure to help finding neighbors in sparse regions
      S2F = calcVoronoi(S2F);

      % set regularization and stability options
      S2F.regularize = check_option(varargin, 'regularize');
      % set standard values
      S2F.regularizationOptions = ...
        {'Qgood', 2.5, 'Qbad', 6, 'lambdamin', 1e-14, 'lambdamax', 1e-4, ...
        'alphamin', 1, 'alphamax', 4, 'p', 2, 'q', 2, 'basis_weights', 'auto'};
      % overwrite, if options are specified as options list after regularize-flag 
      %   (last values in option list are the applied ones)
      temp = get_option(varargin, 'regularize');
      if isa(temp, 'cell')
        S2F.regularizationOptions = [S2F.regularizationOptions, temp];
      end

      % compute basis weights, if auto was selected
      if (strcmp(get_option(S2F.regularizationOptions, 'basis_weights'), 'auto'))
        basis_weights = S2F.compute_basis_weights();
        S2F.regularizationOptions = ...
          set_option(S2F.regularizationOptions, 'basis_weights', basis_weights);
      end

      S2F.stableFind = check_option(varargin, {'stablefind','stable find', 'stable_find'});
      S2F.stableFindOptions = {'nn_voronoi', 32, 'nn_min', S2F.dim, 'nn_max', S2F.nn};
      temp = get_option(varargin, 'stbablefind');
      if isa(temp, 'cell')
        S2F.stableFindOptions = [S2F.stableFindOptions, temp];
      end

    end

    % choose delta such that we get can expect factor-2-oversampling for uiid points
    function d = compute_delta(S2F)
      d = acos(1 - 4 * S2F.dim / numel(S2F.nodes));
    end

    function dimension = get.dim(S2F)
      dimension = (S2F.degree + 1) * (S2F.degree + 2) / 2;
    end

    function antipodal = get.antipodal(S2F)
      try
        antipodal = S2F.nodes.antipodal;
      catch
        antipodal = false;
      end
    end

    function S2F = set.antipodal(S2F,value)
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
    end

    % make sure nn is an integer value
    function nn = get.nn(S2F)
      nn = ceil(S2F.dim * S2F.oF);
    end

    function S2F = set.degree(S2F, deg)
      S2F.degree = deg;
      S2F.regularizationOptions = set_option(S2F.regularizationOptions, ...
        'basis_weights', S2F.compute_basis_weights);
    end

    % compute weights for basis functions for regularization of lsq systems
    %   (punish higher degrees, see tools/mathtools/solve_lsq_book_constsize.m)
    function basis_weights = compute_basis_weights(S2F)
      is_odd = logical(mod(S2F.degree, 2));
      degrees = (is_odd : 2 : S2F.degree)';
      dimensions = 2 * degrees + 1;
      basis_weights = repelem(1 + degrees, dimensions, 1);
      basis_weights = basis_weights / max([basis_weights; 1]);
    end

    % compute expected number of neighbors with given sF.nodes and sF.delta
    function nn = guess_nn(S2F, varargin)
      v = vector3d.rand(10000, 1);
      ind = S2F.nodes.find(v, S2F.delta);

      if (numel(varargin) == 0)
        nn = ceil(mean(sum(ind, 2)));
        return;
      end
      
      if (varargin{1} == "min")
        % expected minimal number of neighbors
        nn = min(sum(ind,2));
      elseif (varargin{1} == "max")
        % expected maximal number of neighbors
        nn = max(sum(ind,2));
      end
    end

    % return number of neighbors for given v (use for identifying 'bad regions')
    function nns = count_neighbors(S2F, v)
      if (S2F.delta == 0)
        S2F.delta = S2F.compute_delta();
      end
      ind = S2F.nodes.find(v, S2F.delta);
      nns = sum(ind, 2);
    end

    monomial_coefficients = get_monomial_coefficients(degs);

    function oI = get.outlierIndicators(S2F)
      oI = computeOutlierIndicators(S2F);
    end

    % important for subsref to function properly
    function n = numArgumentsFromSubscript(varargin)
      n = 0;
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
        S2F.voronoiCenters = accumarray(center_id, S2F.nodes(:), [N_voronoi, 1], @sum);
        S2F.voronoiCenters = S2F.voronoiCenters.normalize;

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
    
  end

  methods (Static = true)
    S2F = interpolate(varargin);
    S2F = approximate(f, varargin);
    S2F = example(varargin)
  end

end
