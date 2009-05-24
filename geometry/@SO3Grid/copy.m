function S3G = copy(S3G,ind)
% copy nodes by indece
%% Input
%  SOG    - @SO3Grid
%  indece - int32
%% See alseo
%  EBSD/delete EBSD/subGrid


S3G.Grid = S3G.Grid(ind);
S3G.options = delete_option(S3G.options,'INDEXED');