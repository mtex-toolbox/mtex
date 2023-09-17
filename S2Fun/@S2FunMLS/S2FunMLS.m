classdef S2FunMLS < S2Fun
  % a class representing a function on the sphere

  properties
    nodes     = [];   % points where the function values are known
    values    = [];   % the corresponding values
    degree    = 2;    % the polynomial degree used for approximation
    delta     = 0;    % support radius of the weight function
    w         = @(t)(max(1-t, 0).^4 .* (4*t+1)); % wendland weight function
    all_degrees = false;  % use even AND odd degrees up to degree if true
    monomials = false;    % use monomials instead of sph. harm. if true
    centered = false;     % only evaluate the basis near the pole if true
  end

  methods
    % initialize a spherical function
    function sF = S2FunMLS(nodes, values, varargin)
      % set the mandatory inputs
      % some grids in mtex are provided as row vectors 
      if size(nodes, 1) > size(nodes, 2) 
        sF.nodes = nodes;
      else 
        sF.nodes = nodes';
      end
      sF.values = values;

      % set degree if given
      if nargin >= 3 && isnumeric(varargin{1})
        sF.degree = varargin{1};
        varargin(1) = [];
      end
      % set delta if given
      if nargin >= 4 && isnumeric(varargin{1})
        sF.delta = varargin{1};
        varargin(1) = [];
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

      % if delta has not been set yet, set it now 
      if sF.delta == 0
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

    end

    % compute delta if none was specified
    function delta = compute_delta(sF)
      if sF.all_degrees
        dim = (sF.degree + 1)^2;
      else
        dim = (sF.degree + 1) * (sF.degree + 2) / 2;
      end
      % compute the smallest delta such that 2.5*dim spherical caps with
      % radius resolution/2 fit into one spherical cap with radius delta
      delta = acos(max(1 - 2.5*dim*(1 - cos(sF.nodes.resolution/2)), -1));
    end

  end

end
