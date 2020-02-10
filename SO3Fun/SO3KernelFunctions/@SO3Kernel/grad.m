function value = grad(psi,co2)

% TODO: new Chebyshev coefficients after differentiation
l = (0:psi.bandwidth).';
A = psi.A .* l;

if nargin == 2
  value = ClenshawU(A,co2);
else
  value = SO3Kernel(A);
end
