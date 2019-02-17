function [V,E] = svd(T)
% singular value decomposition of a rank two tensor
%
% Syntax
%   E = svd(T)
%   [V,E] = svd(T)
%
% Input
%  T - list of M rank 2 @tensor
%
% Output
%  E - 3xM list of singular values
%  V - 3xM list left singular vectors @vector3d
%


[V,E] = eig(T' * T);
E = sqrt(E);

if nargout <= 1, V = E; end
