function sVF = grad(sF) % gradient
% calculates the gradiet of a spherical harmonic
% Syntax
%  sVF = grad(sF)
%
% Output
%  sVF - @sphericalVectorFieldHarmonic
%

sVF = S2VectorFieldHarmonic(sF.dtheta, sF.drho);

end
