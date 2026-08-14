function sF = rotate(sF, rot)
% rotate a function by a rotation
%
% Syntax
%   sF = sF.rotate(rot)
%
% Input
%  sF - @S2FunHarmonic
%  rot - @rotation
%
% Output 
%  sF - @S2FunHarmonic
%

% check for matching reference frames - only a function that claims a
% frame can genuinely mismatch the orientation's crystal frame
if isa(rot,"orientation") && ~isempty(sF.frame) && sF.frame ~= rot.CS.frame
 warning('possible reference frame mismatch');
end

if sF.bandwidth ~= 0
  f = @(v) sF.eval(rotate(v, inv(rot)));
  sF = S2FunHarmonic.quadrature(f, 'bandwidth', sF.bandwidth, sF.frame);
end

% rotating with an orientation changes the reference frame - the result
% adopts the specimen frame; a plain rotation keeps the current frame
if isa(rot,"orientation")
  sF.framePrivate = rot.SS.frame;
  sF.how2plotPrivate = rot.SS.how2plotPrivate;
end

end
