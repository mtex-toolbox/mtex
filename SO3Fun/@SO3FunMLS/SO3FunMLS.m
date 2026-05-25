classdef SO3FunMLS < SO3Fun
% a class representing a function on the rotation group
% 
% Syntax
%   SO3F = SO3FunMLS(nodes, values);
%   SO3F = SO3FunMLS(nodes, values, 'degree', 3, 'oF', 2);
%   SO3F = SO3FunMLS(nodes, values, 'delta', 5*degree);
%   SO3F = SO3FunMLS(nodes, values, 'delta', 5*degree, 'w', @(t)(__));
%   SO3F = SO3FunMLS(nodes, values, 'centered', true, 'monomials', true, 'subsample', 'tangent', true);
%   SO3F = SO3FunMLS(nodes, values, 'regularize', false, 'stablefind', true, 'detectOutliers');
%
% Input
%  nodes  - @orientation, @rotation (data points)
%  values - array of function values assigned to the nodes
%
% Output
%  SO3F - @SO3FunMLS
%
% Options
%  degree  - the polynomial degree used for approximation
%  delta   - support radius of the weight function
%  nn      - specified number of neighbors used for local approximation
%  outlierDetectionRange - specify how many neighbors are taken into account
%                          when searching for outliers
%  w       - @function_handle (weight function)
%          - predefined weight function can be chosen via the following strings:
%             'C1hat', 'const', 'cos', 'hat', 'indicator', 'squared hat', 
%             'wendland' (default)
% distance - specify which metric to use (default: 'euclidean')
%          - run 'help rangesearch' for available options
%
% Flags
%  centered       - only evaluate the basis near the north pole (1,0,0,0) if true
%  detectOutliers - find outliers in the data and reduce their weight in the local least squares problems 
%                   depending on how bad they are
%  subsample      - use a subset of the local nodes that minimizes the Lebesgue
%                   constant 
%  tangent        - use polynomials on the tangent space
%

% TODO: transform into local interpolation-class where SO3FunMLS is a specific subclass

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
    s = crystalSymmetry.default;  % crystal symmetry

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

    bandwidth   = getMTEXpref('maxSO3Bandwidth');
  end

  properties (Dependent)
    dim                   % dimension of the ansatz space
    nn                    % number of neighbors to take into account
    antipodal             % inherited from the nodes
    isReal                % = isReal(SO3F.values)
    outlierIndicators     % same size as SO3F.values, contains for each node a 
                          %   number that is bigger, if the value is an outlier
    SLeft
    SRight

    % properties of the underlying nodes
    fill_distance         % fill distance
    separation_distance   % separation distance
  end

  % TODO: symmetrise w.r.t one symmetry.
  % TODO: use properGroups
  % TODO: use SO3Grid structure

  methods
    
    % initialize a SO(3)-function
    function SO3F = SO3FunMLS(nodes, values, varargin)
    
      if nargin == 0, return; end
    
      % convert arbitrary SO3Fun to SO3FunHarmonic
      if isa(nodes,'function_handle') || isa(nodes,'SO3Fun')
        if nargin == 1, values=[]; end
        SO3F = SO3FunMLS.approximate(nodes,values,varargin{:});
        return
      end
      
      if isa(nodes, 'rotation')
        nodes = orientation(nodes); 
      end

      % MLS needs unique nodes
      if (numel(unique(nodes, 'stable', 'tolerance', 0.01 * degree)) < numel(nodes))
        nodes = nodes(:);
        values = reshape(values, numel(nodes), []);
        [nodes, values] = uniqueData(nodes, values, 'median','tolerance',0.01*degree);
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
      SO3F.nodes = nodes;
      
      SO3F.searcher = createns(nodes.abcd);

      % reshape values accordingly 
      values_size = size(values);
      id = find(cumprod(values_size) == numel(nodes), 1, 'first');
      if (id < numel(values_size))
        remaining_sizes = values_size(id+1 : end);
        values = reshape(values, [numel(nodes), remaining_sizes]);
      else
        values = reshape(values, [numel(nodes), 1]);
      end
      SO3F.values = values;

      % set degree, (maximal) oversampling factor, support radius delta 
      SO3F.degree = get_option(varargin, {'degree', 'deg'}, 3, 'double');
      SO3F.oF = get_option(varargin, {'oF','of', 'OF','oversamplingfactor',...
        'oversampling_factor','oversampling factor'}, 3, 'double');
      SO3F.oF_max = get_option(varargin, {'ofmax','of max', 'max of', 'maxof', ...
        'maximal oversampling factor', 'max oversampling factor'}, 5, 'double');
      SO3F.delta = get_option(varargin, {'delta', 'range', 'support radius'}, 0, 'double');
      
      % weight function, distance, symmetry
      SO3F.w = get_option(varargin, 'weight', 'wendland', {'string','function_handle','char'});
      SO3F.distance = get_option(varargin, 'distance', 'euclidean', 'char');
      SO3F.s = get_option(varargin, {'symmetry', 'cs', 's', 'ss'}, ... 
        specimenSymmetry.default, 'crystalSymmetry');

      % basis stuff
      SO3F.monomials = get_option(varargin, 'monomials', true, 'logical');
      SO3F.tangent = get_option(varargin, 'tangent', false, 'logical');
      SO3F.centered = get_option(varargin, 'centered', true, 'logical');
      if (SO3F.tangent || SO3F.centered), SO3F.monomials = true; end

      % regularization
      SO3F.regularize = get_option(varargin, 'regularize', true, 'logical');
      SO3F.maxcond = get_option(varargin, {'maxcond', 'max cond'}, 10^(SO3F.degree * 3/2), 'double');
      SO3F.mincond = get_option(varargin, {'mincond', 'min cond'}, 10^(SO3F.degree * 1/2), 'double');
      if (SO3F.degree == 0) 
        SO3F.maxcond = 10; 
        SO3F.mincond = 1; 
      end
      SO3F.basis_weights = get_option(varargin, {'basis_weights', 'basisweights', ...
        'basis weights'}, SO3F.compute_basis_weights, 'double');

      % outlier detection
      SO3F.detectOutliers = check_option(varargin, ...
        {'detect outliers', 'detectoutliers, detect_outliers'});
      SO3F.outlierDetectionRange = round(get_option(varargin, ...
        {'outlierdetectionrange', 'outlier detection range', 'odr'}, 10, 'double'));

      % optimal subsampling (minimizes Lebesgue constant)
      SO3F.subsample = check_option(varargin, {'subsampling', 'subsample'});

    end

    function SO3F = set.w(SO3F, weightfun)
      if (isa(weightfun, 'function_handle'))
        SO3F.w = weightfun;
      else
        switch weightfun
          case 'hat';         SO3F.w = @(t)(max(1-t, 0));
          case 'squared hat'; SO3F.w = @(t)(max(1-t, 0).^2);
          case 'indicator';   SO3F.w = @(t)(t <= 1);
          case 'const';       SO3F.w = @(t)(t <= 1);
          case 'cos';         SO3F.w = @(t)((1+cos(pi*t))/2);
          case 'C1hat';       SO3F.w = @(t)((1-t.^2).^2);
          case 'wendland';    SO3F.w = @(t)(max(1-t, 0).^4 .* (4*t+1));
          otherwise;          SO3F.w = @(t)(max(1-t, 0).^4 .* (4*t+1));
        end
      end
    end

    % choose delta such that we get can expect factor-oF-oversampling for uiid points
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
      syms phi;
      d = double(vpasolve(phi - sin(phi) * cos(phi) - ...
        pi / 2 * SO3F.nn / numel(SO3F.nodes) / symmetry_factor));
      % the quaterion distance is twice the spherical distance
      d = 2 * d;
    end

    function dimension = get.dim(SO3F)
      dimension = nchoosek(SO3F.degree + 3, 3);
    end

    % if only delta is specified, guess nn for this delta
    function nn = guess_nn(SO3F, varargin)
      if (SO3F.delta == 0)
        nn = SO3F.nn;
        warning(['Calling this function only makes sense if range-search is acitvated. ' ...
          'You can achieve this for example via SO3F.delta = SO3F.compute_delta. ' ...
          'I just returned SO3F.nn for now.']);
        return;
      end

      testnodes = equispacedSO3Grid(SO3F.nodes.CS, SO3F.nodes.SS, 'points', 10000);
      ind = SO3F.nodes.find(testnodes, SO3F.delta);
      if (numel(varargin) == 0)
        nn = full(ceil(mean(sum(ind, 2))));
        return;
      end
      if (varargin{1} == "min")
        nn = full(floor(min(sum(ind, 2))));
      elseif (varargin{1} == "max")
        nn = full(ceil(max(sum(ind, 2))));
      else 
        nn = full(ceil(mean(sum(ind, 2))));
      end
    end

    % return number of neighbors for given ori (use for identifying 'bad regions')
    function nns = count_neighbors(SO3F, ori)
      if (SO3F.delta == 0)
        nns = repmat(SO3F.nn, size(ori));
        warning(['Calling this function only makes sense if range-search is acitvated. ' ...
          'You can achieve this for example via SO3F.delta = SO3F.compute_delta. ' ...
          'I just returned SO3F.nn for now.']);
        return;
      end

      if (SO3F.delta == 0)
        SO3F.delta = SO3F.compute_delta();
      end
      ind = SO3F.nodes.find(ori, SO3F.delta);
      nns = full(sum(ind, 2));
    end


    function SO3F = set.SRight(SO3F,S)
      SO3F.nodes.CS = S;
    end

    function S = get.SRight(SO3F)
      S = SO3F.nodes.CS;
    end

    function SO3F = set.SLeft(SO3F,S)
      SO3F.nodes.SS = S;
    end

    function S = get.SLeft(SO3F)
      S = SO3F.nodes.SS;
    end

    function SO3F = set.antipodal(SO3F, antipodal)
      SO3F.nodes.antipodal = antipodal;
    end

    function antipodal = get.antipodal(SO3F)
      antipodal = SO3F.nodes.antipodal;
    end

    function SO3F = set.detectOutliers(SO3F, value)
      SO3F.detectOutliers = value;
      if (value)
        % set standard value of outlier detection range
        % should be at least 4, since this is the dim of the basis which is used
        % for computing the outlier indicators
        SO3F.outlierDetectionRange = max(round(SO3F.dim * .7), 4);
      end
    end

    % subsampling needs monomial basis, since linprog need real sampling matrix
    function SO3F = set.subsample(SO3F, value)
      SO3F.subsample = value;
      if (value == true)
        SO3F.monomials = true;
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
      if (value < 1)
        warning('Oversampling factor was too small and has been set to 2.');
        value = 2;
      end
      SO3F.oF = value;
      if (SO3F.delta > 0)
        warning('The support radius delta has been adopted to the new oversampling Factor');
        SO3F.delta = SO3F.compute_delta;
      end
    end

    % make sure nn is an integer value
    function nn = get.nn(SO3F)
      nn = ceil(SO3F.dim * SO3F.oF);
    end

    function SO3F = set.degree(SO3F, deg)
      SO3F.degree = deg;
      SO3F.basis_weights = SO3F.compute_basis_weights;
    end

    % compute weights for basis functions for regularization of lsq systems
    %   (punish higher degrees, see tools/mathtools/solve_lsq_book_constsize.m)
    % weights are between 0 (lowest degree) and 1 (highest degree)
    % they get applied in tools/math_tools/solve_lsq_book_constsize.m
    function basis_weights = compute_basis_weights(SO3F)
      degrees = (0 : SO3F.degree)';
      dimensions = (degrees + 1) .* (degrees + 2) / 2;
      basis_weights = repelem(degrees.^2, dimensions, 1);
      basis_weights = basis_weights / max([basis_weights; 1]) / 10;
    end

    function SO3F = set.basis_weights(SO3F, value)
      if (numel(value) ~= SO3F.dim)
        error(['The number of elements in the basis_weights must match' ...
          'the dimension of the ansatz space.']);
      end
      value = value(:);
      % if ~(min(value) == 0 && max(value) == 1)
        % warning('The basis_weights have been shifted and scaled to [0,1]');
        % value = value - min(value);
        % value = value / max(value);
      % end
      SO3F.basis_weights = value;
    end

    % tangent need centered
    function SO3F = set.tangent(SO3F, value)
      SO3F.tangent = value;
      if (value == true)
        SO3F.centered = true;
      end
    end

    function n = numArgumentsFromSubscript(varargin)
      n = 0;
    end

    function oI = get.outlierIndicators(SO3F)
      oI = computeOutlierIndicators(SO3F);
    end

    function fd = get.fill_distance(SO3F)
      % eg = equispacedSO3Grid(SO3F.nodes.CS, SO3F.nodes.SS, 'resolution', 3*degree);
      % [~, d] = SO3F.nodes.find(eg(:), 1, 'searcher', SO3F.searcher);
      % fd = max(d);
      
      f = SO3FunHandle(@(r) funDist(r,SO3F),SO3F.CS,SO3F.SS);
      acc = 0.25*degree;
      d = max(f,'accuracy',acc,'numLocal',20,'resolution',3*degree);
      fd = max(d);

    end

    function sd = get.separation_distance(SO3F)
      [~, d] = SO3F.nodes.find(SO3F.nodes, 2, 'searcher', SO3F.searcher);
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






%% Additional Functions
function d = funDist(modes,mls)
  [~, d] = mls.nodes.find(modes(:), 1, 'searcher', mls.searcher);
  d = reshape(d,size(modes));
end