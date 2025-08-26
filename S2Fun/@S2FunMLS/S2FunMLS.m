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
    dim
    antipodal
  end

  methods
    % initialize a spherical function
    function S2F = S2FunMLS(nodes, values, varargin)
      % initialize a S2-valued function

      if nargin == 0, return; end

      % convert arbitrary S2Fun to S2FunHarmonic
      if isa(nodes,'function_handle') || isa(nodes,'S2Fun')
        if nargin == 1, values=[]; end
        S2F = S2FunMLS.approximate(nodes,values,varargin{:});
        return
      end

      % preserve grid structure
      S2F.nodes = nodes;
      sz = [size(values), 1];
      S2F.values = reshape(values(:) , [length(nodes) , sz(find(cumprod(sz)==length(nodes), 1)+1:end)] );

      % set degree if given
      if nargin >= 3 && isnumeric(varargin{1})
        S2F.degree = varargin{1};
        varargin(1) = [];
      end
      % set delta or k if given
      if nargin >= 4 && isnumeric(varargin{1})
        temp = varargin{1};
        % if the input is a whole number, assume that nn is specified
        if (floor(temp) == temp)
          S2F.nn = temp;
        else
          S2F.delta = temp;
        end
        varargin(1) = [];
      % otherwise set k = 2 * dim
      else
        S2F.nn = 2 * S2F.dim;
      end

      S2F.s = get_option(varargin, 'symmetry', crystalSymmetry('1'), 'crystalSymmetry');

      % apply boolean flag arguments
      S2F.all_degrees = get_option(varargin, 'all_degrees', false, 'logical');
      S2F.monomials = get_option(varargin, 'monomials', true, 'logical');
      S2F.centered = get_option(varargin, 'centered', false, 'logical');
      S2F.tangent = get_option(varargin, 'tangent', false, 'logical');


      % if tanget is set to true, we must use monomials
      if (S2F.tangent == true)
        S2F.monomials = true;
      end

      % if delta has not been set yet, set it now 
      if ((S2F.delta == 0) && (S2F.nn == 0))
        S2F.delta = compute_delta(S2F);
      end

      weight = get_option(varargin, 'weight');
      if (isa(weight, 'function_handle'))
        S2F.w = weight;
      elseif (isa(weight, 'string'))
        if strcmp(weight_arg, 'hat')
          S2F.w = @(t)(max(1-t, 0));
        elseif  strcmp(weight_arg, 'squared hat')
          S2F.w = @(t)(max(1-t, 0).^2);
        elseif strcmp(weight_arg, 'indicator')
          S2F.w = @(t)(t .* (t < 1));
        end
      else
        S2F.w = @(t)(max(1-t, 0).^4 .* (4*t+1));
      end
  
      if (S2F.nn < S2F.dim)
        S2F.nn = 2 * S2F.dim;
        warning(sprintf(...
          ['The specified number of neighbors nn was less than the dimension dim.\n\t ' ...
          'nn has been set to 2 * dim.']));
      end

      if (S2F.delta == 0)
        S2F.delta = guess_delta(S2F);
      end

    end

    % compute delta if none was specified
    function delta = compute_delta(S2F)
      % compute the smallest delta such that 2.5*dim spherical caps with
      % radius resolution/2 fit into one spherical cap with radius delta
      delta = acos(max(1 - 2.5*S2F.dim*(1 - cos(S2F.nodes.resolution/2)), -1));
    end

    function dimension = get.dim(S2F)
      if (S2F.all_degrees == true)
        dimension = (S2F.degree + 1)^2;
      else
        dimension = (S2F.degree + 1) * (S2F.degree + 2) / 2;
      end
    end

    function antipodal = get.antipodal(S2F)
      try
        antipodal = S2F.nodes.antipodal;
      catch
        antipodal = false;
      end
    end

    function d = guess_delta(S2F)
      d = acos(1 - 4 * S2F.dim / numel(S2F.nodes));
    end

  end

  methods (Static = true)
    S2F = interpolate(varargin);
    S2F = approximate(f, varargin);
  end

end