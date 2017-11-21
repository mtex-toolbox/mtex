function sVF = grad(sF) % gradient
%
% Syntax
%  sVF = grad(sF)
%

sVF = sphVectorFieldHarmonic(sF.dtheta, sF.drho);

end
