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
  ind = false(GridLength(G));
  ind(q) = true;
end

NG = G;
NG.Grid    = NG.Grid(ind);

if check_option(G,'indexed')
  if isempty(G.subGrid)
    NG.subGrid = ~ind;
  else
    rem = find(~G.subGrid);
    NG.subGrid(rem(~ind)) = true;
  end
end
