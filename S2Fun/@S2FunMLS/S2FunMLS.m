classdef S2FunMLS < S2Fun
% a class representing a function on the rotation group
% 
% Syntax
%   S2F = S2FunMLS(nodes,values)
%   S2F = S2FunMLS(nodes,values, nn, __)
%   S2F = S2FunMLS(nodes,values, delta, __)
%   S2F = S2FunMLS(nodes,values, delta, w, @(t)(__))
%   S2F = S2FunMLS(nodes,values, 'centered', 'detectOutliers', 'monomials', 'subsample', 'tangent')
%
% Input
%  nodes  - @orientation,@rotation (interpolation points)
%  values - array of function values
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
%  centered       - only evaluate the basis near the pole if true
%  detectOutliers - find outliers in the data and reduce their weight in the local least squares problems 
%                   depending on how bad they are
%  monomials      - use monomial basis isntead of spherical harmonics
%  subsample      - use a subset of the local nodes that minimizes the lebesgue
%                   constant 
%  tangent        - use polynomials on the tangent space
%


  properties
    nodes       = []      % points where the function values are known
    values      = []      % the corresponding values
    degree      = 3       % the polynomial degree used for approximation
    delta       = 0       % support radius of the weight function
    nn          = 0       % specified number of neighbors to use 
    w           = @(t)(max(1-t, 0).^4 .* (4*t+1)) % Wendland weight function
    monomials   = true    % use monomials instead of sph. harm. if true
    centered    = false   % only evaluate the basis near the pole if true
    tangent     = false   % use polynomials on the tangent space
    subsample   = false   % perform optimal subsampling, or not
    distance    = 'euclidean';

    s = crystalSymmetry(); % crystal symmetry

    detectOutliers = false;
    outlierDetectionRange = 10; % number of neighbors to take into account for outlier detection
  end

  properties (Dependent)
    dim
    antipodal
    isReal
    outlierIndicators
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

      % properly extract the size of the S2FunMLS
      % this is given by the size of the values-array for each node
      % we obtain it by removing the entries of size(nodes) from size(values)
      nodes_size = size(nodes);
      nodes_dim = numel(nodes_size);
      if (ismember(numel(nodes), nodes_size))
        nodes_dim = 1;
      end
      values_size = size(values);
      values_size = values_size(nodes_dim+1 : end);

      % remove nodes that occur more than once, and also remove the
      % corresponding values
      [nodes, values] = uniqueData(nodes,values);
      values = reshape(values, [numel(nodes), values_size]);

      % preserve grid structure
      S2F.nodes = nodes;
      sz = [size(values), 1];
      S2F.values = reshape(values(:) , [length(nodes) , sz(find(cumprod(sz)==length(nodes), 1)+1:end)] );

      % set degree, number of neighbors, support radius delta,
      %   outlierDetectionRange, weight function
      S2F.degree = get_option(varargin, {'degree', 'deg'}, 3, 'double');
      S2F.nn = round(get_option(varargin, {'neighbors', 'nn'}, 2*S2F.dim, 'double'));
      if (S2F.nn < S2F.dim)
        S2F.nn = 2 * S2F.dim;
        warning(sprintf(...
          ['The specified number of neighbors was less than the dimension ' ...
          'of the ansatz space.\n\t It has been set to 2 times the dimension.']));
      end
      S2F.delta = get_option(varargin, {'delta', 'range', 'support radius'}, compute_delta(S2F), 'double');
      S2F.outlierDetectionRange = roudn(get_option(varargin, ...
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
      S2F.monomials = check_option(varargin, 'monomials', 'logical');
      S2F.centered = check_option(varargin, 'centered', 'logical');
      S2F.tangent = check_option(varargin, 'tangent', 'logical');
      S2F.subsample = check_option(varargin, {'subsampling', 'subsample'}, 'logical');
      S2F.detectOutliers = check_option(varargin, ...
        {'detect outliers', 'detectoutliers, detect_outliers'}, 'logical');

      % if tangent is set to true, we must use monomials
      if (S2F.tangent == true)
        S2F.monomials = true;
      end

      if (S2F.delta == 0)
        S2F.delta = guess_delta(S2F);
      end

      S2F.s.how2plot = nodes.how2plot;

    end

    % important for subsref to function properly
    function n = numArgumentsFromSubscript(varargin)
      n = 0;
    end

    % compute delta if none was specified
    function delta = compute_delta(S2F)
      % compute the smallest delta such that 2.5*dim spherical caps with
      % radius resolution/2 fit into one spherical cap with radius delta
      delta = acos(max(1 - 2.5*S2F.dim*(1 - cos(S2F.nodes.resolution/2)), -1));
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

    % subsampling needs monomial basis, since linprog need real sampling matrix
    function S2F = set.subsample(S2F, value)
      S2F.subsample = value;
      if (value == true)
        S2F.monomials = true;
      end
    end

    % tangent need centered
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

    % make sure nn is an integer value
    function S2F = set.nn(S2F, value)
      if (value > 0 && value < S2F.dim)
        error('Invalid value! The number of neighbors must be an integer >= sF.dim.'); 
      end
      S2F.nn = round(value);
    end

    function S2F = set.degree(S2F, deg)
      S2F.degree = deg;
      S2F.nn = 2 * S2F.dim;
    end

    % choose delta such that 2-oversampling in expectation for uiid points
    function d = guess_delta(S2F)
      d = acos(1 - 4 * S2F.dim / numel(S2F.nodes));
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

    % outlierIndicators = computeOutlierIndicators(S2F, k);
    function oI = get.outlierIndicators(S2F)
      oI = computeOutlierIndicators(S2F);
    end

  end

  methods (Static = true)
    S2F = interpolate(varargin);
    S2F = approximate(f, varargin);
    S2F = example(varargin)
  end

end
