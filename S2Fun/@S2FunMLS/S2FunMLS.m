classdef S2FunMLS < S2Fun
  % a class representing a function on the sphere

  properties
    nodes       = [];      % points where the function values are known
    values      = [];      % the corresponding values
    degree      = 3;       % the polynomial degree used for approximation
    delta       = 0;       % support radius of the weight function
    nn          = 0;       % specified number of neighbors to use 
    w           = @(t)(max(1-t, 0).^4 .* (4*t+1)); % wendland weight function
    all_degrees = false;   % use even AND odd degrees up to degree if true
    monomials   = true;    % use monomials instead of sph. harm. if true
    centered    = false;   % only evaluate the basis near the pole if true
    tangent     = false;   % use polynomials on the tangent space
    s           = crystalSymmetry('1');   % TODO: symmetry
  end

  properties (Dependent)
    dim;
    antipodal
  end

  methods
    % initialize a spherical function
    function sF = S2FunMLS(nodes, values, varargin)
      % set the mandatory inputs
      % some grids in mtex are provided as row vectors 
      if size(nodes, 1) < size(nodes, 2) 
        nodes = nodes';
      end
      sF.nodes = nodes;
      sF.values = values;

      % set degree if given
      if nargin >= 3 && isnumeric(varargin{1})
        sF.degree = varargin{1};
        varargin(1) = [];
      end
      % set delta or k if given
      if nargin >= 4 && isnumeric(varargin{1})
        temp = varargin{1};
        % if the input is a whole number, assume that nn is specified
        if (floor(temp) == temp)
          sF.nn = temp;
        else
          sF.delta = temp;
        end
        varargin(1) = [];
      % otherwise set k = 2 * dim
      else
        sF.nn = 2 * sF.dim;
      end

      % apply boolean flag arguments
      sF.all_degrees = get_option(varargin, 'all_degrees', false, 'logical');
      sF.monomials = get_option(varargin, 'monomials', true, 'logical');
      sF.centered = get_option(varargin, 'centered', false, 'logical');
      sF.tangent = get_option(varargin, 'tangent', false, 'logical');

      % if tanget is set to true, we must use monomials
      if (sF.tangent == true)
        sF.monomials = true;
      end

      % if delta has not been set yet, set it now 
      if ((sF.delta == 0) && (sF.nn == 0))
        sF.delta = compute_delta(sF);
      end

      weight = get_option(varargin, 'weight');
      if (isa(weight, 'function_handle'))
        sF.w = weight;
      elseif (isa(weight, 'string'))
        if strcmp(weight_arg, 'hat')
          sF.w = @(t)(max(1-t, 0));
        elseif  strcmp(weight_arg, 'squared hat')
          sF.w = @(t)(max(1-t, 0).^2);
        elseif strcmp(weight_arg, 'indicator')
          sF.w = @(t)(t .* (t < 1));
        end
      else
        sF.w = @(t)(max(1-t, 0).^4 .* (4*t+1));
      end
  
      if (sF.nn < sF.dim)
        sF.nn = 2 * sF.dim;
        warning(sprintf(...
          ['The specified number of neighbors nn was less than the dimension dim.\n\t ' ...
          'nn has been set to 2 * dim.']));
      end

      if (sF.delta == 0)
        sF.delta = guess_delta(sF);
      end

    end

    % compute delta if none was specified
    function delta = compute_delta(sF)
      % compute the smallest delta such that 2.5*dim spherical caps with
      % radius resolution/2 fit into one spherical cap with radius delta
      delta = acos(max(1 - 2.5*sF.dim*(1 - cos(sF.nodes.resolution/2)), -1));
    end

    function dimension = get.dim(sF)
      if (sF.all_degrees == true)
        dimension = (sF.degree + 1)^2;
      else
        dimension = (sF.degree + 1) * (sF.degree + 2) / 2;
      end
    end

    function antipodal = get.antipodal(SO3F)
      try
        antipodal = SO3F.nodes.antipodal;
      catch
        antipodal = false;
      end
    end

    function d = guess_delta(sF)
      d = acos(1 - 4 * sF.dim / numel(sF.nodes));
    end

  end

end