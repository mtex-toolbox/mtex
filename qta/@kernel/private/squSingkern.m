function A = squSingkern(kappa,maxl)
% Chebyshev coefficients of the squared singularity kernel

A(1) = 1;
A(2) = (1+kappa^2)/2/kappa-1/log((1+kappa)/(1-kappa));

for l=1:maxl-1
	A(l+2) = (-2*kappa*l*A(l)+(2*l+1)*(1+kappa^2)*A(l+1))/2/kappa/(l+1);
end

A = A .*(2*(0:maxl)+1);

ind = find(A<min(A)*100,1,'first');
A = A(1:ind);