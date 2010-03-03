function S3G = delete(S3G,ind)
% clear nodes by indece
%% Input
%  SOG    - @SO3Grid
%  indece - int32
%% Output
%  "not indexed" SO3Grid

index = 1:numel(S3G.orientation);
index(ind) = [];
S3G.orientation = S3G.orientation(index);
%S3G.options = delete_option(S3G.options,'INDEXED');

if check_option(S3G,'indexed')
  S3G.gamma = subGrid(S3G.gamma,ind);
  S3G.alphabeta  = subGrid(S3G.alphabeta,GridLength(S3G.gamma)>0);
  S3G.gamma(GridLength(S3G.gamma)==0) = [];
end
