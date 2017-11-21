function sF = dtheta(sF)
M = sqrt(length(sF.fhat))-1;

fhat = zeros((M+2)^2, 1);
for m = 0:M+1
	a = (m-1)*sqrt((m^2-(-m:m).^2)/((2*m-1)*(2*m+1)));
	b = (m+2)*sqrt(((m+1)^2-(-m:m).^2)/((2*m+1)*(2*m+3)));
	if m <= 1
		a(m+1) = 0; b(m+1) = 0;
	end
	for l = -m:m
		fhat(m*(m+1)+l+1) = a(l+m+1)*get_fhat(sF.fhat, m-1, l, M)-b(l+m+1)*get_fhat(sF.fhat, m+1, l, M);
	end
end

sF = sphFunHarmonic(fhat);
f = @(v) sF.eval(v)./max(sin(v.theta), 0.1);
sF = sphFunHarmonic.quadrature(f);

end



function fhat = get_fhat(fhat, m, l, M)
if abs(l) <= m & 0 <= m & m <= M
	fhat = fhat(m*(m+1)+l+1);
else
	fhat = 0;
end
end
