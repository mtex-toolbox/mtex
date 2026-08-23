function check_trueEbsd(varargin)
% the TrueEBSD workflow end to end, and that its automatic settings are measured
%
% Runs the five-map WC-Co sequence through pixelSizeMatch, calcDistortion and
% undistort twice - once with every setting left at 'auto', once tuned by hand
% the way the doc pages tune it - and compares the two.
%
% The bar is not that automatic equals hand tuned. It is that a user who
% specifies nothing gets a registration as good as one who tuned it, and that
% what was chosen is reported so it can be overridden.
%
% Real data, so this is a slow-tier test: mtexdata trueEbsdWCCoSmall is the
% centre half of the WC-Co field of view coarsened 4x, 192 x 256. checkLargeGrid
% covers what that leaves out - edgeWidth is measured over a centred 512 px
% window, so on a 192 x 256 map the window is the whole image and the crop that
% used to raise MTEX:mapImage:notContiguous never runs.
%
% checkSelfSufficient is here because @trueEbsd2 was copied in from the TrueEBSD
% add-on, which is normally on the path alongside MTEX and shadows it. It pins
% the property the copy exists to have: everything the workflow needs resolves
% inside MTEX.
%
% Syntax
%   check_trueEbsd
%
% See also
% trueEbsd2 mapImage spatialTransform xcfShift

checkSelfSufficient
checkAutoAgainstHandTuned
checkLargeGrid

end

% =========================================================================
function checkSelfSufficient
% every piece the workflow needs resolves inside this MTEX installation
%
% Not an absence check on the add-on: a user may legitimately have it
% installed. What matters is which copy answers.

root = mtex_path;

for f = {'trueEbsd2','pairShifts','remapShifted','mapImage','xcfShift', ...
         'spatialTransformShift','spatialTransformDrift','spatialTransformTilt'}
  w = which(f{1});
  assert(~isempty(w),'%s is not on the path',f{1});
  assert(startsWith(w,root), ...
    '%s resolves to %s, outside MTEX - the workflow is not self-contained',f{1},w);
end

end

% =========================================================================
function checkAutoAgainstHandTuned

ebsd = mtexdata('trueEbsdWCCoSmall','silent');
img  = ebsd.opt.trueEbsdImgs;

auto = runJob(ebsd,img,false);
hand = runJob(ebsd,img,true);

% every auto value must be a number by the time calcDistortion returns
assert(all(~cellfun(@ischar,{auto.opt.roiSize})),'a roiSize was left at ''auto''');
assert(all(~cellfun(@ischar,{auto.opt.edgeWidth})),'an edgeWidth was left at ''auto''');

% the doc pages pick 64 px by hand; a factor of two either way is the same choice
assert(all(auto.roi(1:4) >= 16 & auto.roi(1:4) <= 128), ...
  'auto picked tile sizes %s, outside 16..128 px',mat2str(auto.roi));

% a boundary width, not the top of the sweep - the first criterion tried
% maximised variance and always returned 7 of 7
assert(all(auto.edge >= 1 & auto.edge <= 6), ...
  'auto picked edge widths %s, which looks like the end of the sweep',mat2str(auto.edge));

% hop 1 is the EBSD-to-image pair and is intrinsically scattered, so it gets
% more latitude than the image-to-image hops
assert(auto.resid(1) <= hand.resid(1) + 0.35, ...
  'hop 1 residual %.3f px against %.3f hand tuned',auto.resid(1),hand.resid(1));
for n = 3:4
  assert(auto.resid(n) <= hand.resid(n) + 0.15, ...
    'hop %d residual %.3f px against %.3f hand tuned',n,auto.resid(n),hand.resid(n));
end

assert(auto.indexed >= 0.98*hand.indexed, ...
  'auto kept %d indexed points against %d hand tuned',auto.indexed,hand.indexed);
assert(auto.corr >= hand.corr - 0.005, ...
  'auto scored corr %.4f against %.4f hand tuned',auto.corr,hand.corr);

% a measurement, not a draw
again = runJob(ebsd,img,false);
assert(isequal(again.roi,auto.roi) && isequal(again.edge,auto.edge), ...
  'auto chose different values on a second run');

% what was chosen has to be reported, and the numbers reported have to be the
% ones used - checking for the word 'auto' only tested the wording
txt = evalc('runVerbose(ebsd,img)');
assert(contains(txt,'edgeWidth') && contains(txt,'roiSize'), ...
  'calcDistortion did not report the settings it measured');
assert(contains(txt,'setOptions'), ...
  'the report does not say how to override what was measured');
assert(contains(txt,strjoin(compose('%d',auto.edge),' ')), ...
  'the reported edge widths are not the %s px it used',mat2str(auto.edge));

% roiSize gets no such check: the note reports what was MEASURED and the retry
% then doubles it where a hop did not converge

end

% =========================================================================
function checkLargeGrid
% a grid larger than the window edgeWidth is measured over
%
% The window used to be taken by striding, and subGrid refuses a stride, so
% auto edgeWidth raised MTEX:mapImage:notContiguous on every full-size map -
% invisible at 192 x 256, where the stride is 1. Padding the same content out
% symmetrically leaves the centred window byte for byte identical, so the
% measured width must be identical too; a stride fails that even without the
% error, because it grows with the grid.

base = blockyImage(640);

% 192 + 640 + 192: centred(640,512) is rows 65:576 and centred(1024,512) is
% rows 257:768, and 257-192 == 65, so both windows see the same pixels
big = zeros(1024,1024);
big(193:832,193:832) = base;

small = measureEdge(base);
large = measureEdge(big);

assert(all(small.grid > 512) && all(large.grid > 512), ...
  'grids came back %s and %s - at most 512 either way nothing is cropped', ...
  mat2str(small.grid),mat2str(large.grid));

assert(all(isfinite(small.edge)) && all(small.edge > 0), ...
  'edgeWidth came back %s on a %s grid',mat2str(small.edge),mat2str(small.grid));

assert(isequal(small.edge,large.edge), ...
  ['the measured edgeWidth moved from %s to %s when the same content was ' ...
   'padded out around it, so the window is not a centred crop'], ...
  mat2str(small.edge),mat2str(large.edge));

end

% =========================================================================
function out = measureEdge(im)
% one two-map job carrying im twice, taken as far as the measurement
%
% The pair is the identity, so nothing is fitted and the cost is all autoTune.

px = 0.05;

L = [mapImage(im,'dxy',px,'name','a'), mapImage(im,'dxy',px,'name','b')];

job = trueEbsd2(L,spatialTransformId);
job.pixelSizeMatch(px);
evalc('job.calcDistortion');

out.grid = gridSize(job.resizedList(1));
out.edge = round([job.opt.edgeWidth]/px);

end

% =========================================================================
function im = blockyImage(n)
% blocks with a definite width, softened so the edges are a few pixels wide

rng(42,'twister');

b = 16;
im = kron(rand(ceil(n/b)),ones(b));
im = im(1:n,1:n);

% a 3 px box blur, so the boundaries have a width to find
im = conv2(im,ones(3)/9,'same');

end

% =========================================================================
function out = runJob(ebsd,img,byHand)

job = buildJob(ebsd,img);
job.pixelSizeMatch(0);

px = job.resizedList(1).dx;
job.setOptions('numROI',16);

if byHand
  job.setOptions('roiSize',64*px,'edgeWidth',5*px);
  job.setOptions(1,'edgeWidth',3*px);
  job.setOptions(5,'edgeWidth',3*px,'roiSize',0);
end

evalc('job.calcDistortion(''fitErr'')');
evalc('job.undistort');

out.opt   = job.opt;
out.roi   = round([job.opt.roiSize]/px);
out.edge  = round([job.opt.edgeWidth]/px);
out.resid = arrayfun(@(n) residOf(job,n,px),1:4);

e = job.undistortedList(1).ebsd; i = job.undistortedList(1).img;
ok = ~isnan(e.bc(:)) & ~isnan(i(:));
out.indexed = nnz(e.isIndexed);
out.corr    = corr(double(e.bc(ok)),double(i(ok)));

end

% =========================================================================
function runVerbose(ebsd,img)
job = buildJob(ebsd,img);
job.pixelSizeMatch(0);
job.setOptions('numROI',16);
job.calcDistortion('fitErr');
end

% =========================================================================
function job = buildJob(ebsd,img)

px = img.pixSzImg;
L = [mapImage(ebsd.bc,ebsd,'name','bcImg'), ...
     mapImage(img.fsdB3, 'dxy',px,'name','fsdB3'), ...
     mapImage(img.fsdT3, 'dxy',px,'name','fsdT3'), ...
     mapImage(img.fsdT1, 'dxy',px,'name','fsdT1'), ...
     mapImage(img.fsdT10,'dxy',px,'name','fsdT10')];
L(2:end) = rescale(imboxfilt(L(2:end),3));

% + and not *: an unfitted prototype has zero coefficients, so it reports
% itself as the identity and mtimes would absorb the shift away
job = trueEbsd2(L,[spatialTransformShift + spatialTransformDrift, ...
   spatialTransformId, spatialTransformShift, spatialTransformTilt]);

end

% =========================================================================
function r = residOf(job,n,px)
fe = job.fitError(n);
if isempty(fe.xShiftsXcf), r = NaN; return; end
r = mean(sqrt((fe.xShiftsXcf(:)/px).^2 + (fe.yShiftsXcf(:)/px).^2),'omitnan');
end
