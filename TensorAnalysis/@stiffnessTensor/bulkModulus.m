function [KV,KR,KVRH] = bulkModulus(C)
% isotropic elastic bulk modulus, Voigt Reuss Hill bounds
%
% Syntax
%
%   [KV,KR,KVRH] = bulkModulus(C)
%
% Input
%  C - @stiffnessTensor
%
% Output
%  KV - Voigt effective bulk modulus, upper bound
%  KR - Reuss effective bulk modulus, lower bound
%  KVRH - Voigt Reuss Hill effective bulk modulus

[KV,KR,KVRH] = bulkModulus(inv(C));

end