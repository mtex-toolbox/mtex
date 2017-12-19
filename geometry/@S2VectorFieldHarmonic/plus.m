function sVF = plus(sVF1, sVF2)
%
% Syntax
%  sVF = sVF1+sVF2
%  sVF = a+sVF1
%  sVF = sVF1+a
%

if isa(sVF1, 'vector3d')
  sVF = S2VectorFieldHarmonic(  ...
    sVF2.sF_theta+sVF1.theta, ...
    sVF2.sF_rho+sVF1.rho, ...
    sVF2.sF_n+norm(sVF1));

elseif isa(sVF2, 'vector3d')
  sVF = S2VectorFieldHarmonic(  ...
    sVF1.sF_theta+sVF2.theta, ...
    sVF1.sF_rho+sVF2.rho, ...
    sVF1.sF_n+norm(sVF2));

else
  sVF.sF_theta = sVF1.sF_theta+sVF2.sF_theta;
  sVF.sF_rho = sVF1.sF_theta+sVF2.sF_theta;
  sVF.sF_n = sVF1.sF_theta+sVF2.sF_theta;

end

end
