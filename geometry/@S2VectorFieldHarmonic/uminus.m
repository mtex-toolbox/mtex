function sVF = uminus(sVF)
%
% Syntax
%  sVF = -sVF
%

sVF = S2VectorFieldHarmonic( ...
  -sVF.sF_theta, ...
  -sVF.sF_rho, ...
  -sVF.sF_n);

end
