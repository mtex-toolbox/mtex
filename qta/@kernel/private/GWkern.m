function p=GWkern(kappa,l)
% Legendre coefficients of the Gauss-Weierstrass kernel
% up to order l with coefficient kappa

p(1) = 1;
for i=1:l
    p(i+1) = (2*i+1)*exp(-i*(i+1)*kappa);
end
%p = p(1:sum(p > 1E-10));
