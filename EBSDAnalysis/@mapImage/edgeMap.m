function e = edgeMap(mg,padWidth)
% the edge transform of an image: how unlike its neighbours each pixel is
%
% Absolute brightness is not comparable between a band contrast map and a
% backscatter image - they are different physics - but boundaries appear in
% both. Correlating edge transforms rather than raw values is what makes two
% such images registrable against each other at all.
%
% Each channel is contrast normalised over its 2nd to 98th percentile, then
% for each of the eight neighbours the difference vector across channels is
% taken and its length summed in. A pixel whose neighbour lies off the image
% differences against zero.
%
% Syntax
%
%   e = edgeMap(mg)
%   e = edgeMap(mg,3)
%
% Input
%  mg       - @mapImage
%  padWidth - neighbour distance in pixels, default 1. Raise it to bring out
%             boundaries blurred over several pixels
%
% Output
%  e - r × c, one value per pixel
%
% Description
% This is work, not a property read - the whole image is normalised and
% differenced eight times. Compute it once and keep it; a loop that reads it
% per iteration pays for it every time.
%
% The scale is the same whatever the channel count, so edge maps of a
% greyscale and a colour image are directly comparable. TrueEBSD's
% GenBoundaryMap, which this reproduces, returns sqrt(3) times this on a
% single channel image - it replicated greyscale into three identical
% channels and reduced them by a Euclidean norm. That factor is invisible to
% cross correlation, which zero means and unit normalises every tile, so
% dropping it changes no registration result.
%
% See also
% mapImage mapImage/interp

if nargin < 2, padWidth = 1; end

img = mg.img;
[r,c,nChan] = size(img);

% contrast normalise each channel over its 2nd..98th percentile
for k = 1:nChan
  ch = img(:,:,k);
  lim = percentileOf(ch,[2 98]);
  if lim(2) > lim(1), img(:,:,k) = (ch - lim(1)) ./ (lim(2) - lim(1)); end
end

% the eight neighbours, as [row col] offsets
offset = padWidth * [-1 -1; -1 0; -1 1; 0 -1; 0 1; 1 -1; 1 0; 1 1];

e = zeros(r,c);

for k = 1:size(offset,1)
  d = shiftZeroPad(img,offset(k,1),offset(k,2)) - img;
  e = e + sqrt(sum(d.^2,3));
end

end

% =========================================================================
function s = shiftZeroPad(img,dr,dc)
% img displaced by (dr,dc), zeros shifted in at the edges

[r,c,~] = size(img);
s = zeros(size(img));

ri = max(1,1-dr):min(r,r-dr);
ci = max(1,1-dc):min(c,c-dc);

s(ri,ci,:) = img(ri+dr,ci+dc,:);

end
