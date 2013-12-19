function psi = mtimes(psi1,psi2)

A = psi1.A;
B = psi2.A;
L = min(length(A),length(B)) - 1;
A = A(1:L+1);
B = B(1:L+1);
l = 0:L;

psi = kernel('Fourier',(A./(2*l+1)).*(B./(2*l+1)) .* (2*l+1));
