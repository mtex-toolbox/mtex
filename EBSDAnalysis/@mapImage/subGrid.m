function mg = subGrid(mg,rows,cols)
% crop a rectangle out of a mapImage
%
% Crops the image, the map that travels with it, and moves the origin so the
% geometry still says where the remaining pixels are. Nothing is resampled.
%
% Syntax
%
%   mg = subGrid(mg,rows,cols)
%   mg = subGrid(mg,mask)
%
% Input
%  mg         - @mapImage
%  rows, cols - index vectors, contiguous and ascending
%  mask       - logical over the grid; its bounding box is taken
%
% Output
%  mg - @mapImage
%
% See also
% mapImage mapImage/extent EBSDsquare/subGrid

if nargin == 2 && islogical(rows)
  mask = rows;
  rows = find(any(mask,2)); cols = find(any(mask,1));
  rows = rows(1):rows(end); cols = cols(1):cols(end);
end

rows = rows(:).'; cols = cols(:).';

assert(isequal(rows,rows(1):rows(end)) && isequal(cols,cols(1):cols(end)),...
  'MTEX:mapImage:notContiguous',...
  'A subGrid is a rectangle, so the indices have to be contiguous and ascending.');

sz = gridSize(mg);
assert(rows(1) >= 1 && rows(end) <= sz(1) && cols(1) >= 1 && cols(end) <= sz(2),...
  'MTEX:mapImage:outsideGrid',...
  'Asked for rows %d:%d and columns %d:%d of a %d x %d grid.',...
  rows(1),rows(end),cols(1),cols(end),sz(1),sz(2));

% the corner moves with the crop, which is the whole of the geometry update
mg.origin = mg.origin + (rows(1)-1)*mg.d1 + (cols(1)-1)*mg.d2;

mg.img = mg.img(rows,cols,:);

if ~isempty(mg.ebsd), mg.ebsd = mg.ebsd(rows,cols); end

end
