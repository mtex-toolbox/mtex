function S3G = copy(S3G,ind)
% copy nodes by indece
%% Input
%  SOG    - @SO3Grid
%  indece - int32
%% See alseo
%  EBSD/delete EBSD/subGrid


S3G.orientation = S3G.orientation(ind);

if check_option(S3G,'indexed')
  S3G.gamma = subGrid(S3G.gamma,ind);
  S3G.alphabeta  = subGrid(S3G.alphabeta,GridLength(S3G.gamma)>0);
  S3G.gamma(GridLength(S3G.gamma)==0) = [];
end
