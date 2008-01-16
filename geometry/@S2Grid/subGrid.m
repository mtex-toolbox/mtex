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

G.res = S2G.res;
G.theta = [];
G.rho = [];
G.Grid = S2G.Grid(ind);
G.options = delete_option(S2G.options,'INDEXED');
G = class(G,'S2Grid');
