function [G, ind] = subGrid(G,q,epsilon,varargin)
% sub-SO3Grid as epsilon neigborhood of a node
%
% Syntax
%   G = subGrid(G,midpoint,radius)
% 
% Input
%  G        - @SO3Grid
%  midpoint - @quaternion
%  radius   - double
%
% Output
%  G - SO3Grid
%
% See also
%  SO3Grid/find S2Grid/subGrid

if nargin >= 3
  ind = find(G,q,epsilon,varargin{:});
  ind = any(ind,2);
elseif islogical(q) 
  ind = q;
else
  ind = false(length(G),1);
  ind(q) = true;
end

G.a = G.a(ind);
G.b = G.b(ind);
G.c = G.c(ind);
G.d = G.d(ind);
G.i = G.i(ind);

G.gamma = subGrid(G.gamma,ind);
G.alphabeta  = subGrid(G.alphabeta,GridLength(G.gamma)>0);
G.gamma(GridLength(G.gamma)==0) = [];

