classdef halfQuadraticFilter < l1TVFilter
% obsolete, use l1TVFilter instead
%
% A constructor may not return an object of another class, so this shim
% inherits from l1TVFilter, whose default method is the half-quadratic
% minimisation this class implemented.

methods (Hidden = true)

  function F = halfQuadraticFilter(varargin)

    warning(['The syntax "halfQuadraticFilter" is obsolete. ' ...
      'Please use "l1TVFilter" instead.'])

    F = F@l1TVFilter(varargin{:});

  end
end

end
