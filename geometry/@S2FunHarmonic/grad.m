function sVF = grad(sF, varargin) % gradient
% calculates the gradiet of a spherical harmonic
% Syntax
%  sVF = grad(sF)
%
% Output
%  sVF - @sphericalVectorFieldHarmonic
%

f = @(v) ...
  sF.dthetasin.eval(v)./sin(v.theta).*S2VectorField.theta(v)+ ...
  sF.drho.eval(v)./(sin(v.theta).^2).*S2VectorField.rho(v);
%                       ^
%                       |
%              from the metrix tensor

sVF = S2VectorFieldHarmonic.quadrature(f);

end
