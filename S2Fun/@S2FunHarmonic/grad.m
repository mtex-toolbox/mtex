function sVF = grad(sF)
% calculates the gradiet of a spherical harmonic
% Syntax
%  sVF = grad(sF)
%
% Output
%  sVF - @sphericalVectorFieldHarmonic
%

sF = [sF.drho sF.dtheta];
sVF = S2VectorFieldHarmonic(sF);

end
