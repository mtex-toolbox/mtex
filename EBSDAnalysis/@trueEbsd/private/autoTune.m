function [opt,regImg,notes] = autoTune(job)
% measure the settings that were left at 'auto'
%
% Nothing here is a new idea: these are the rules the paper states and the
% retry loop already applies, run forwards off one cheap correlation instead
% of by hand or by doubling after failure.
%
% Syntax
%
%   [opt,regImg,notes] = autoTune(job)
%
% Input
%  job - @trueEbsd, after pixelSizeMatch
%
% Output
%  opt    - job.opt with every 'auto' replaced by a measured value
%  regImg - what each map contributes to the correlation, computed once
%  notes  - what was measured, as numbers rather than as sentences, so the
%           caller decides how to lay it out. NaN where a value was given
%           outright and nothing was measured for it:
%             edgePx  per map, roiPx / shiftPx / featPx per hop
%
% Description
% Two measurements. registerOn is deliberately not among them - see below.
%
%  edgeWidth   the neighbour distance that makes the edge transform most
%              informative - swept over the image alone, taking the width
%              at which the variance of the result saturates
%  roiSize     from the shift a coarse pass measures. The paper's rule is
%              that a measured shift should be no more than about a quarter
%              of the tile width, so four times the shift, floored by the
%              feature scale and rounded to a power of two
%
% The coarse pass uses few large tiles deliberately. Its own size is fixed,
% so if it were small it could miss a large shift and every size derived
% from it would be confidently wrong. The retry in calcDistortion remains
% the backstop for that.
%
% See also
% trueEbsd/setOptions trueEbsd/calcDistortion xcfShift

opt = job.opt;
nImg = numel(job.resizedList);

notes = struct('edgePx',nan(1,nImg),'roiPx',nan(1,nImg-1), ...
  'shiftPx',nan(1,nImg-1),'featPx',nan(1,nImg-1));

% ---- 1. the edge transform's length scale, per image --------------------
for n = 1:nImg

  if ~ischar(opt(n).edgeWidth), continue; end

  px = job.resizedList(n).dx;
  w = bestEdgeWidth(job.resizedList(n));
  opt(n).edgeWidth = w * px;

  notes.edgePx(n) = w;

end

% ---- the two candidate registration images ------------------------------
% both are needed while registerOn is still open, and the chosen one is kept
edgeOf = cell(1,nImg); rawOf = cell(1,nImg);
for n = 1:nImg
  padPx = max(1,round(opt(n).edgeWidth / job.resizedList(n).dx));
  edgeOf{n} = edgeMap(job.resizedList(n),padPx);
  rawOf{n}  = job.resizedList(n).img;
  if size(rawOf{n},3) > 1, rawOf{n} = mean(rawOf{n},3); end
end

% ---- 2. the registration image ------------------------------------------
% registerOn is NOT measured - see the note on betterOn below, and
% PARAMETERS.md. It is stated, and the two sides of a hop have to agree,
% because correlating an edge transform against raw values is meaningless
% and the per image setting allows it.
for n = 1:nImg-1
  if isa(job.T(n),'spatialTransformId'), continue; end
  assert(strcmp(opt(n).registerOn,opt(n+1).registerOn), ...
    'MTEX:trueEbsd:registerOnMismatch', ...
    ['Hop %d correlates map %d against map %d, but one is set to ''%s'' '...
    'and the other to ''%s''. An edge transform and a set of raw values '...
    'have nothing to match on.'],n,n,n+1,opt(n).registerOn,opt(n+1).registerOn);
end

regImg = cell(1,nImg);
for n = 1:nImg
  if strcmp(opt(n).registerOn,'edge'), regImg{n} = edgeOf{n}; else, regImg{n} = rawOf{n}; end
end

% ---- 3. the tile size, per hop ------------------------------------------
for n = 1:nImg-1

  if ~ischar(opt(n).roiSize), continue; end

  px = job.resizedList(n).dx;

  % measured even where the hop is the identity and nothing is fitted: the
  % residual across that pair is still a real measurement, and calcDistortion
  % takes it with the same tiles as everything else
  [sizePx,shiftPx,featPx] = bestRoiSize(regImg{n},regImg{n+1}, ...
    opt(n).numROI,gridSize(job.resizedList(n)));

  opt(n).roiSize = sizePx * px;

  notes.roiPx(n)   = sizePx;
  notes.shiftPx(n) = shiftPx;
  notes.featPx(n)  = featPx;

end

% the reference correlates against nothing
if ischar(opt(nImg).roiSize), opt(nImg).roiSize = 0; end

% ---- 4. can each image be registered on directly ------------------------
for n = 1:nImg
  if ischar(opt(n).highContrast), opt(n).highContrast = true; end
end

end

% =========================================================================
function w = bestEdgeWidth(mg)
% the neighbour distance that matches the boundary width of the image
%
% Differencing two pixels further apart always gives a bigger difference, so
% the variance of the edge transform rises with the width and MAXIMISING it
% just returns the widest tried - measured, it picked 7 of 7 on every image
% of the WC-Co sequence. What it does is rise and then flatten, and it
% flattens once the width exceeds the boundary it is resolving. So the
% saturation point is the estimate, not the peak.

sz = gridSize(mg);

% A central window is enough for a length scale and bounds the cost. It is
% taken at full resolution rather than by striding: a stride aliases exactly
% the sharp edges being measured, and it quantises the answer to multiples
% of itself - on a 768 row map that would leave 6, 12, 18 px and nothing in
% between. Anything smaller than the window is used whole.
probe = subGrid(mg,centred(sz(1),512),centred(sz(2),512));

v = zeros(1,7);
for k = 1:7
  v(k) = var(reshape(edgeMap(probe,k),[],1),'omitnan');
end

% the narrowest width already within a tenth of the plateau
w = find(v >= 0.9*max(v),1);
if isempty(w), w = 1; end

end

% =========================================================================
function idx = centred(n,want)
% the middle want pixels of n, or all of them if there are fewer

if n <= want, idx = 1:n; return; end

first = floor((n-want)/2) + 1;
idx = first:first+want-1;

end

% =========================================================================
% Why registerOn is not measured here
%
% Two criteria were implemented and both failed on a case whose answer is
% known - the WC-Co sequence, where the EBSD-to-image hop must match on
% edges and the three image-to-image hops are better raw.
%
% The median correlation PEAK HEIGHT chose edge for all five, including the
% three known to be better raw. It is the correlation's confidence in one
% tile and depends on that image's own autocorrelation, so it does not
% compare across two different transforms of the same picture.
%
% The SCATTER of the tile shifts about their median chose raw for the EBSD
% hop, which is the one case edges exist for, and cost 8000 indexed points.
% Raw channels of dissimilar images can agree closely with each other and
% still be systematically wrong, locked onto a shared brightness gradient
% rather than onto structure.
%
% So it is stated rather than guessed. 'edge' is the default because it is
% the method's premise - absolute brightness is not comparable between band
% contrast and backscatter, but boundaries appear in both - and 'raw' is the
% exception for a pair that already shares contrast, which whoever collected
% them knows.

% =========================================================================
function [sizePx,shiftPx,featPx] = bestRoiSize(a,b,numROI,sz)
% four times the measured shift, floored by the feature scale
%
% Both bounds are the paper's: a shift beyond about a quarter of the tile
% width falls outside the window the correlation can see, and a tile with
% too few features in it has nothing to lock onto.

roi = coarseRoi(size(a));

[u,peak] = xcfShift(a,b,'ROISize',roi,'numROI',max(4,round(numROI/4)));

ok = isfinite(peak);
if any(ok), shiftPx = median(norm(u(ok))); else, shiftPx = 0; end

featPx = featureScale(a);

% Two bounds, both the paper's, and the second is easy to get wrong.
%
% A shift beyond about a quarter of the tile width falls outside the window
% the correlation can see - that is the first.
%
% The second is that a tile needs several features in it to lock onto. But
% the Hann window tapers the tile to nothing at its edges, so only the
% CENTRAL QUARTER is really contributing: to see a couple of features the
% tile has to be four times as wide as they span. Counting the full width
% instead gave 32 px where 64 was wanted, and hops 3 and 4 measurably worse
% for it.
wanted = max(4*shiftPx, 4*2*featPx);

% powers of two are what the correlation's FFT wants, and what the retry
% steps through
sizePx = 2^ceil(log2(max(wanted,16)));

% never larger than the image can hold a grid of
sizePx = min(sizePx, 2^floor(log2(min(sz)/2)));

end

% =========================================================================
function roi = coarseRoi(sz)
% deliberately large: the coarse pass has to contain whatever shift is
% there, and it is cheap because there are few of them

roi = 2^floor(log2(min(sz)/3));
roi = max(min(roi,256),32);

end

% =========================================================================
function s = featureScale(img)
% the width of the autocorrelation peak, which is the scale of whatever
% structure the image has

img = img - mean(img(:),'omitnan');
img(~isfinite(img)) = 0;

f = abs(fft2(img)).^2;
ac = fftshift(real(ifft2(f)));
ac = ac / max(ac(:));

% the half width along the middle row, which is enough for a length scale
mid = ac(round(size(ac,1)/2)+1,:);
c = round(numel(mid)/2)+1;

k = find(mid(c:end) < 0.5,1);
if isempty(k), s = 1; else, s = k; end

end
