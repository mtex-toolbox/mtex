function [i,j,inside] = pos2ind(mg,pos)
% which pixel of a mapImage covers a position
%
% On a regular grid this is a projection and a round, not a search: the two
% step vectors are perpendicular, so the row and the column index separate.
%
% Syntax
%
%   [i,j] = pos2ind(mg,pos)
%   [i,j,inside] = pos2ind(mg,pos)
%   ind = pos2ind(mg,pos)
%
% Input
%  mg  - @mapImage
%  pos - @vector3d
%
% Output
%  i, j   - row and column index, 1 based, NOT clipped to the grid
%  inside - whether the index falls within the grid
%  ind    - linear index into the grid, NaN outside it
%
% See also
% mapImage mapImage/interp mapImage/subGrid

[u,v] = gridCoordinates(mg,pos);

i = round(u) + 1;
j = round(v) + 1;

sz = gridSize(mg);
inside = i >= 1 & i <= sz(1) & j >= 1 & j <= sz(2);

if nargout <= 1
  ind = nan(size(i));
  ind(inside) = sub2ind(sz,i(inside),j(inside));
  i = ind;
end

end
