function [S1G,ind] = subGrid(S1G,x,epsilon)
% epsilon - neighborhood of a point in the grid
%
% Syntax
%   [S1G,ind] = subGrid(S1G,midpoint,radius)
%
% Input
%  S1G        - @S1Grid
%  midpoint   - double
%  radius     - double
%
% Output
%  S1G        - @S1Grid
%  ind        - int32

if nargin == 3
  ind = find(S1G,x,epsilon);
else
  ind = x;
end

p = {S1G.points};
rs = [ 0 cumsum( cellfun('prodofsize',p) )];

if ~islogical(ind)
  ind = sparse(ind(:),ones(numel(ind),1),true(numel(ind),1),rs(end),1);
end

for k=1:numel(p)
  sel = ind( rs(k)+1:rs(k+1) );
  S1G(k).points = p{k}(sel);
end
