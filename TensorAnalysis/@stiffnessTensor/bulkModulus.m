function [KV,KR,KVRH] = bulkModulus(C)
% Voigt-Reuss-Hill elastic bulk moduli
%
% Syntax
%
%   [KV,KR,KVRH] = bulkModulus(S)
%
% Input
%  S - @complianceTensor
%
% Output
%  KV - bulk modulus Voigt average, upper bound
%  KR - bulk modulus Reuss average, lower bound
%  KVRH -bulk modulus Voigt Reuss Hill average, ￼


[KV,KR,KVRH] = bulkModulus(inv(C));

end