function NG = subGrid(G,q,epsilon)
% sub-SO3Grid as epsilon neigborhood of a node
%% Syntax
%  NG = subGrid(G,midpoint,radius)
% 
%% Input
%  SO3G     - @SO3Grid
%  midpoint - @quaternion
%  radius   - double
%
%% Output
%  NG - SO3Grid
%
%% See also
%  SO3Grid/find S2Grid/subGrid

if nargin == 3
  ind = find(G,q,epsilon);
elseif islogical(q) 
  ind = q;
else
  ind = false(GridLength(G),1);
  ind(q) = true;
end

NG = G;
NG.Grid    = NG.Grid(ind);

if check_option(G,'indexed')
  id = cumsum([0,GridLength(G.gamma)]);
  for i = 1:length(G.gamma)
    G.gamma(i) = subGrid(G.gamma(i),ind(1+id(i):id(i+1)));
  end
  G.alphabeta  = subGrid(G.alphabeta,GridLength(G.gamma)>0);
  G.gamma(GridLength(G.gamma)==0) = [];
end

