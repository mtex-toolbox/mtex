function [g,keep] = gridCells(ebsd)
% put a map on its grid and say which cells a text file lists
%
% Description
%
% Both the .ang and the .ctf format write a map row by row with x varying
% fastest. |gridify| provides exactly that order - its first matrix
% dimension is the grid direction closest to y and its second the one
% closest to x, both increasing - so the file order is the transposed
% matrix read column wise.
%
% On a hexagonal grid MTEX stores the staggered rows in a rectangle, which
% may hold cells that are not part of the grid at all - a file whose rows
% differ in length (NCOLS_ODD vs NCOLS_EVEN) leaves the far end of every
% second row unreached. Those are told apart from measurements by oldId,
% which gridify sets for the cells a measurement landed on and leaves NaN
% for the rest.
%
% A square grid keeps its full rectangle instead: an .ang or .ctf lists
% every grid point, and a cell without a measurement is written as not
% indexed rather than left out, which is what keeps the map rectangular.
%
% Syntax
%   [g,keep] = gridCells(ebsd)
%
% Input
%  ebsd - @EBSD
%
% Output
%  g    - gridded @EBSD, @EBSDsquare or @EBSDhex
%  keep - logical matrix, true for every cell the file lists

g = ebsd.gridify;

keep = true(size(g));

if isa(g,'EBSDhex')

  if isfield(g.prop,'oldId')
    keep = ~isnan(g.prop.oldId);
  elseif size(keep,2) > 2
    % no record of where the measurements came from - fall back to the
    % layout a file with alternating row lengths produces
    keep(:,end) = false;
    keep(2:2:end,end-1) = false;
  end

end

end
