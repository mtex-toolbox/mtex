function [row,col] = cube2hex(ebsd,x,~,z)
% convert cube coordinates into offset coordinates
%
% Description
% The inverse of <EBSDhex.hex2cube.html |hex2cube|>. Cells outside the
% measured grid are returned as |NaN|. Called with a single output the
% linear index into the grid is returned instead of row and column.
%
% Syntax
%   [row,col] = cube2hex(ebsd,x,y,z)
%   ind = cube2hex(ebsd,x,y,z)
%
% Input
%  ebsd    - @EBSDhex
%  x, y, z - cube coordinates of the cells
%
% Output
%  row, col - offset coordinates of the cells, |NaN| outside the grid
%  ind      - linear indices of the cells
%
% See also
% EBSDhex/hex2cube

if ebsd.isRowAlignment
  col = 1 + x + (z - ebsd.offset * ~iseven(round(z))) / 2;
  row = 1 + z;
else
  col = 1 + x;
  row = 1 + z + (x - ebsd.offset * ~iseven(round(x))) / 2;
end

% ensure inside the box
isInside = row > 0 & col > 0 & row <= size(ebsd,1) & col <= size(ebsd,2);
row(~isInside) = NaN;
col(~isInside) = NaN;

if nargout < 2
  ind = ~isnan(row);
  row(ind) = sub2ind(size(ebsd),row(ind),col(ind));
end

end
