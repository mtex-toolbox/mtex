function NG = subGrid(G,q,epsilon)
% sub-SO3Grid as epsilon neigborhood of a node
% usage:  NG = subGrid(G,midpoint,radius)
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
  ind = zeros(GridLength(G));
  ind(q) = 1;
end

NG = G;
NG.Grid    = NG.Grid(ind);

if check_option(G,'indexed')
  rem = find(~G.subGrid);
  NG.subGrid(rem(~ind)) = 1;
end
