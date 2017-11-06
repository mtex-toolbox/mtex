function sF_rho = drho(sF)

M = sqrt(length(sF.fhat))-1;
fhat_rho = zeros((M+1)^2, 1);
for m = 1:M
	fhat_rho(m*(m+1)+(-m:m)+1) = i*(-m:m)'.*sF.fhat(m*(m+1)+(-m:m)+1);
end
sF_rho = sphFunHarmonic(fhat_rho);

end
