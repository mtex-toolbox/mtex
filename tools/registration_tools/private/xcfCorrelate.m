function [dx,dy,peak] = xcfCorrelate(A,B,cx,cy,roiSize,fPass,mesh,window,bandPass,varargin)
% batched sub pixel phase correlation of matching tiles of two images
%
% The shift of each tile is the peak of a band pass filtered, windowed phase
% correlation, located to sub pixel accuracy by the upsampled matrix DFT of
% Guizar-Sicairos et al. Every tile is processed at once: the tiles are
% gathered by linear indexing into a roiSize × roiSize × nROI array, and
% fft2/ifft2/pagemtimes run batched over the third dimension.
%
% The upsampled DFT kernels are hoisted out of the per tile work. Written
% naively the kernel is rebuilt for every tile; writing it as
%
%   exp(prefac*(u - dftshift + base*mesh)*f) =
%       exp(prefac*(u - dftshift)*f) .* exp(-2i*pi*base*f/roiSize)
%
% splits it into a factor depending only on the sample index u, shared by
% every tile and built once, and a phase ramp depending only on the tile,
% applied to the cross power spectrum. What is left is a matrix product.
%
% The peak is then refined in two passes rather than one: the same +-0.75
% pixel window at 1/coarseMesh first, then a +-1/coarseMesh window at the
% full 1/mesh. Same final resolution, about 25 times fewer samples. The two
% agree whenever the peak is unimodal inside the search window, which the
% method already assumes.
%
% A tile whose input is not finite - padding, or a flat tile with zero
% standard deviation - comes back NaN in all three outputs.
%
% Syntax
%
%   [dx,dy,peak] = xcfCorrelate(A,B,cx,cy,roiSize,fPass,mesh,window,bandPass)
%
% Input
%  A, B     - r × c images
%  cx, cy   - tile centres in pixels
%  roiSize  - tile width
%  fPass    - band pass settings, as given to xcfFilters
%  mesh     - peak upsampling factor
%  window   - roiSize × roiSize taper
%  bandPass - roiSize × roiSize filter, fft order
%
% Output
%  dx, dy - shift of each tile, in pixels, shaped like cx
%  peak   - correlation peak height
%
% Options
%  coarseMesh - resolution of the first refinement pass, default 48
%  dedupeBand - drop the duplicated band indices, see below
%
% See also
% xcfShift xcfFilters

% Raising coarseMesh costs more in the first pass and saves it in the
% second, and narrows the window the second pass searches, so it also
% decides how often the two pass search can settle in a different lobe than
% a single pass would.
coarse = min(48,mesh);

rs = roiSize;
h = round(rs/2);
nRows = size(A,1);
nR = numel(cx);


% Tiles per batch, holding the coarse correlation array near 128 MB
batchSize = max(1,floor(2^21/max(rs^2,1)));

% The band the filter keeps.
%
% This is not the reduction it looks like. With the shipped settings nKeep is
% 3/4 of roiSize, so the two blocks overlap and a third of the indices appear
% twice - for a 64 pixel tile the "reduced" 96 × 96 spectrum covers all 64
% frequencies with 32 duplicated. The duplicates cost 2.25x in every matrix
% product and, because a doubled index is doubled on both axes, weight those
% frequency pairs four times. 'dedupeBand' drops them, which is cheaper and
% matches the band pass xcfFilters describes - but it changes the answer, and
% measurably for the worse on a known shift, so it is off by default.
nKeep = fPass(3) + fPass(4);
band = [1:nKeep, rs-(nKeep-1):rs]';

bandFilt = bandPass(band,band);

fIdx = ifftshift(0:rs-1) - floor(rs/2);
f = reshape(fIdx(band),[],1);

% sample offsets shared by every tile, one matrix per refinement pass
twoPass = coarse < mesh;
[KrC,KcC] = dftKernels(f,ceil(coarse*1.5),coarse,rs);
if twoPass, [KrF,KcF] = dftKernels(f,2*ceil(mesh/coarse)+1,mesh,rs); end

dx = zeros(nR,1); dy = zeros(nR,1); peak = zeros(nR,1);

cenX = cx(:); cenY = cy(:);

for b0 = 1:batchSize:nR

  b = b0:min(b0+batchSize-1,nR);
  nb = numel(b);

  rows = cenY(b).' + (-h:h-1).';
  cols = cenX(b).' + (-h:h-1).';
  lin = reshape(rows,[rs 1 nb]) + (reshape(cols,[1 rs nb])-1)*nRows;

  [specA,badA] = tileSpectrum(A(lin),window,band,bandFilt);
  [specB,badB] = tileSpectrum(B(lin),window,band,bandFilt);
  bad = badA | badB;

  % the kept band is embedded in a 2*rs array, so the inverse transform lands
  % the peak on a half pixel grid over the full +-rs/2 range
  CC = complex(zeros(2*rs,2*rs,nb));
  lo = rs+1-fix(numel(band)/2);
  hi = rs+1+fix((numel(band)-1)/2);
  CC(lo:hi,lo:hi,:) = fftshift(fftshift(specA.*conj(specB),1),2);
  CC = ifft2(ifftshift(ifftshift(CC,1),2));

  [~,pk] = max(reshape(CC,[],nb),[],1);
  rloc = mod(pk(:)-1,2*rs) + 1;
  cloc = floor((pk(:)-1)/(2*rs)) + 1;

  rowShift = rloc - 1; rowShift(rloc > rs) = rloc(rloc > rs) - 2*rs - 1;
  colShift = cloc - 1; colShift(cloc > rs) = cloc(cloc > rs) - 2*rs - 1;
  rowShift = rowShift/2; colShift = colShift/2;

  kern = specB .* conj(specA);
  [rowShift,colShift,pkHeight] = refine(kern,f,rowShift,colShift,KrC,KcC,coarse,rs);
  if twoPass
    [rowShift,colShift,pkHeight] = refine(kern,f,rowShift,colShift,KrF,KcF,mesh,rs);
  end

  rowShift(bad) = NaN; colShift(bad) = NaN; pkHeight(bad) = NaN;

  dy(b) = rowShift; dx(b) = colShift; peak(b) = pkHeight;

end

dx = reshape(dx,size(cx));
dy = reshape(dy,size(cx));
peak = reshape(peak,size(cx));

end

% =========================================================================
function [spec,bad] = tileSpectrum(tile,window,band,bandFilt)
% zero mean, unit standard deviation, window, transform, band pass

mu = mean(tile,[1 2]);
sd = std(tile,0,[1 2]);
tile = (tile - mu)./sd;

bad = squeeze(~isfinite(sd) | sd == 0 | any(~isfinite(tile),[1 2]));

tile = fft2(tile.*window);
spec = bandFilt.*tile(band,band,:);

% keep NaN out of the batched transforms
spec(:,:,bad) = 0;

end

% =========================================================================
function [Kr,Kc] = dftKernels(f,w,mesh,rs)
% the part of the kernel that does not depend on the tile: the DFT sampled
% at (u - fix(w/2))/mesh pixels, u = 0..w-1

u = (0:w-1).' - fix(w/2);
pf = -1i*2*pi/(rs*mesh);

Kr = exp(pf*(u*f.'));
Kc = exp(pf*(f*u.'));

end

% =========================================================================
function [rowShift,colShift,peak] = refine(kern,f,rowShift,colShift,Kr,Kc,mesh,rs)
% locate the peak on a grid of spacing 1/mesh centred on the incoming
% estimate, applying the tile dependent phase ramp to the spectrum rather
% than building a fresh pair of kernels per tile

w = size(Kr,1);

% snap to the sample grid, so the window is centred on a sample rather than
% between two
rowShift = round(rowShift*mesh)/mesh;
colShift = round(colShift*mesh)/mesh;

pr = exp((-2i*pi/rs)*(f   .* reshape(rowShift,1,1,[])));
pc = exp((-2i*pi/rs)*(f.' .* reshape(colShift,1,1,[])));

CC = conj(pagemtimes(pagemtimes(Kr,kern.*pr.*pc),Kc));

[peak,pk] = max(reshape(CC,[],size(CC,3)),[],1);
peak = abs(peak(:));

d = fix(w/2);
rloc = mod(pk(:)-1,w) - d;
cloc = floor((pk(:)-1)/w) - d;

rowShift = rowShift + rloc/mesh;
colShift = colShift + cloc/mesh;

end
