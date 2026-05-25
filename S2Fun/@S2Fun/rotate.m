function sF = rotate(sF, rot)
% rotate a function by a rotation
%
% Syntax
%   sF = sF.rotate(rot)
%
% Input
%  sF - @S2Fun
%  rot - @rotation
%
% Output 
%  sF - @S2Fun
%

% check for matching reference frames
if isa(rot,"orientation") && sF.s ~= rot.CS
  warning('possible symmetry mismatch');
end

sF = S2FunHandle(@(v) sF.eval(inv(rot).*v), sF.s);

if isa(rot,"orientation"), sF.s = rot.SS; end

end
