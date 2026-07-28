function [x,y,z] = hex2cube(ebsd,row,col)
% convert offset coordinates into cube coordinates
%
% Description
% Cells of a hexagonal grid are addressed by a row and a column index,
% so called offset coordinates. For many computations the three digit cube
% coordinates |x|, |y|, |z| are more convenient as they satisfy
% |x + y + z == 0| and all six neighbours differ by exactly one step in two
% of the three coordinates. See
% <https://www.redblobgames.com/grids/hexagons/ here> for the details.
%
% Syntax
%   [x,y,z] = hex2cube(ebsd,row,col)
%   [x,y,z] = hex2cube(ebsd,ind)
%
% Input
%  ebsd     - @EBSDhex
%  row, col - offset coordinates of the cells
%  ind      - linear indices of the cells
%
% Output
%  x, y, z - cube coordinates of the cells
%
% See also
% EBSDhex/cube2hex

% convert to row, col indices
if nargin == 2, [row,col] = ind2sub(size(ebsd),row); end

%col = col - 1 + ebsd.offset * ~iseven(round(row));
col = col - 1;
row = row - 1 ;

if ebsd.isRowAlignment
  x = col - (row - ebsd.offset * ~iseven(round(row))) / 2;
  z = row;
else
  z = row - (col - ebsd.offset * ~iseven(round(col))) / 2;
  x = col;
end
y = -x-z;

end
