function ebsd = reduce(ebsd,fak)
% reduce ebsd data by a factor
% 
% Syntax
%   ebsd = reduce(ebsd)   % take every second pixel horiz. and vert.
%   ebsd = reduce(ebsd,3) % take every third pixel horiz. and vert.
%
% Input
%  ebsd - @EBSD
%
% Output
%  ebsd - @EBSD
%

if nargin == 1, fak = 2; end

s = size(ebsd);


rows = 1:2:s(1);
cols = 1:2:2*floor((s(2))/2);

[c,r] = meshgrid(cols,rows);

c = c + iseven(round((r+1)/2));

ind = sub2ind(s,r,c);

ebsd.unitCell = 2*ebsd.unitCell;
ebsd.dHex = 2*ebsd.dHex;

ebsd = ebsd.subSet(ind);

end