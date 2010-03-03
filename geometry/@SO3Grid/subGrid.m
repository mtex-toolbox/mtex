function [G ind] = subGrid(G,q,epsilon,varargin)
% sub-SO3Grid as epsilon neigborhood of a node
%% Syntax
%  G = subGrid(G,midpoint,radius)
% 
%% Input
%  G        - @SO3Grid
%  midpoint - @quaternion
%  radius   - double
%
%% Output
%  G - SO3Grid
%
%% See also
%  SO3Grid/find S2Grid/subGrid

if nargin >= 3
  ind = find(G,q,epsilon,varargin{:});
  ind = any(ind,2);
elseif islogical(q) 
  ind = q;
else
  ind = false(numel(G),1);
  ind(q) = true;
end

G.orientation = G.orientation(ind);

if check_option(G,'indexed')
  G.gamma = subGrid(G.gamma,ind);
  %disp([int2str(sum(GridLength(G.gamma))), ' - ', int2str(numel(G.Grid))]);
  G.alphabeta  = subGrid(G.alphabeta,GridLength(G.gamma)>0);
  %disp(int2str(GridLength(G.alphabeta)));
  G.gamma(GridLength(G.gamma)==0) = [];
end
