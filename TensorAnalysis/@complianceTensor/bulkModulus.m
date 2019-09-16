function [KV,KR,KVRH] = bulkModulus(S)
% isotropic elastic bulk modulus, Voigt Reuss Hill bounds
%
% Syntax
%
%   [KV,KR,KVRH] = VRHBulkModulus(S)
%
% Input
%  S - @complianceTensor
%
% Output
%  KV - Voigt effective bulk modulus, upper bound
%  KR - Reuss effective bulk modulus, lower bound
%  KVRH - Hill effective bulk modulus

% compute stifness tensor as 6x6 matrices
C = matrix(inv(S),'voigt');
S = matrix(S,'voigt');

% KVoigt = ((C(1,1)+C(2,2)+C(3,3))+(2*(C(1,2)+C(2,3)+C(3,1))))/9
KV = mean(C(1:3,1:3,:),[1,2]);

% KReuss = 1/((S(1,1)+S(2,2)+S(3,3))+2*(S(1,2)+S(2,3)+S(3,1))) 
KR = 1./sum(S(1:3,1:3,:),[1,2]);

% Voigt Reuss Hill average
KVRH = 0.5.*(KV + KR);

end