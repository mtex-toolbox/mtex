function beta = linearCompressibility(S,x)
% computes the linear compressibility of an elasticity tensor
%
% Description
%
% $$\beta(x) = S_{ijkk} x_i x_j$$
%
% Input
%  S - elastic @complianceTensor
%  x - list of @vector3d
%
% Output
%  beta - linear compressibility in directions v
%

% return a function if required
if nargin == 1 || isempty(x)
  beta = S2FunHarmonicSym.quadrature(@(x) linearCompressibility(S,x),'bandwidth',2,S.CS);
  return
end

% compute tensor product
beta = EinsteinSum(S,[-1 -2 -3 -3],x,-1,x,-2);
