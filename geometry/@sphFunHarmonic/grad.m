function sVF = grad(sF) % gradient
% calculates the gradiet of a spherical harmonic
% Syntax
%  sVF = grad(sF)
%
% Output
%  sVF - @sphericalVectorFieldHarmonic
%

sVF = sphVectorFieldHarmonic(sF.dtheta, sF.drho);

end
