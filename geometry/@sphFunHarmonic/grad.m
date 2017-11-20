function sVF = grad(sF) % gradient

M = sqrt(length(sF.fhat))-1;

fhat_theta = zeros((M+2)^2, 1);
for m = 0:M+1
	a = (m-1)*sqrt((m^2-(-m:m).^2)/((2*m-1)*(2*m+1)));
	b = (m+2)*sqrt(((m+1)^2-(-m:m).^2)/((2*m+1)*(2*m+3)));
	if m <= 1
		a(m+1) = 0; b(m+1) = 0;
	end
	for l = -m:m
		fhat_theta(m*(m+1)+l+1) = a(l+m+1)*get_fhat(sF.fhat, m-1, l, M)-b(l+m+1)*get_fhat(sF.fhat, m+1, l, M);
	end
end
sF_theta = sphFunHarmonic(fhat_theta, 'w', @(v) sF.w(v)./max(sin(v.theta), 0.1));


fhat_rho = zeros((M+1)^2, 1);
for m = 1:M
	fhat_rho(m*(m+1)+(-m:m)+1) = i*(-m:m)'.*sF.fhat(m*(m+1)+(-m:m)+1);
end
sF_rho = sphFunHarmonic(fhat_rho, 'w', @(v) sF.w(v));

sVF = sphVectorFieldHarmonic(sF_theta, sF_rho);

end


function fhat = get_fhat(fhat, m, l, M)
if abs(l) <= m & 0 <= m & m <= M
	fhat = fhat(m*(m+1)+l+1);
else
	fhat = 0;
end
end
