function sF = rotate_outer(sF, rot)
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

% the orientation has to act on the frame the function is expressed in -
% the symmetries need not agree, only the frames have to fit
if isa(rot,"orientation"), rot = fitFrame(rot,sF.frame); end

sF = S2FunHandle(@(v) sF.eval(inv(rot).*v),sF.frame);

% rotating with an orientation changes the reference frame - the result
% adopts the specimen frame; a plain rotation keeps the current frame
if isa(rot,"orientation")
  sF.framePrivate = rot.SS.frame;
end

end
