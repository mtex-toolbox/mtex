function [G,ind] = subGrid(S2G,v,epsilon)
% subgrid 
%
%% Syntax
%  G = subGrid(S2G,Ind)
%  [G,ind] = subGrid(S2G,midpoint,epsilon)
%
%% Input
%  S2G - S2Grid
%  ind - int32
%  midpoint - vector3d
%  epsilon  - double
%
%% Output
% G   - "not indexed" - S2Grid
%  ind - int32

if nargin == 3
  ind = find(S2G,v,epsilon);
else
  ind = v;
end

G = S2G;
G.Grid = G.Grid(ind);
G.res = S2G.res;

if check_option(G,'indexed')
  id = cumsum([0,GridLength(G.rho)]);
  for i = 1:length(G.rho)
    G.rho(i) = subGrid(G.rho(i),ind(1+id(i):id(i+1)));
  end
  G.theta = subGrid(G.theta,GridLength(G.rho)>0);
  G.rho(GridLength(G.rho)==0) = [];
end
