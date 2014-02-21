function beta = volumeCompressibility(C)
% computes the volume compressibility of an elasticity tensor
%
% Description
%
% $$\beta(x) = S_{iikk}$$
%
% Input
%  C - elastic stiffness @tensor
%
% Output
%  beta - volume compressibility
%

% compute the complience
S = inv(C);

% compute tensor product
beta = double(EinsteinSum(S,[-1 -1 -2 -2]));
