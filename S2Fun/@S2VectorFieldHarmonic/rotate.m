function sVF = rotate(sVF, rot, varargin)
% rotate a function by a rotation
%
% Syntax
%   sVF = sVF.rotate(rot)
%
% Input
%  sVF - @S2VectorFieldHarmonic
%  rot - @rotation
%
% Output
%   sVF - @S2VectorFieldHarmonic
%

% the orientation has to act on the frame the field is expressed in - the
% symmetries need not agree, only the frames have to fit
fr = getFrame(sVF.sF);
if isa(rot,'orientation'), rot = fitFrame(rot,fr); end

if sVF.bandwidth ~= 0
  f = @(v) rot .* sVF.eval(rotate(v, inv(rot)));
  sVF = S2VectorFieldHarmonic.quadrature(f, 'bandwidth', sVF.bandwidth);
end

% rotating with an orientation changes the reference frame - the result
% adopts the specimen frame; a plain rotation keeps the current frame,
% which the quadrature rebuild above dropped
if isa(rot,'orientation')
  sVF.sF = setFrame(sVF.sF,rot.SS.frame);
elseif ~isempty(fr)
  sVF.sF = setFrame(sVF.sF,fr);
end

end
