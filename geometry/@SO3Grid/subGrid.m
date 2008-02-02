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

if check_option(NG,'indexed')
  NG.gamma = subGrid(NG.gamma,ind);
  %disp([int2str(sum(GridLength(NG.gamma))), ' - ', int2str(numel(NG.Grid))]);
  NG.alphabeta  = subGrid(NG.alphabeta,GridLength(NG.gamma)>0);
  %disp(int2str(GridLength(NG.alphabeta)));
  NG.gamma(GridLength(NG.gamma)==0) = [];
end

