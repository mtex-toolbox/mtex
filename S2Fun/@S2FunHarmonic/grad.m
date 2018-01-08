function sVF = grad(sF)
% calculates the gradiet of a spherical harmonic
% Syntax
%  sVF = grad(sF)
%
% Output
%  sVF - @sphericalVectorFieldHarmonic
%

Gth = sF.dtheta;
Grh = sF.drho;

f = @(v) ...
  Gth.eval(v)./(sin(v.theta).^2).*S2VectorField.rho(v)+ ...
  Grh.eval(v).*S2VectorField.theta(v);
%                       ^
%                       |
%              from the metrix tensor

sVF = S2VectorFieldHarmonic.quadrature(f);

end
