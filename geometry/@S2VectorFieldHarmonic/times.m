function sVF = times(sVF1,sVF2)
%
% Syntax
%  sVF = sVF1*sVF2
%  sVF = a*sVF1
%  sVF = sVF1*a
%

if isnumeric(sVF1)
  sVF = S2VectorFieldHarmonic( ...
    sVF2.sF_theta*sVF1, ...
    sVF2.sF_rho*sVF1, ...
    sVF2.sF_theta*sVF1);
elseif isnumeric(sVF2)
  sVF = S2VectorFieldHarmonic( ...
    sVF1.sF_theta*sVF2, ...
    sVF1.sF_rho*sVF2, ...
    sVF1.sF_theta*sVF2);
end

end
