classdef SO3FunMLS < SO3Fun
% a class representing a function on the rotation group
% 
% Syntax
%   SO3F = SO3FunMLS(nodes,values)
%   SO3F = SO3FunMLS(nodes,values, nn, __)
%   SO3F = SO3FunMLS(nodes,values, delta, __)
%   SO3F = SO3FunMLS(nodes,values, delta, w, @(t)(__))
%   SO3F = SO3FunMLS(nodes,values, 'centered', 'detectOutliers', 'subsample', 'tangent')
%
% Input
%  nodes  - @orientation, @rotation (data points)
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
%  centered       - only evaluate the basis near the north pole (1,0,0,0) if true
%  detectOutliers - find outliers in the data and reduce their weight in the local least squares problems 
%                   depending on how bad they are
%  subsample      - use a subset of the local nodes that minimizes the Lebesgue
%                   constant 
%  tangent        - use polynomials on the tangent space
%

% TODO: transform into local interpolation-class where SO3FunMLS is a specific subclass

  properties
    nodes       = [];   % orientations where the function values are known
    values      = [];   % the corresponding values

    degree      = 3     % the polynomial degree used for approximation
    delta       = 0     % support radius of the weight function
    nn          = 0     % specified number of neighbors to use 
    w           = @(t)(max(1-t, 0).^4 .* (4*t+1)); % wendland weight function

    centered    = false % only evaluate the basis near the pole if true
    tangent     = false % use polynomials on the tangent space
    subsample   = false % perform optimal subsampling, or not

    detectOutliers = false; % specify if we should search for outliers, and reduce their weight
    outlierDetectionRange = 10; % number of neighbors to take into account for outlier detection

    bandwidth   = getMTEXpref('maxSO3Bandwidth');
  end

  properties (Dependent)
    antipodal
    dim
    isReal
    outlierIndicators
    SLeft
    SRight
  end

  % TODO: symmetrise w.r.t one symmetry.
  % TODO: use properGroups
  % TODO: use SO3Grid structure

  methods
    
    function SO3F = SO3FunMLS(nodes, values, varargin)
    % initialize a SO(3)-valued function
    
      if nargin == 0, return; end
    
      % convert arbitrary SO3Fun to SO3FunHarmonic
      if isa(nodes,'function_handle') || isa(nodes,'SO3Fun')
        if nargin == 1, values=[]; end
        SO3F = SO3FunMLS.approximate(nodes,values,varargin{:});
        return
      end

      nodes = orientation(nodes);

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
      SO3F.nodes = nodes;

      % same as for nodes
      values = squeeze(values);
      if (size(values, 1) == 1), values = values.'; end
      SO3F.values = squeeze(values);

      % set degree, number of neighbors, support radius delta,
      %   outlierDetectionRange, weight function
      SO3F.degree = get_option(varargin, 'degree', 3, 'double');
      SO3F.nn = round(get_option(varargin, {'neighbors', 'nn'}, 2*SO3F.dim, 'double'));
      if (SO3F.nn < SO3F.dim)
        SO3F.nn = 2 * SO3F.dim;
        warning(sprintf(...
          ['The specified number of neighbors was less than the dimension ' ...
          'of the ansatz space.\n\t It has been set to 2 times the dimension.']));
      end
      SO3F.delta = get_option(varargin, {'delta', 'range', 'support radius'}, compute_delta(SO3F), 'double');
      SO3F.outlierDetectionRange = round(get_option(varargin, ...
        {'outlierdetectionrange', 'outlier detection range', 'odr'}, 10, 'double'));

      % set the weight function 
      weightfun = get_option(varargin, 'weight', 'wendland', {'string','function_handle'});
      if (isa(weightfun, 'function_handle'))
        SO3F.w = weightfun;
      else
        switch weightfun
          case 'hat';         SO3F.w = @(t)(max(1-t, 0));
          case 'squared hat'; SO3F.w = @(t)(max(1-t, 0).^2);
          case 'indicator';   SO3F.w = @(t)(t .* (t <= 1));
          case 'const';       SO3F.w = @(t)(t .* (t <= 1));
          case 'cos';         SO3F.w = @(t)((1+cos(pi*t))/2);
          case 'C1hat';       SO3F.w = @(t)((1-t.^2).^2);
          case 'wendland';    SO3F.w = @(t)(max(1-t, 0).^4 .* (4*t+1));
          otherwise;          SO3F.w = @(t)(max(1-t, 0).^4 .* (4*t+1));
        end
      end

      % apply boolean flag arguments
      SO3F.centered = check_option(varargin, 'centered');
      SO3F.tangent = check_option(varargin, 'tangent');
      SO3F.subsample = check_option(varargin, {'subsampling', 'subsample'});
      SO3F.detectOutliers = check_option(varargin, ...
        {'detect outliers', 'detectoutliers, detect_outliers'});

    end

    % choose delta such that we get can expect factor-2-oversampling for uiid points
    function d = compute_delta(SO3F)
      % for N nodes on one hemisphere, the expected number of nodes in a
      % spherical cap of angular radius phi is
      %         N * 2/pi * (phi - sin(phi) * cos(phi))
      % choose delta such that the expected number of neighbors is 2*sF.dim
      syms phi;
      d = double(vpasolve(phi-sin(phi)*cos(phi) - pi*SO3F.dim/numel(SO3F.nodes)));
      % the quaterion distance is twice the spherical distance
      d = 2 * d;
    end

    function dimension = get.dim(SO3F)
      if (SO3F.degree == 0)
        dimension = 1;
        return;
      end
      dimension = nchoosek(SO3F.degree + 3, 3);
    end

    % if only delta is specified, guess nn for this delta
    function nn = guess_nn(SO3F, varargin)
      testnodes = equispacedSO3Grid(SO3F.nodes.CS, 'points', 1000);
      ind = SO3F.nodes.find(testnodes, SO3F.delta);
      if (numel(varargin) == 0)
        nn = ceil(mean(sum(ind, 2)));
        return;
      end
      if (varargin{1} == "min")
        nn = floor(min(sum(ind, 2)));
      elseif (varargin{1} == "max")
        nn = ceil(max(sum(ind, 2)));
      end
    end

    % return number of neighbors for given v (use for identifying 'bad regions')
    function nns = count_neighbors(SO3F, ori)
      if (SO3F.delta == 0)
        SO3F.delta = SO3F.compute_delta();
      end
      ind = SO3F.nodes.find(ori, SO3F.delta);
      nns = sum(ind, 2);
    end


    function SO3F = set.SRight(SO3F,S)
      SO3F.nodes.CS = S;
    end

    function S = get.SRight(SO3F)
      try
        S = SO3F.nodes.CS;
      catch
        S = specimenSymmetry.default;
      end
    end

    function SO3F = set.SLeft(SO3F,S)
      SO3F.nodes.SS = S;
    end

    function S = get.SLeft(SO3F)
      try
        S = SO3F.nodes.SS;
      catch
        S = specimenSymmetry.default;
      end
    end

    function SO3F = set.antipodal(SO3F, antipodal)
      SO3F.nodes.antipodal = antipodal;
    end

    function antipodal = get.antipodal(SO3F)
      try
        antipodal = SO3F.nodes.antipodal;
      catch
        antipodal = false;
      end
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

    function out = get.isReal(f)
      out = isreal(f.values);
    end
  
    function F = set.isReal(F,value)
      if ~value, return; end
      F.values = real(F.values);
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

  end

  methods (Static = true)
    SO3F = interpolate(varargin);
    SO3F = approximate(f, varargin);
    SO3F = example(varargin)
  end
  
end
