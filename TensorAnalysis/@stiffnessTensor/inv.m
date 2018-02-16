function S = inv(C)
% stiffness to compliance tensor
%
% Input
%  C - @complianceTensor
%
% Output
%  S - @complianceTensor
%

S = complianceTensor(inv@tensor(C));