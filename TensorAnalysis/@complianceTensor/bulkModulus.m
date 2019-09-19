function [KV,KR,KVRH] = bulkModulus(S)
% isotropic elastic bulk modulus, Voigt Reuss Hill bounds
%
% Syntax
%
%   [KV,KR,KVRH] = BulkModulus(S)
%
% Input
%  S - @complianceTensor
%
% Output
%  KV - Voigt effective bulk modulus, upper bound
%  KR - Reuss effective bulk modulus, lower bound
%  KVRH - Voigt Reuss Hill effective bulk modulus

% the Voigt bound
% KV = ((C(1,1)+C(2,2)+C(3,3))+(2*(C(1,2)+C(2,3)+C(3,1))))/9
KV = EinsteinSum(inv(S),[-1 -1 -2 -2])/9;


% the Reuss bound
% KR = 1/((S(1,1)+S(2,2)+S(3,3))+2*(S(1,2)+S(2,3)+S(3,1)))
KR = 1./EinsteinSum(S,[-1 -1 -2 -2]);

% Voigt Reuss Hill average
KVRH = 0.5.*(KV + KR);

end