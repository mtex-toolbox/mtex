function ebsd = transformReferenceFrame(ebsd,gL)
% a hexagonal grid has only one matrix layout
%
% Syntax
%
%   ebsd = transformReferenceFrame(ebsd,gridLayout.columnMajor)
%
% Input
%  ebsd - @EBSDhex
%  gL   - @gridLayout, has to be the column major layout
%
% Output
%  ebsd - @EBSDhex, unchanged
%
% Description
% A hexagonal grid encodes the alternating offset of its lines in the matrix
% layout, so unlike an <EBSDsquare.transformReferenceFrame.html
% |EBSDsquare|> it cannot be reindexed into another one.
%
% See also
% EBSDsquare/transformReferenceFrame EBSD/gridify

if ~isAligned(gL,gridLayout.columnMajor)
  error('MTEX:EBSDhex:fixedLayout','%s\n\n%s',...
    ['A hexagonal grid stores the alternating offset of its lines in the '...
    'matrix layout, so it is always column major and cannot be reindexed '...
    'into the layout asked for.'],...
    'Regrid onto a square unit cell first if the map has to match an image.');
end

end
