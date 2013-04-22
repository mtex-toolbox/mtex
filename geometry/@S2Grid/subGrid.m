function [S2G,ind] = subGrid(S2G,v,epsilon)
% subgrid 
%
%% Syntax
%  S2G = subGrid(S2G,Ind)
%  [S2G,ind] = subGrid(S2G,midpoint,epsilon)
%
%% Input
%  S2G - S2Grid
%  ind - int32
%  midpoint - vector3d
%  epsilon  - double
%
%% Output
%  S2G   - @S2Grid (not indexed)
%  ind - int32

if nargin == 3
  ind = find(S2G,v,epsilon);
  ind = any(ind,2);
else
  ind = v;
end

S2G.vector3d = S2G.vector3d(ind);

if check_option(S2G,'indexed')
  S2G.rho = subGrid(S2G.rho,ind);
  S2G.theta = subGrid(S2G.theta,GridLength(S2G.rho)>0);
  S2G.rho(GridLength(S2G.rho)==0) = [];
end
