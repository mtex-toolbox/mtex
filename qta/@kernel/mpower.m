function psi = mpower(psi,p)

A = psi.A;
L = length(A) - 1;
l = 0:L;

psi = kernel('Fourier',(A./(2*l+1)).^p .* (2*l+1));
