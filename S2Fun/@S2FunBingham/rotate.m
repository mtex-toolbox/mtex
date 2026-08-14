function  BS2 = rotate(BS2,rot)
% rotate a S2FunBingham function
%
% Syntax
%   BS2 = BS2.rotate(rot)
%
% Input
%  BS2 - @S2FunBingham
%  rot - @rotation
%
% Output 
%  BS2 - @S2FunBingham
%

% the orientation has to act on the frame the function is expressed in -
% the symmetries need not agree, only the frames have to fit
if isa(rot,'orientation'), rot = fitFrame(rot,BS2.frame); end

BS2.a = rot.*BS2.a;

% rotating with an orientation changes the reference frame - the result
% adopts the specimen frame; a plain rotation keeps the current frame
if isa(rot,'orientation')
  BS2.framePrivate = rot.SS.frame;
  BS2.how2plotPrivate = rot.SS.how2plotPrivate;
end

end

