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

% compute the complience
S = inv(C);

% compute tensor product
beta = double(EinsteinSum(S,[-1 -2 -3 -3],x,-1,x,-2));
