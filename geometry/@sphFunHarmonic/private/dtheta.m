function sF = dtheta(sF)

fhat = zeros((sF.M+2)^2, 1);
for m = 0:sF.M+1
	for l = -m:m
		a = (m-1)*sqrt((m^2-l^2)/((2*m-1)*(2*m+1)));
		b = (m+2)*sqrt(((m+1)^2-l^2)/((2*m+1)*(2*m+3)));
		if (m-1 == 0 | m-1 == -1) & l == 0
			a = 0;
		end
		if m+1 == 0 & l == 0
			b = 0;
		end
		fhat(m*(m+1)+l+1) = a*get_fhat(sF.fhat, m-1, l, sF.M)-b*get_fhat(sF.fhat, m+1, l, sF.M);
	end
end

sF = sphFunHarmonic(fhat);
%f = @(v) sF.eval(v)./max(sin(v.theta), 0.1);
%sF = sphFunHarmonic.quadrature(f, 'm', 2*sF.M);

end



function fhat = get_fhat(fhat, m, l, M)
if abs(l) <= m & 0 <= m & m <= M
	fhat = fhat(m*(m+1)+l+1);
else
	fhat = 0;
end
end
