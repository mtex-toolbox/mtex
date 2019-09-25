function S3G = copy(S3G,ind)
% copy nodes by indece
%
% Input
%  S3G    - @SO3Grid
%  indece - int32
%
% See also
%  EBSD/delete EBSD/subGrid

 S3G.a = S3G.a(ind);
 S3G.b = S3G.b(ind);
 S3G.c = S3G.c(ind);
 S3G.d = S3G.d(ind);
 S3G.i = S3G.i(ind);
  
 S3G.gamma = subGrid(S3G.gamma,ind);
 S3G.alphabeta  = subGrid(S3G.alphabeta,GridLength(S3G.gamma)>0);
 S3G.gamma(GridLength(S3G.gamma)==0) = [];
