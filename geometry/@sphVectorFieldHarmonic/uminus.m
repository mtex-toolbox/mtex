function sVF = uminus(sVF)
%
% Syntax
%  sVF = -sVF
%

sVF = sphVectorFieldHarmonic( ...
  -sVF.sF_theta, ...
  -sVF.sF_rho, ...
  -sVF.sF_n);

end
