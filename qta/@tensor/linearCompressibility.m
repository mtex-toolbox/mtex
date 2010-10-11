function out = linearCompressibility(E,v)
% computes the linear compressibility of an elasticity tensor
%
%% Description
% formula: out = S_ijkk x_i x_j
%
%% Input
%  E - elasticity @tensor
%  v - list of @vector3d
%
%% Output
%  out - linear compressibility in directions v
%

% compute the complience
S = inv(E);

% compute tensor product
out = double(EinsteinSum(S,[-1 -2 -3 -3],v,-1,v,-2));