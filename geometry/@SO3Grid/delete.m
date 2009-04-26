function S3G = delete(S3G,ind)
% clear nodes by indece
%% Input
%  SOG    - @SO3Grid
%  indece - int32
%% Output
%  "not indexed" SO3Grid

index = 1:length(S3G.Grid);
index(ind) = [];
S3G.Grid = S3G.Grid(index);
S3G.options = delete_option(S3G.options,'INDEXED');

