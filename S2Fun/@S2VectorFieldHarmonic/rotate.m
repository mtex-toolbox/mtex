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

%sVF.sF = rotate(sVF.sF, rot);

if sVF.bandwidth ~= 0
  f = @(v) rot .* sVF.eval(rotate(v, inv(rot)));
  sVF = S2VectorFieldHarmonic.quadrature(f, 'bandwidth', sVF.bandwidth);
end

end
