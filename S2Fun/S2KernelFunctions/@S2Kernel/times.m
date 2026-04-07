function psi = times(psi1,psi2)
% overloads |psi1 .* psi2|
%
% Syntax
%   psi = psi1 .* psi2
%   psi = a .* psi2
%   psi = psi1 .* a
%
% Input
%  psi1, psi2 - @S2Kernel
%  a - double
%
% Output
%  psi - @S2Kernel
%

if isnumeric(psi1)
  psi = SO3Kernel(psi1 .* psi2.A);
  return
end
if isnumeric(psi2)
  psi = psi2 .* psi1;
  return
end

psi = SO3KernelHandle(@(co2) psi1.eval(co2).* psi2.eval(co2));

end
