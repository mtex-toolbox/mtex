function C = inv(S)
% compliance to stiffness tensor
%
% Input
%  S - @complianceTensor
%
% Output
%  C - @stiffnessTensor
%

C = stiffnessTensor(inv@tensor(S));