function sVF = grad(sF, varargin)
% calculates the gradiet of a spherical harmonic
% Syntax
%  sVF = grad(sF)
%
% Output
%  sVF - @sphericalVectorFieldHarmonic
%

if nargin > 1
  sF = [sF.drho; sF.dthetasin];
  v = varargin{1};
  y = eval(sF, v);
  sVF = ...
    y(:, 1)./sin(v.theta).^2.*S2VectorField.rho(v)+ ...
    y(:, 2)./sin(v.theta).*S2VectorField.theta(v);

  sVF(v.theta < 0.01 | v.theta > pi-0.01) = vector3d([0 0 0]);

else
  sF = [sF.drho; sF.dtheta];
  sVF = S2VectorFieldHarmonic(sF);
end

end
