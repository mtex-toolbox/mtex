function psi = plus(psi1,psi2)
% overloads |psi1 + psi2|
%
% Syntax
%   psi = psi1 + psi2
%   psi = a + psi1
%   psi = psi1 + a
%
% Input
%  psi1, psi2 - @S2Kernel
%  a - double
%
% Output
%  psi - @S2Kernel
%


if isnumeric(psi1) 
  psi = S2Kernel(psi2);
  psi.A(1) = psi2.A(1)+psi1;
  return
end
if isnumeric(psi2)
  psi = psi2 + psi1;
  return
end

[~, index] = max([psi1.bandwidth, psi2.bandwidth]);
if index == 1
  psi2.bandwidth = psi1.bandwidth;
else
  psi1.bandwidth = psi2.bandwidth;
end

psi = S2Kernel(psi1.A + psi2.A);


end