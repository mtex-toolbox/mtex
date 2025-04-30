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

      % apply flags in the function arguments and remove them afterwards
      alldeg_specifier_pos = find(strcmp(varargin, 'all_degrees'), 1);
      if ~isempty(alldeg_specifier_pos)
        sF.all_degrees = true;
        varargin(alldeg_specifier_pos) = [];
      end

      monomial_specifier_pos = find(strcmp(varargin, 'monomials'), 1);
      if ~isempty(monomial_specifier_pos)
        sF.monomials = true;
        varargin(monomial_specifier_pos) = [];
      end

      center_specifier_pos = find(strcmp(varargin, 'centered'), 1);
      if ~isempty(center_specifier_pos)
        sF.centered = true;
        varargin(center_specifier_pos) = [];
      end

      tangent_specifier_pos = find(strcmp(varargin, 'tangent'), 1);
      if ~isempty(tangent_specifier_pos)
        sF.tangent = true;
        % this is the same as using only even/odd centered monomials and
        % setting the z-coordinate to 1
        sF.centered = true;
        sF.monomials = true;
        varargin(tangent_specifier_pos) = [];
      end

      % if delta has not been set yet, set it now 
      if ((sF.delta == 0) && (sF.nn == 0))
        sF.delta = compute_delta(sF);
      end

      % get the weight function if one is specified
      if numel(varargin) > 0
        parser = inputParser;
        addParameter(parser, "weight", sF.w);
        parse(parser, varargin{:});
        weight_arg = string(parser.Results.weight);
        if isa(weight_arg, 'string')
          if strcmp(weight_arg, 'hat')
            sF.w = @(t)(max(1-t, 0));
          elseif  strcmp(weight_arg, 'squared hat')
            sF.w = @(t)(max(1-t, 0).^2);
          elseif strcmp(weight_arg, 'indicator')
            sF.w = @(t)(t .* (t < 1));
          end
        elseif isa(weight_arg, "function_handle")
          sF.w = parser.results.weight;
        end
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

    function d = guess_delta(sF)
      d = acos(1 - 4 * sF.dim / numel(sF.nodes));
    end

  end

end