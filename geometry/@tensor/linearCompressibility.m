function beta = linearCompressibility(C,x)
% computes the linear compressibility of an elasticity tensor
%
% Description
%
% $$\beta(x) = S_{ijkk} x_i x_j$$
%
% Input
%  C - elastic stiffness @tensor
%  x - list of @vector3d
%
% Output
%  beta - linear compressibility in directions v
%

% TODO this should be a function specified by Fourier coefficients
if nargin == 1 || isempty(x)
  x = equispacedS2Grid('points',10000);
  generateFun = true;
else
  generateFun = false;  
end

% compute the complience
S = inv(C);

% compute tensor product
beta = double(EinsteinSum(S,[-1 -2 -3 -3],x,-1,x,-2));

% generate a function if required
if generateFun
  beta = sphFunTri(v,beta);
end