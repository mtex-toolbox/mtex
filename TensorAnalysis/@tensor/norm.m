function n = norm(T)
% tensor frobenius norm
%
% Synatx
%
%   n = norm(T)
%
% Input
%  T - @tensor
%
% Output
%  n - double
%

n = reshape(sqrt(sum(reshape(T.M.^2,[3^T.rank,size(T)]),1)),size(T));

