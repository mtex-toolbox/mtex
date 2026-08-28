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

% the orientation has to act on the frame the function is expressed in -
% the symmetries need not agree, only the frames have to fit
if isa(rot,"orientation"), rot = fitFrame(rot,sF.frame); end

% a rotated function is invariant under the rotated group rather than under
% the one it came with, so the frame it is written in keeps no group
if sF.bandwidth ~= 0
  fr = sF.frame;
  if ~isempty(fr), fr = stripSym(fr); end
  f = @(v) sF.eval(rotate(v, inv(rot)));
  sF = S2FunHarmonic.quadrature(f, 'bandwidth', sF.bandwidth, fr);
end

% rotating with an orientation changes the reference frame - the result
% adopts the specimen frame; a plain rotation keeps the current frame
if isa(rot,"orientation")
  sF.framePrivate = rot.SS;
end

end
