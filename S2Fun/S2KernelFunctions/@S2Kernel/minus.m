function psi = minus(psi1,psi2)
% overloads |psi1 - psi2|
%
% Syntax
%   psi = psi1 - psi2
%   psi = a - psi1
%   psi = psi1 - a
%
% Input
%  psi1, psi2 - @S2Kernel
%  a - double
%
% Output
%  psi - @S2Kernel
%

psi = plus(psi1,-psi2);
        
end