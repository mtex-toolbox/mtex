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

% check for matching reference frames - only a function that claims a
% frame can genuinely mismatch the orientation's crystal frame
if isa(rot,"orientation") && ~isempty(sF.frame) && sF.frame ~= rot.CS.frame
  warning('possible reference frame mismatch');
end

sF = S2FunHandle(@(v) sF.eval(inv(rot).*v), sF.frame);

% rotating with an orientation changes the reference frame - the result
% adopts the specimen frame; a plain rotation keeps the current frame
if isa(rot,"orientation")
  sF.framePrivate = rot.SS.frame;
  sF.how2plotPrivate = rot.SS.how2plotPrivate;
end

end
