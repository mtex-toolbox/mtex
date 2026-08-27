function [u,peak,pos] = xcfShift(A,B,varargin)
% measure how far each part of one image moved relative to another
%
% Divides the region the two images share into a grid of tiles and phase
% correlates each tile against the matching tile of the other image. The
% result is a displacement per tile, to sub pixel accuracy, and the height of
% the correlation peak that produced it.
%
% The peak height is not a diagnostic - it is the weight. A tile that landed
% on featureless background correlates weakly and must not get an equal vote
% when a transform is fitted through the displacements:
%
%   [u,peak,pos] = xcfShift(A,B);
%   T = spatialTransformShift.fit(pos, pos + u, 'weights', peak);
%
% Syntax
%
%   [u,peak,pos] = xcfShift(A,B)
%   [u,peak,pos] = xcfShift(mgA,mgB)
%   [u,peak,pos] = xcfShift(A,B,'ROISize',64,'numROI',[24 18])
%
% Input
%  A, B     - r × c images, the same size
%  mgA, mgB - @mapImage on the same grid, in which case u and pos are in
%             specimen units rather than pixels
%
% Output
%  u    - n × 1 @vector3d, the displacement from A to B at each tile: the
%         feature at pos in A is at pos + u in B
%  peak - n × 1 correlation peak height, the fit weight
%  pos  - n × 1 @vector3d, the tile centres, in A
%
% Options
%  ROISize    - tile width in pixels, default 2^ceil(log2(rows/4))
%  numROI     - tiles across, scalar or [nx ny]. A scalar is scaled by the
%               aspect ratio to give ny. Default 24
%  XCFMesh    - peak upsampling, default 250
%  coarseMesh - resolution of the first refinement pass, default 48
%
% Flags
%  dedupeBand - drop the duplicated band pass indices, see xcfCorrelate
%
% Description
% Only the region where both images are finite is tiled, so the padding an
% earlier resampling left behind is excluded rather than correlated against.
% A tile that still contains a non finite value, or that is flat, comes back
% with NaN in all three outputs - drop those before fitting, which every
% spatialTransform fit does for you.
%
% References
%
% * M. Guizar-Sicairos, S. T. Thurman, J. R. Fienup, Efficient subpixel image
% registration algorithms, Optics Letters (2008), Vol. 33, 156.
%
% See also
% spatialTransform mapImage/edgeMap

% a @mapImage pair carries its own geometry, so answer in specimen units
isMap = isa(A,'mapImage');

assert(isMap == isa(B,'mapImage'),'MTEX:xcfShift:mixedInput',...
  'Give two images or two mapImages, not one of each.');

if isMap
  assert(isequal(gridSize(A),gridSize(B)),'MTEX:xcfShift:sizeMismatch',...
    ['The two images have to be on one grid before they can be correlated. '...
    'They are %s and %s.'],mat2str(gridSize(A)),mat2str(gridSize(B)));
  mg = A;
  A = A.img; B = B.img;
end

if size(A,3) > 1, A = mean(A,3); end
if size(B,3) > 1, B = mean(B,3); end

assert(isequal(size(A),size(B)),'MTEX:xcfShift:sizeMismatch',...
  'The two images have to be the same size, got %s and %s.',...
  mat2str(size(A)),mat2str(size(B)));

[nRows,nCols] = size(A);

% about 25 grains across a typical map, rounded to a power of two
roiSize = get_option(varargin,'ROISize',2^ceil(log2(nRows/4)));
roiSize = 2*round(roiSize/2);

% below this the band pass keeps no frequencies at all and the correlation
% fails somewhere deep inside instead of here
assert(roiSize >= 8,'MTEX:xcfShift:tileTooSmall',...
  ['A correlation tile of %d pixels is too small to filter and correlate. '...
  'ROISize is in pixels and has to be at least 8.'],roiSize);

n = get_option(varargin,'numROI',24);
if isscalar(n), n = [n, max(1,round(n*nRows/nCols))]; end

mesh = get_option(varargin,'XCFMesh',250);

% only where both images have a measurement - the rest is padding
valid = isfinite(A) & isfinite(B);
assert(any(valid,'all'),'MTEX:xcfShift:noOverlap',...
  'The two images have no pixel where both are finite.');

rows = find(any(valid,2)); cols = find(any(valid,1));
region = [cols(1)+1, rows(1)+1, cols(end)-cols(1)-1, rows(end)-rows(1)-1];

[cx,cy] = xcfROIGrid(roiSize,n,region);

% the band pass the tiles are filtered by, and the taper
fPass = [0; 0; round(roiSize/2); round(roiSize/4)];
[bandPass,window] = xcfFilters(roiSize,fPass);

[dx,dy,peak] = xcfCorrelate(A,B,cx,cy,roiSize,fPass,mesh,window,bandPass,varargin{:});

% The correlation answers "where in B is the feature that A has here", i.e.
% A(p) = B(p - d). Negating makes u the displacement FROM A TO B, so that
% pos + u is where a tile went - which is the direction spatialTransform
% fits in, and the direction its name claims.
dx = -dx; dy = -dy;

peak = peak(:);

if isMap
  % pixel steps into specimen displacement, and tile centres into positions
  u = dx(:).*mg.d2 + dy(:).*mg.d1;
  pos = mg.origin + (cy(:)-1).*mg.d1 + (cx(:)-1).*mg.d2;
else
  z = zeros(numel(dx),1);
  u = vector3d(dx(:),dy(:),z);
  pos = vector3d(cx(:),cy(:),z);
end

end
