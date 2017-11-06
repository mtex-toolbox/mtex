function sF_theta = stheta(sF)

M = sqrt(length(sF.fhat))-1;
fhat_theta = zeros((M+2)^2, 1);

for m = 1:M+1
	for l = -m:m
		if m <= 1 & l == 0
			a = 0; b = 0;
		else
			a = m*sqrt(((m+1)^2-l^2)/((2*m+1)*(2*m+3)));
			b = (m+1)*sqrt((m^2-l^2)/((2*m-1)*(2*m+1)));
		end
		fhat_theta(m*(m+1)+l+1) = a*get_fhat(sF.fhat, m-1, l, M)-b*get_fhat(sF.fhat, m+1, l, M);
	end
end

sF_tmp = sphFunHarmonic(fhat_theta);
f = @(v) eval(sF_tmp, v)./sin(v.theta);
sF_theta = sphFunHarmonic.quadrature(f);

end


function fhat = get_fhat(fhat, m, l, M)
if abs(l) <= m & 0 <= m & m <= M
	fhat = fhat(m*(m+1)+l+1);
else
	fhat = 0;
end
end
