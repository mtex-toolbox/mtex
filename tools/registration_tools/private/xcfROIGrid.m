function [cx,cy] = xcfROIGrid(roiSize,numROI,region)
% centres of a grid of correlation tiles inside a region
%
% Tiles are spread evenly across the region, with the outermost ones half a
% tile in from its edge so that every tile is whole. A tile that would still
% cross the edge after rounding is dropped rather than clipped.
%
% Syntax
%
%   [cx,cy] = xcfROIGrid(roiSize,[nx ny],[x0 y0 w h])
%
% Input
%  roiSize - tile width in pixels
%  numROI  - [nx ny] tiles across and down
%  region  - [left top width height], as imcrop
%
% Output
%  cx, cy - ny × nx tile centres, in pixels
%
% See also
% xcfShift

h = roiSize/2;

% linspace happily runs backwards, so a tile that cannot fit has to be
% refused here rather than caught as a bad subscript further down
assert(region(3) >= roiSize && region(4) >= roiSize,'MTEX:xcfShift:noROI',...
  ['A tile of %d pixels does not fit inside the %g × %g region the two '...
  'images share. Use a smaller ROISize, or check that they overlap.'],...
  roiSize,region(3),region(4));

x = round(linspace(ceil(h + region(1)), floor(region(1) + region(3) - h), numROI(1)));
y = round(linspace(ceil(h + region(2)), floor(region(2) + region(4) - h), numROI(2)));

% rounding can push the last centre back over the edge
while ~isempty(x) && x(end) + h > region(1) + region(3), x(end) = []; end
while ~isempty(y) && y(end) + h > region(2) + region(4), y(end) = []; end

assert(~isempty(x) && ~isempty(y),'MTEX:xcfShift:noROI',...
  ['No tile of %d pixels fits inside the %g × %g region the two images '...
  'share. Use a smaller ROISize, or check that they overlap at all.'],...
  roiSize,region(3),region(4));

[cx,cy] = meshgrid(x,y);

end
