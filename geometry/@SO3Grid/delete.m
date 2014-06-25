function S3G = delete(S3G,ind)
% clear nodes by indece
% Input
%  SOG    - @SO3Grid
%  indece - int32
%
% Output
%   SO3Grid - "not indexed"

% remove orientations
S3G.a(ind) = [];
S3G.b(ind) = [];
S3G.c(ind) = [];
S3G.d(ind) = [];
S3G.i(ind) = [];

S3G.gamma = subGrid(S3G.gamma,~ind);
S3G.alphabeta  = subGrid(S3G.alphabeta,GridLength(S3G.gamma)>0);
S3G.gamma(GridLength(S3G.gamma)==0) = [];
