function sF = rotate_outer(sF, rot)
% rotate a function by a rotation
%
% Syntax
%   sF = sF.rotate_outer(rot)
%
% Input
%  sF - @S2FunHandle
%  rot - @rotation
%
% Output 
%  sF - @S2FunHandle
%

% the orientation has to act on the frame the function is expressed in -
% the symmetries need not agree, only the frames have to fit
if isa(rot,"orientation"), rot = fitFrame(rot,sF.frame); end

fun = sF.fun;
sF.fun = @(v) fun(inv(rot)*v);

% rotating with an orientation changes the reference frame - the result
% adopts the specimen frame; a plain rotation keeps the current frame
if isa(rot,"orientation")
  sF.framePrivate = rot.SS.frame;
end

end
