function value = mean(sF)
% calculates the mean value of a spherical harmonic
% Syntax
%  value = mean(sF)
%

s = size(sF);
sF = sF.subSet(':');
value = real(sF.fhat(1, :));
value = reshape(value, s);

end
