function check_xcfShift(varargin)
% checks on xcfShift, the cross correlation primitive
%
% Two things matter here and the first is the sign. u is the displacement
% FROM A TO B - the feature at pos in A is at pos + u in B - because that is
% the direction a spatialTransform is fitted in. Getting it backwards yields
% a plausible looking registration that is wrong by twice the distortion, so
% every case below states the truth as a resampling and checks it comes back.
%
% Syntax
%   check_xcfShift
%
% See also
% xcfShift spatialTransform mapImage

checkSignAndMagnitude
checkSubPixel
checkWeights
checkInvalidRegion
checkMapImage
checkFitsATransform
checkErrors

end

% =========================================================================
function base = texture(n,m,s)
% a smooth random field, sharp enough for the correlation peak to be narrow

if nargin < 3, s = 0.5; end

w = max(3,round(6*s));
k = exp(-((-w:w).^2)/(2*s^2)); k = k/sum(k);

base = conv2(k,k,randn(n,m),'same');

end

% =========================================================================
function checkSignAndMagnitude
% an integer shift of a sharp image comes back exactly, with the right sign

rng(1);
base = texture(300,400);

% B is A displaced: B(i,j) = A(i+2,j+3), so the feature at (i,j) in A sits at
% (i-2,j-3) in B. u is A -> B, so u = (-3,-2) in (x,y)
A = base(21:280, 21:380);
B = base(23:282, 24:383);

u = xcfShift(A,B,'ROISize',64,'numROI',[8 6]);

assert(abs(median(u.x) + 3) < 1e-9 && abs(median(u.y) + 2) < 1e-9,...
  'a (-3,-2) displacement came back as (%+.4f,%+.4f)',median(u.x),median(u.y))

% the other direction has to be the negative, or the sign is not a
% convention but an accident
uBack = xcfShift(B,A,'ROISize',64,'numROI',[8 6]);
assert(abs(median(uBack.x) - 3) < 1e-9 && abs(median(uBack.y) - 2) < 1e-9,...
  'swapping the arguments did not negate u: (%+.4f,%+.4f)',...
  median(uBack.x),median(uBack.y))

% an image against itself has not moved
uSame = xcfShift(A,A,'ROISize',64,'numROI',[8 6]);
assert(max(norm(uSame)) < 1e-9,'an image is displaced from itself by %g',...
  max(norm(uSame)))

end

% =========================================================================
function checkSubPixel
% a fractional shift is recovered well inside a tenth of a pixel

rng(2);
base = texture(400,400,1);

for d = [0.25 0.5 0.75 1.5]

  [X,Y] = meshgrid(1:360,1:260);
  A = base(21:280,21:380);
  B = interp2(base, X+20+d, Y+20+d, 'spline');

  u = xcfShift(A,B,'ROISize',64,'numROI',[8 6]);

  % resampling at +d moves the content the other way, so u is -d
  err = max(abs(median(u.x) + d), abs(median(u.y) + d));

  % the shipped implementation scores about 0.06 px on a real image; on a
  % synthetic one with no noise it should do far better, so a loose bar here
  % would not detect a broken refinement pass
  assert(err < 0.02,'a %.2f px shift was recovered to %.4f px',d,err)

end

end

% =========================================================================
function checkWeights
% the peak height has to separate a tile that correlated from one that could not

rng(4);
base = texture(300,400);

A = base(21:280,21:380);
B = base(23:282,24:383);

% flatten a band of both images - those tiles have nothing to lock onto
A(1:70,:) = 0.5;
B(1:70,:) = 0.5;

[u,peak,pos] = xcfShift(A,B,'ROISize',64,'numROI',[8 6]);

assert(numel(peak) == length(u) && numel(peak) == length(pos),...
  'u, peak and pos disagree in length')

flat = pos.y < 70;
assert(any(flat),'the fixture put no tile in the flat band')

% a flat tile has zero standard deviation and is reported as unusable
assert(all(isnan(peak(flat))),'a featureless tile got a usable peak height')
assert(all(isnan(u.x(flat))),'a featureless tile got a displacement')

good = ~flat & isfinite(peak);
assert(all(peak(good) > 0),'a tile that correlated has a non positive weight')

end

% =========================================================================
function checkInvalidRegion
% only the region where both images have data is tiled

rng(5);
base = texture(300,400);

A = base(21:280,21:380);
B = base(23:282,24:383);

% the padding an earlier resampling leaves behind
A(1:60,:) = NaN;
B(:,1:80) = NaN;

[~,~,pos] = xcfShift(A,B,'ROISize',64,'numROI',[6 5]);

assert(all(pos.y > 60) && all(pos.x > 80),...
  'a tile was placed on padding: min centre (%g,%g)',min(pos.x),min(pos.y))

end

% =========================================================================
function checkMapImage
% given two mapImages the answer is in specimen units, not pixels

rng(6);
base = texture(300,400);

step = 0.25;
A = mapImage(base(21:280,21:380),'dxy',step);
B = mapImage(base(23:282,24:383),'dxy',step);

[u,~,pos] = xcfShift(A,B,'ROISize',64,'numROI',[8 6]);

% the same displacement as the pixel case, scaled by the step
assert(abs(median(u.x) + 3*step) < 1e-9 && abs(median(u.y) + 2*step) < 1e-9,...
  'the mapImage answer is (%+.4f,%+.4f), expected (%+.4f,%+.4f)',...
  median(u.x),median(u.y),-3*step,-2*step)

% and the tile centres are positions on the specimen, inside its extent
ext = extent(A);
assert(all(pos.x >= ext(1) & pos.x <= ext(2) & pos.y >= ext(3) & pos.y <= ext(4)),...
  'a tile centre fell outside the image extent')

end

% =========================================================================
function checkFitsATransform
% the whole point: the output feeds spatialTransform.fit unchanged

rng(7);
base = texture(300,400);

A = base(21:280,21:380);
B = base(23:282,24:383);

[u,peak,pos] = xcfShift(A,B,'ROISize',64,'numROI',[8 6]);

keep = isfinite(peak);
T = spatialTransformShift.fit(pos(keep), pos(keep) + u(keep), 'weights', peak(keep));

% A pure translation, so the linear part is the identity and the offset is u.
% The bars come from the peak refinement grid rather than being tuned: a
% displacement is quantised to 1/XCFMesh = 0.004 px, and a tile disagreeing
% by that much over the ~300 px the centres span perturbs the linear part by
% about 1e-5.
assert(norm(T.M(1:2,1:2) - eye(2),'fro') < 1e-4,...
  'a pure translation fitted a linear part %g from the identity',...
  norm(T.M(1:2,1:2) - eye(2),'fro'))
assert(abs(T.M(1,3) + 3) < 0.01 && abs(T.M(2,3) + 2) < 0.01,...
  'the fitted translation is (%+.4f,%+.4f), expected (-3,-2)',T.M(1,3),T.M(2,3))

end

% =========================================================================
function checkErrors
% the refusals

A = rand(100,120); B = rand(100,120);

try
  xcfShift(A,rand(50,50));
  error('two images of different sizes were correlated')
catch e
  assert(strcmp(e.identifier,'MTEX:xcfShift:sizeMismatch'),...
    'wrong identifier for a size mismatch: %s',e.identifier)
end

try
  xcfShift(A,mapImage(B,'dxy',1));
  error('an array and a mapImage were correlated together')
catch e
  assert(strcmp(e.identifier,'MTEX:xcfShift:mixedInput'),...
    'wrong identifier for mixed input: %s',e.identifier)
end

try
  xcfShift(nan(100,120),B);
  error('two images with no overlap were correlated')
catch e
  assert(strcmp(e.identifier,'MTEX:xcfShift:noOverlap'),...
    'wrong identifier for no overlap: %s',e.identifier)
end

try
  xcfShift(A,B,'ROISize',512);
  error('a tile larger than the image was accepted')
catch e
  assert(strcmp(e.identifier,'MTEX:xcfShift:noROI'),...
    'wrong identifier for an oversized tile: %s',e.identifier)
end

end
