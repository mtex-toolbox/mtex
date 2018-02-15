function sVF1 = cross(sVF1, sVF2, varargin)
% pointwise cross product
%
% Syntax
%   sVF = cross(sVF1, sVF2)
%
% Input
%   sVF1, sVF2 - @S2VectorField
%
% Output
%   sVF - @S2VectorFieldHarmonic
%

if isa(sVF2, 'vector3d')
  
  xyz = repmat(squeeze(double(sVF2)).',size(sVF1.sF.fhat,1),1);
  
  sVF1.sF.fhat = cross(sVF1.sF.fhat,xyz,2);
  
else
  f = @(v) cross(sVF1.eval(v), sVF2.eval(v));
  sVF1 = S2VectorFieldHarmonic.quadrature(f, 'bandwidth',sVF1.bandwidth + sVF2.bandwidth);
end

end
