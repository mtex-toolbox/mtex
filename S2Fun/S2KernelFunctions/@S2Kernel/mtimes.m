function psi = mtimes(psi1,psi2)
% implements |psi1 * alpha| and |alpha*psi2| as matrix product
%
% Syntax
%   psi = a * psi1
%   psi = psi1 * [1;1]
%
% Input
%  psi1 - @S2Kernel
%  a - double
%
% Output
%  psi - @S2Kernel
%


if isnumeric(psi1) || isnumeric(psi2)
  psi = psi1 .* psi2;
  return
end

error('Operator * is not supported for operands of this types. Use .* instead.')

end