function f_hat = calcFourier(SO3F,L,varargin)
% 

if nargin == 1, L = SO3F.bandwidth; end

f_hat = SO3F.f_hat(1:min(end,deg2dim(L+1)));
