function NG = delete(N,ind)
% clear nodes by indece
%% Input
%  SOG    - @SO3Grid
%  indece - int32
%% Output
%  "not indexed" SO3Grid

index = 1:length(N.Grid);
index(ind) = [];
N.Grid = N.Grid(index);
N.options = delete_option(N.options,'INDEXED');
NG = N;
