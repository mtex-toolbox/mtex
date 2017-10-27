function sF = approximation(v, y, varargin)

M_MAX = ceil(sqrt(length(v))/2);
Y = zeros(length(v), (M_MAX+1)^2);
for m = 0 : M_MAX
	for l = -m : m
		P =legendre(m, cos(v.theta));
		P = P(abs(l)+1, :);
		P = (-1)^abs(l)*sqrt(factorial(m-abs(l))/factorial(m+abs(l)))*P;

		Y(:, m^2+l+m+1) = sqrt((2*m+1)/(4*pi))*P.*exp(i*l*v.rho');
	end
end

fhat = (Y'*Y)\(Y'*y);
sF = sphFunHarmonic(fhat);

end
