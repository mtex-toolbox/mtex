function value = grad(psi,co2)

% TODO: new Chebyshev coefficients after differentiation
A = psi.A;

if nargin == 2
  value = ClenshawU(A,co2);
else
  value = SO3Kernel(A);
end
