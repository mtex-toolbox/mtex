function check_mapImage(varargin)
% checks on mapImage - a regular grid that knows where it sits
%
% The class exists so an image and an EBSD map can be compared pixel by
% pixel, so most of what is tested here is that the geometry and the array
% agree: pos derived from the origin and the steps lands on the map's own
% positions, cropping moves the corner, and relaying the array out turns the
% map with it.
%
% Syntax
%   check_mapImage
%
% See also
% mapImage EBSDsquare gridLayout

checkConstruction
checkFromMap
checkScanUnit
checkFrameIsCopied
checkPosAndIndex
checkExtent
checkSize
checkInterp
checkSubGrid
checkRelayout
checkEdgeMap
checkRescale
checkBoxFilter
checkDisplay
checkErrors

end

% =========================================================================
function checkEdgeMap
% the edge transform, and the percentile it normalises by

% a step edge - the boundary lights up and the flat regions do not
img = zeros(20,20); img(:,11:end) = 1;
e = edgeMap(mapImage(img,'dxy',1));

assert(isequal(size(e),[20 20]),'edgeMap returned %s',mat2str(size(e)))
assert(all(e(:,10) > 0) && all(e(:,11) > 0),'the step itself did not light up')

% away from the step AND away from the image border, since a pixel whose
% neighbour is off the image differences against zero - so the border of the
% bright half lights up too, deliberately
in = 2:19;
assert(all(e(in,2:9) == 0,'all') && all(e(in,12:19) == 0,'all'),...
  'the flat interior of a step is not flat in the edge map')

% that border behaviour is the documented choice, so pin it: the bright half
% differences against the padding, the dark half has nothing to differ from
assert(all(e(1,12:19) > 0),'the border of the bright region did not light up')
assert(all(e(1,2:9) == 0),'the border of the dark region lit up against zero')

% the scale does not depend on the channel count - a greyscale image and the
% same values in three channels differ only by the sqrt(3) of the norm
grey = rand(15,18);
e1 = edgeMap(mapImage(grey,'dxy',1));
e3 = edgeMap(mapImage(repmat(grey,1,1,3),'dxy',1));
assert(max(abs(e3 - sqrt(3)*e1),[],'all') < 1e-12,...
  'three identical channels are not sqrt(3) times one')

% a flat image has no edges inside it, and must not divide by a zero range.
% Its border is a different matter - see above, the padding is zero and the
% image is not, so the frame lights up whatever the image
flat = edgeMap(mapImage(0.5*ones(10,10),'dxy',1));
assert(all(flat(2:9,2:9) == 0,'all'),'a constant image produced interior edges')
assert(all(isfinite(flat(:))),'a constant image produced non finite values')

% padWidth reaches further
wide = edgeMap(mapImage(img,'dxy',1),3);
assert(nnz(any(wide > 0,1)) > nnz(any(e > 0,1)),...
  'a larger padWidth did not widen the edge')

end

% =========================================================================
function checkRescale
% stretch to a range, over an array, without inventing values

rng(3);
a = mapImage(2+3*rand(9,11),'dxy',1);
b = mapImage(-5*rand(6,6),'dxy',1);

arr = rescale([a b]);
assert(numel(arr) == 2,'rescale did not return the whole array')

for k = 1:2
  v = arr(k).img;
  assert(abs(min(v(:))) < 1e-12 && abs(max(v(:))-1) < 1e-12,...
    'entry %d is on [%g %g], expected [0 1]',k,min(v(:)),max(v(:)))
end

% a stated range
r = rescale(a,-1,1);
assert(abs(min(r.img(:))+1) < 1e-12 && abs(max(r.img(:))-1) < 1e-12,...
  'a stated range was not used')

% channels move together by default, so the colour balance survives
rgb = mapImage(cat(3,rand(8,8),0.5*rand(8,8),0.1*rand(8,8)),'dxy',1);
together = rescale(rgb);
mx = squeeze(max(together.img,[],[1 2]));
assert(max(mx) > 0.99 && min(mx) < 0.9,...
  'the channels were rescaled separately by default')

apart = rescale(rgb,'perChannel');
mx = squeeze(max(apart.img,[],[1 2]));
assert(all(abs(mx-1) < 1e-12),'''perChannel'' did not rescale each channel')

% a flat image has no range and must not be divided by zero
flat = rescale(mapImage(0.5*ones(5,5),'dxy',1));
assert(all(flat.img(:) == 0.5) && all(isfinite(flat.img(:))),...
  'a constant image was not left alone')

% padding neither skews the range nor becomes a number
withNaN = mapImage([1 2 NaN; 3 4 5],'dxy',1);
rn = rescale(withNaN);
assert(isnan(rn.img(1,3)),'rescale filled in a NaN')
assert(abs(max(rn.img(:),[],'omitnan')-1) < 1e-12,'NaN skewed the range')

end

% =========================================================================
function checkBoxFilter
% the box filter, over an array, and its deliberate NaN behaviour

rng(4);
a = mapImage(randn(20,26),'dxy',1);
b = mapImage(randn(13,13,3),'dxy',1);

arr = imboxfilt([a b],5);
assert(numel(arr) == 2,'imboxfilt did not return the whole array')
assert(isequal(gridSize(arr(1)),gridSize(a)) && arr(2).nChannel == 3,...
  'imboxfilt changed a shape')

% a constant image is its own box mean, which is the check that the border
% is replicated rather than zero padded
flat = imboxfilt(mapImage(7*ones(9,9),'dxy',1),3);
assert(max(abs(flat.img(:)-7)) < 1e-12,...
  'a constant image was not preserved - the border is not replicated')

% separability: a box mean of a box mean is not the same filter, but a
% single box has to reproduce a hand computed interior value
v = reshape(1:25,5,5); mv = imboxfilt(mapImage(v,'dxy',1),3);
assert(abs(mv.img(3,3) - mean(v(2:4,2:4),'all')) < 1e-12,...
  'the interior box mean is wrong')

% NaN is excluded, not propagated - a resampled map is padded with it
n = [1 2 3; 4 NaN 6; 7 8 9];
mn = imboxfilt(mapImage(n,'dxy',1),3);
assert(all(isfinite(mn.img(:))),...
  'a single NaN spread over the neighbourhood instead of being excluded')
assert(abs(mn.img(2,2) - mean([1 2 3 4 6 7 8 9])) < 1e-12,...
  'the centre is not the mean of the finite values around it')

% only where nothing finite was under the box does it stay NaN
allNaN = imboxfilt(mapImage(nan(7,7),'dxy',1),3);
assert(all(isnan(allNaN.img(:))),'an all NaN image came back finite')

try
  imboxfilt(a,4);
  error('an even box size was accepted')
catch e
  assert(strcmp(e.identifier,'MTEX:mapImage:badBoxSize'),...
    'wrong identifier for an even box: %s',e.identifier)
end

end

% =========================================================================
function checkDisplay
% display has to survive every state a mapImage can be in
%
% It did not: it looped over length(mg) while size and numel had been
% overloaded to mean the GRID, so a scalar image displayed its pixels as
% though they were objects, and an array could not be displayed at all. A
% default constructed entry then broke it again on the empty frame.

d = 0.3; ebsd = makeMap(6,d);

states = {mapImage, ...                                  % nothing set
          mapImage(rand(4,5),'dxy',0.2), ...             % no map, no name
          mapImage(rand(4,5,3),'dxy',0.2,'name','rgb'), ...
          mapImage(ebsd.bc,ebsd,'name','bc'), ...        % carries a map
          [mapImage(rand(3,3),'dxy',1), mapImage], ...   % array with a gap
          mapImage.empty};

for k = 1:numel(states)
  try
    txt = evalc('display(states{k})');
  catch e
    error('display failed on state %d: %s',k,e.message);
  end
  assert(~isempty(txt),'display produced nothing for state %d',k)
end

end

% =========================================================================
function ebsd = makeMap(n,d,nc)
% a small map on a square lattice, n rows by nc columns at step d
%
% Rectangular by default, so that anything which transposes the array
% without transposing the geometry shows up as a size mismatch rather than
% passing unnoticed.

if nargin < 3, nc = n + 3; end

[x,y] = ndgrid((0:n-1)*d,(0:nc-1)*d);

% a band contrast that differs in every pixel, so anything that permutes the
% array without permuting the values shows up
bc = reshape(1:numel(x),size(x));

ebsd = EBSD(vector3d(y(:),x(:),0*x(:)), rotation.rand(numel(x),1), ...
  ones(numel(x),1), {crystalSymmetry('m-3m','mineral','testPhase')}, ...
  struct('bc',bc(:)));
ebsd = gridify(ebsd);

end

% =========================================================================
function checkConstruction
% an image with no map gets its own frame and the step it was given

img = rand(7,11);
mg = mapImage(img,'dxy',[0.5 0.25],'name','bse');

assert(isequal(gridSize(mg),[7 11]),'gridSize is %s, expected [7 11]',mat2str(gridSize(mg)))
assert(mg.nChannel == 1,'a 2d array has %d channels',mg.nChannel)
assert(strcmp(mg.name,'bse'),'the name did not survive construction')
assert(abs(mg.dx - 0.5) < 1e-12 && abs(mg.dy - 0.25) < 1e-12,...
  'step is %g × %g, expected 0.5 × 0.25',mg.dx,mg.dy)
assert(max(abs(double(mg) - img),[],'all') == 0,'double(mg) is not the image')

% a scalar dxy means square pixels
sq = mapImage(img,'dxy',0.3);
assert(abs(sq.dx - sq.dy) < 1e-12,'a scalar dxy gave non square pixels')

% integer types are scaled the way im2double would
u8 = mapImage(uint8([0 128; 255 64]));
assert(abs(max(u8.img,[],'all') - 1) < 1e-12,'uint8 was not scaled to [0,1]')

% channels are kept
rgb = mapImage(rand(4,5,3));
assert(rgb.nChannel == 3,'a 3 channel image reports %d',rgb.nChannel)
assert(isequal(gridSize(rgb),[4 5]),'gridSize should be the grid')

end

% =========================================================================
function checkFromMap
% built on a map, the geometry comes from the map and matches it exactly

d = 0.3; ebsd = makeMap(9,d);
mg = mapImage(ebsd.bc,ebsd);

assert(isequal(gridSize(mg),size(ebsd)),'the image and the map disagree on size')
assert(abs(mg.dx - norm(ebsd.d2)) < 1e-12 && abs(mg.dy - norm(ebsd.d1)) < 1e-12,...
  'the step was not taken from the map')

% the derived positions have to be the map's own, not merely similar
assert(max(norm(mg.pos - ebsd.pos),[],'all') < 1e-12,...
  'the derived pos differs from the map by %g',max(norm(mg.pos - ebsd.pos),[],'all'))

% and the layout the array is in is the one the map states
assert(isAligned(mg.layout,gridLayout(ebsd.d1,ebsd.d2)),...
  'the layout disagrees with the map''s own d1/d2')

end

% =========================================================================
function checkScanUnit
% the unit of the positions travels with the image
%
% Every other spatial class - @EBSD, @grain2d, @grainBoundary - carries
% scanUnit. @mapImage did not, and plot hardcoded 'um', so a map in nm
% rendered and printed as micrometres regardless.

d = 0.3; ebsd = makeMap(6,d);
ebsd.scanUnit = 'nm';

mg = mapImage(ebsd.bc,ebsd,'name','bc');
assert(strcmp(mg.scanUnit,'nm'),...
  'the unit was not taken from the map, it is ''%s''',mg.scanUnit)

% and it survives everything that rebuilds the entry
assert(strcmp(subGrid(mg,2:5,2:6).scanUnit,'nm'),'subGrid lost the unit')
turned = transformReferenceFrame(mg,gridLayout(mg.d2,-mg.d1));
assert(strcmp(turned.scanUnit,'nm'),'transformReferenceFrame lost the unit')

% it reaches the display, which is where a wrong unit would mislead
txt = evalc('display(mg)');
assert(contains(txt,'nm'),'display does not show the unit')

% an image with no map keeps the default, or takes what it is given
assert(strcmp(mapImage(rand(4,4),'dxy',1).scanUnit,'um'),'the default is not um')
assert(strcmp(mapImage(rand(4,4),'dxy',1,'scanUnit','mm').scanUnit,'mm'),...
  '''scanUnit'' was not accepted')

end

% =========================================================================
function checkFrameIsCopied
% framing an image must not reach back into the caller's map

other = plottingConvention(vector3d.Z,vector3d.X);

% a map that carries a frame - the handle must not be shared
ebsd = makeMap(6,0.3);
ebsd.pos.frame = specimenFrame;
mg = mapImage(ebsd.bc,ebsd);

assert(mg.frame ~= ebsd.frame,'the frame handle was adopted rather than copied')

before = char(ebsd.how2plot);
mg.frame.how2plot = other;
assert(strcmp(char(ebsd.how2plot),before),...
  'framing the image restated the map''s own convention')

% and the other way round, so neither side can reach the other
fr = ebsd.frame;
fr.how2plot = plottingConvention(vector3d.X,vector3d.Y);
assert(strcmp(char(mg.how2plot),char(other)),...
  'reframing the map changed the image')

% a frame free map has nothing to copy and follows the session default,
% which must also be a copy rather than the default itself
bare = makeMap(4,0.3);
assert(isempty(bare.frame),'the bare fixture unexpectedly carries a frame')

mb = mapImage(bare.bc,bare);
assert(~isempty(mb.frame),'a frame free map produced a frame free image')

sessionBefore = char(specimenFrame.default.how2plot);
mb.frame.how2plot = other;
assert(strcmp(char(specimenFrame.default.how2plot),sessionBefore),...
  'framing the image restated the session default')

end

% =========================================================================
function checkPosAndIndex
% pos and pos2ind are inverse where they should be

mg = mapImage(rand(8,13),'dxy',[0.5 0.25]);

p = mg.pos;
[i,j] = pos2ind(mg,p);

[ii,jj] = ndgrid(1:8,1:13);
assert(isequal(i,ii) && isequal(j,jj),...
  'pos2ind did not return each pixel to its own index')

% a position between pixels rounds to the nearer one
mid = mg.origin + 0.4*mg.d1 + 0.6*mg.d2;
[i1,j1] = pos2ind(mg,mid);
assert(i1 == 1 && j1 == 2,'rounding gave (%d,%d), expected (1,2)',i1,j1)

% outside the grid the index is reported but flagged
[~,~,inside] = pos2ind(mg,mg.origin - 5*mg.d1);
assert(~inside,'a position off the grid was reported as inside')

ind = pos2ind(mg,mg.origin - 5*mg.d1);
assert(isnan(ind),'the linear index off the grid is not NaN')

end

% =========================================================================
function checkExtent
% the bounds are the corners, and they follow a crop

mg = mapImage(rand(5,9),'dxy',[2 3]);
ext = extent(mg);

% the combined form is [xmin xmax ymin ymax zmin zmax], as @EBSD returns
assert(numel(ext) == 6,'extent returned %d values, expected 6',numel(ext))
assert(abs(ext(2) - ext(1) - 8*2) < 1e-12,'x extent is %g, expected %g',...
  ext(2)-ext(1),8*2)
assert(abs(ext(4) - ext(3) - 4*3) < 1e-12,'y extent is %g, expected %g',...
  ext(4)-ext(3),4*3)

[xmin,xmax,ymin,ymax] = extent(mg);
assert(isequal([xmin xmax ymin ymax],ext(1:4)),'the two extent forms disagree')
assert(isequal(extent(mg,1:4),ext(1:4)),'the ind form disagrees')

% and it agrees with the map it was built on, which is the point
d = 0.3; ebsd = makeMap(7,d);
assert(max(abs(extent(mapImage(ebsd.bc,ebsd)) - extent(ebsd))) < 1e-12,...
  'the image and the map it came from report different extents')

end

% =========================================================================
function checkSize
% size reports the grid, in every form MATLAB offers

mg = mapImage(rand(4,9,3),'dxy',0.5);

assert(isequal(gridSize(mg),[4 9]),'gridSize is %s',mat2str(gridSize(mg)))
assert(gridSize(mg,1) == 4 && gridSize(mg,2) == 9,'gridSize(mg,dim) is wrong')
assert(gridSize(mg,3) == 1,'gridSize(mg,3) should be 1 - channels are nChannel')

[r,c] = gridSize(mg);
assert(r == 4 && c == 9,'[r,c] = gridSize(mg) is wrong')

% size, numel and length have to keep describing the OBJECT ARRAY, or a
% sequence of images cannot be one. This is where mapImage parts company
% with @EBSD, which overloads them to mean the map
assert(isscalar(mg),'a single mapImage is not scalar')

arr = [mg, mapImage(rand(3,3),'dxy',1)];
assert(numel(arr) == 2 && length(arr) == 2 && isequal(size(arr),[1 2]),...
  'an array of 2 images reports numel %d, length %d, size %s',...
  numel(arr),length(arr),mat2str(size(arr)))
assert(isequal(gridSize(arr(2)),[3 3]),'indexing the array gave the wrong image')

assert(isempty(mapImage.empty),'an empty mapImage array is not empty')

end

% =========================================================================
function checkInterp
% sampling at the pixel centres returns the pixels, and outside returns NaN

img = rand(10,14);
mg = mapImage(img,'dxy',[0.4 0.7]);

v = interp(mg,mg.pos);
assert(max(abs(v - img),[],'all') < 1e-12,...
  'interp at the pixel centres is off by %g',max(abs(v - img),[],'all'))

% halfway between two pixels, linearly
mid = mg.origin + 0.5*mg.d2;
assert(abs(interp(mg,mid) - mean(img(1,1:2))) < 1e-12,...
  'interp between two pixels is not their mean')

% no measurement outside, and no invented one
assert(isnan(interp(mg,mg.origin - 3*mg.d1)),'interp extrapolated silently')

% channels come back stacked
rgb = mapImage(rand(6,8,3),'dxy',0.5);
vv = interp(rgb,rgb.pos);
assert(isequal(size(vv),[6 8 3]),'multi channel interp returned %s',mat2str(size(vv)))
assert(max(abs(vv - rgb.img),[],'all') < 1e-12,'multi channel interp lost values')

end

% =========================================================================
function checkSubGrid
% cropping moves the corner and takes the map with it

d = 0.3; ebsd = makeMap(10,d);
mg = mapImage(ebsd.bc,ebsd);

sub = subGrid(mg,3:7,4:9);

assert(isequal(gridSize(sub),[5 6]),'the crop is %s, expected [5 6]',mat2str(gridSize(sub)))
assert(max(abs(sub.img - mg.img(3:7,4:9)),[],'all') == 0,'the crop took the wrong pixels')

% the geometry has to follow, or the crop no longer says where it is
assert(norm(sub.origin - mg.pos(3,4)) < 1e-12,...
  'the origin did not move with the crop')
assert(max(norm(sub.pos - mg.pos(3:7,4:9)),[],'all') < 1e-12,...
  'the cropped positions are not the ones cropped out')

% and the map is cropped the same way
assert(isequal(size(sub.ebsd),[5 6]),'the map was not cropped with the image')

% a mask takes its bounding box
mask = false(10,10); mask(4:6,2:8) = true;
mb = subGrid(mg,mask);
assert(isequal(gridSize(mb),[3 7]),'the mask crop is %s, expected [3 7]',mat2str(gridSize(mb)))

end

% =========================================================================
function checkRelayout
% turning the array to face another way moves nothing on the specimen

d = 0.3; ebsd = makeMap(8,d);   % 8 × 11, so a transpose is visible
mg = mapImage(ebsd.bc,ebsd);

target = gridLayout(mg.d2,-mg.d1);   % a quarter turn from where it is
turned = transformReferenceFrame(mg,target);

assert(isAligned(turned.layout,target),...
  'the array was not laid out the way asked for')

assert(isequal(gridSize(turned),flip(gridSize(mg))),...
  'a quarter turn left the array %s, expected %s',...
  mat2str(gridSize(turned)),mat2str(flip(gridSize(mg))))

% every pixel still covers the same piece of specimen, so the two position
% sets agree as SETS - sortrows, not sort, or x and y would be compared
% independently and a mismatched pairing would pass
before = sortrows([mg.pos.x(:), mg.pos.y(:)]);
after = sortrows([turned.pos.x(:), turned.pos.y(:)]);
assert(max(abs(before - after),[],'all') < 1e-12,...
  'relaying the array out moved pixels on the specimen')

% the step lengths swap with the axes, which a square fixture would hide
assert(abs(turned.dx - mg.dy) < 1e-12 && abs(turned.dy - mg.dx) < 1e-12,...
  'the step lengths did not follow the transpose')

% the new origin is worth pinning outright rather than only via the round
% trip. Columns now run along -d1, so the corner that ends up at (1,1) is
% the one at the far end of the old rows
sz = gridSize(mg);
assert(norm(turned.origin - mg.pos(sz(1),1)) < 1e-12,...
  'the new origin is not the corner the flips brought to the front')

% and value and position stayed together, which is the whole point
[i,j] = pos2ind(turned,mg.pos(2,3));
assert(abs(turned.img(i,j) - mg.img(2,3)) < 1e-12,...
  'a pixel and its position came apart in the relayout')

% the map came too
assert(isequal(size(turned.ebsd),gridSize(turned)),...
  'the map was not turned with the image')
assert(max(abs(turned.ebsd.bc - turned.img),[],'all') < 1e-12,...
  'the map and the image are no longer in the same order')

% turning it back is the identity
back = transformReferenceFrame(turned,mg.layout);
assert(isequal(gridSize(back),gridSize(mg)) && ...
  max(abs(back.img - mg.img),[],'all') < 1e-12,'the relayout does not round trip')
assert(norm(back.origin - mg.origin) < 1e-12,'the origin did not round trip')

end

% =========================================================================
function checkErrors
% the refusals are the ones the design depends on

ebsd = makeMap(6,0.3);

try
  mapImage(rand(5,5),ebsd);
  error('an image was accepted on a map of a different size')
catch e
  assert(strcmp(e.identifier,'MTEX:mapImage:sizeMismatch'),...
    'wrong identifier for a size mismatch: %s',e.identifier)
end

try
  mapImage(rand(6,6),'name','not a varname');
  error('an invalid identifier was accepted as a name')
catch e
  assert(strcmp(e.identifier,'MTEX:mapImage:badName'),...
    'wrong identifier for a bad name: %s',e.identifier)
end

try
  mapImage(rand(4,4,2,2));
  error('a 4d array was accepted as an image')
catch e
  assert(strcmp(e.identifier,'MTEX:mapImage:tooManyDimensions'),...
    'wrong identifier for a 4d array: %s',e.identifier)
end

try
  subGrid(mapImage(rand(5,5)),[1 3 4],1:2);
  error('a non contiguous crop was accepted')
catch e
  assert(strcmp(e.identifier,'MTEX:mapImage:notContiguous'),...
    'wrong identifier for a non contiguous crop: %s',e.identifier)
end

end
