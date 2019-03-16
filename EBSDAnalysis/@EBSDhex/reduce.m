function ebsd = reduce(ebsd)
% reduce ebsd data by taking only second pixel
% 
% Syntax
%   ebsd = reduce(ebsd)   % take every second pixel horiz. and vert.
%
% Input
%  ebsd - @EBSDhex
%
% Output
%  ebsd - @EBSDhex
%

s = size(ebsd);

rows = 1:2:s(1);
cols = 1:2:2*floor((s(2))/2);

[c,r] = meshgrid(cols,rows);

if ebsd.isRowAlignment
  c = c + iseven(round((r+1)/2));
else
  r = r + iseven(round((c+1)/2));
end

ind = sub2ind(s,r,c);

ebsd.unitCell = 2*ebsd.unitCell;
ebsd.dHex = 2*ebsd.dHex;

ebsd = ebsd.subSet(ind);

end