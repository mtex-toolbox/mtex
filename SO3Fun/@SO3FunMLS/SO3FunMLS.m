classdef SO3FunMLS < SO3Fun
% a class representing a function on the rotation group
% Syntax
%   SO3F = SO3FunMLS(nodes,values)
%   SO3F = SO3FunMLS(nodes,values,N,__)
%   SO3F = SO3FunMLS(nodes,values,eps,__)
%   SO3F = SO3FunMLS(nodes,values,eps,w,__)
%
% Input
%  nodes  - @orientation,@rotation (interpolation points)
%  values - array of function values
%  N      - specified number of neighbors used for local interpolation
%  eps    - support radius of the weight function
%  w      - @function_handle (weight function)
%
% Output
%  SO3F - @SO3FunMLS
%
% Options
%  degree - the polynomial degree used for approximation
%
% Flags
%  all_degrees  - use even AND odd degrees up to degree if true
%  centered     - only evaluate the basis near the pole if true
%  tangent      - use polynomials on the tangent space
%  hat          - use hat function as weight function
%  squared_hat  - use squared-hat function as weight function
%  indicator    - use indicator function as weight function
%

% TODO: transform into local interpolation-class where SO3FunMLS is a specific subclass

  properties
    nodes       = [];   % orientations where the function values are known
    values      = [];   % the corresponding values
    degree      = 3     % the polynomial degree used for approximation
    delta       = 0     % support radius of the weight function
    nn          = 0     % specified number of neighbors to use 
    w           = @(t)(max(1-t, 0).^4 .* (4*t+1));        % wendland weight function
    all_degrees = false % use even AND odd degrees up to degree if true
    centered    = false % only evaluate the basis near the pole if true
    tangent     = false % use polynomials on the tangent space
    bandwidth   = getMTEXpref('maxSO3Bandwidth');
  end

  properties (Dependent)
    dim;
    antipodal
    SLeft
    SRight
  end

  methods
    
    function SO3F = SO3FunMLS(nodes, values, varargin)

      if nargin == 0, return; end
 
      SO3F.nodes = nodes; % preserve grid structure
      sz = size(values);
      SO3F.values = reshape(values , [length(nodes) , sz(find(cumprod(sz)==length(nodes), 1)+1:end)] );

      % set optional arguments
      SO3F.degree = get_option(varargin,'degree',3);
      
      % apply flags in the function arguments and remove them afterwards
      SO3F.all_degrees = check_option(varargin,'all_degrees');
      SO3F.centered = check_option(varargin,'centered');
      if check_option(varargin,'tangent')
        SO3F.tangent = true;
        SO3F.centered = true;
      end

      % get the weight function if one is specified
      fun = getClass(varargin,'function_handle');
      if ~isempty(fun)
        SO3F.w = fun;
      elseif check_option(varargin,'hat')
        SO3F.w = @(t)(max(1-t, 0));
      elseif check_option(varargin,'squared hat')
        SO3F.w = @(t)(max(1-t, 0).^2);
      elseif check_option(varargin,'indicator')
        SO3F.w = @(t)(t .* (t < 1));
      end

      % set delta or k if given
      if nargin > 2 && isnumeric(varargin{1})
        temp = varargin{1};
      else
        temp = 2 * SO3F.dim;
      end
      % if the input is a whole number, assume that nn is specified
      if (floor(temp) == temp)
        if (temp < SO3F.dim)
          warning('The specified number of neighbors nn was less than the dimension dim. nn has been set to 2 * dim.');
          SO3F.nn = 2*SO3F.dim;
        else 
          SO3F.nn = temp;
        end
        SO3F.delta = guess_delta(SO3F);
      else
        SO3F.nn = 2 * SO3F.dim;
        SO3F.delta = temp;
      end
      
    end

    function dimension = get.dim(SO3F)
      if (SO3F.all_degrees == true)
        dimension = nchoosek(SO3F.degree + 3, 3) + nchoosek(SO3F.degree + 2, 3);
      else
        dimension = nchoosek(SO3F.degree + 3, 3);
      end
    end

    function d = guess_delta(SO3F)
      % for N nodes on one hemisphere, the expected number of nodes in a
      % spherical cap of angular radius phi is
      %         N * 2/pi * (phi - sin(phi) * cos(phi))
      % choose delta such that the expected number of neighbors is 2*sF.dim
      syms phi;
      d = double(vpasolve(phi-sin(phi)*cos(phi) - pi*SO3F.dim/numel(SO3F.nodes)));
      % the quaterion distance is twice the spherical distance
      d = 2 * d;
    end

    function SO3F = set.SRight(SO3F,S)
      SO3F.nodes.CS = S;
    end

    function S = get.SRight(SO3F)
      try
        S = SO3F.nodes.CS;
      catch
        S = specimenSymmetry;
      end
    end

    function SO3F = set.SLeft(SO3F,S)
      SO3F.nodes.SS = S;
    end

    function S = get.SLeft(SO3F)
      try
        S = SO3F.nodes.SS;
      catch
        S = specimenSymmetry;
      end
    end

    function SO3F = set.antipodal(SO3F,antipodal)
      SO3F.nodes.antipodal = antipodal;
    end

    function antipodal = get.antipodal(SO3F)
      try
        antipodal = SO3F.nodes.antipodal;
      catch
        antipodal = false;
      end
    end

    function n = numArgumentsFromSubscript(varargin)
      n = 0;
    end

  end

end
