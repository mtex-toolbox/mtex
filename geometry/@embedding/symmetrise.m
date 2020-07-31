function symObj = symmetrise(obj)
% symmetrise embedding
%
% Syntax
%
%   symE = symmetrise(e)
%
% Input
%  e - @embedding
%
% Output
%  symE - @embedding invariant with respect to all symmetry elements
%
      
symObj = mean( rotate_outer(obj, obj.CS.properGroup.rot),1);
symObj = reshape(symObj, size(obj));

end