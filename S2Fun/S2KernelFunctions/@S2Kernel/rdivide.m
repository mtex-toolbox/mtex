function psi = rdivide(psi1, psi2)
% overloads ./
%
% Syntax
%   psi = psi1 ./ psi2
%   psi = psi1 ./ a
%   psi = a ./ psi2
%
% Input
%  psi1, psi2 - @S2Kernel
%  a - double
%
% Output
%  psi - @S2Kernel
%


if isnumeric(psi1)
  psi = SO3KernelHandle(@(co2) psi1 ./ psi2.eval(co2));
  return
end
if isnumeric(psi2)
  psi = times(1./psi2,psi1);
  return
end

psi = SO3KernelHandle(@(co2) psi1.eval(co2)./ psi2.eval(co2));

end

