function sF = dthetadtheta(sF)

fhat_theta = zeros((sF.M+2)^2, 1);
for m = 0:sF.M+1
	a = (m-1)*sqrt((m^2-(-m:m).^2)/((2*m-1)*(2*m+1)));
	b = (m+2)*sqrt(((m+1)^2-(-m:m).^2)/((2*m+1)*(2*m+3)));
	if m <= 1
		a(m+1) = 0; b(m+1) = 0;
	end
	for l = -m:m
		fhat_theta(m*(m+1)+l+1) = a(l+m+1)*get_fhat(sF.fhat, m-1, l, sF.M)-b(l+m+1)*get_fhat(sF.fhat, m+1, l, sF.M);
	end
end

sF_theta = sphFunHarmonic(fhat_theta);


fhat_theta_theta = zeros((sF_theta.M+2)^2, 1);
for m = 0:sF_theta.M+1
	a = (m-1)*sqrt((m^2-(-m:m).^2)/((2*m-1)*(2*m+1)));
	b = (m+2)*sqrt(((m+1)^2-(-m:m).^2)/((2*m+1)*(2*m+3)));
	if m <= 1
		a(m+1) = 0; b(m+1) = 0;
	end
	for l = -m:m
		fhat_theta_theta(m*(m+1)+l+1) = a(l+m+1)*get_fhat(sF_theta.fhat, m-1, l, sF_theta.M)-b(l+m+1)*get_fhat(sF_theta.fhat, m+1, l, sF_theta.M);
	end
end

sF_theta_theta = sphFunHarmonic(fhat_theta_theta);

f = @(v) (sF_theta_theta.eval(v)-cos(v.theta).*sF_theta.eval(v))./max(sin(v.theta).^2, 0.1);
sF = sphFunHarmonic.quadrature(f);

end



function fhat = get_fhat(fhat, m, l, M)
if abs(l) <= m & 0 <= m & m <= M
	fhat = fhat(m*(m+1)+l+1);
else
	fhat = 0;
end
end
