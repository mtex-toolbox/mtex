function sVF = rdivide(sVF1, sVF2)
%
% Syntax
%  sVF = sVF1/a
%

if isnumeric(sVF2)
  sVF = sphVectorFieldHarmonic( ...
    sVF1.sF_theta./sVF2, ...
    sVF1.sF_rho./sVF2, ...
    sVF1.sF_theta./sVF2);
end

end
