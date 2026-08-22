function check_mapImagePlot(varargin)
% checks on mapImage/plot
%
% The assertions are about graphics objects, so this is the plotting tier
% rather than core. What matters is that an image is drawn where it sits on
% the specimen - so it overlays the map it came from without either being
% permuted - and that the two backends are picked correctly.
%
% Syntax
%   check_mapImagePlot
%
% See also
% mapImage mapImage/plot EBSD/plot

vis = get(0,'DefaultFigureVisible');
set(0,'DefaultFigureVisible','off');
cleanup = onCleanup(@() restore(vis));

checkBackends
checkCoordinates
checkChannels
checkRefusals

end

% =========================================================================
function restore(vis)
close all
set(0,'DefaultFigureVisible',vis);
end

% =========================================================================
function checkBackends
% axis aligned goes to image(), rotated to surface()

figure; h = plot(mapImage(rand(12,17),'dxy',0.4));
assert(isa(h,'matlab.graphics.primitive.Image'),...
  'an axis aligned grid drew a %s, expected an Image',class(h))

% a grid at 45 degrees is still regular, but its pixels are not rows and
% columns of the picture
rot = mapImage(rand(12,17));
rot.d1 = 0.4*normalize(vector3d(1,1,0));
rot.d2 = 0.4*normalize(vector3d(1,-1,0));

figure; h = plot(rot);
assert(isa(h,'matlab.graphics.primitive.Surface'),...
  'a rotated grid drew a %s, expected a Surface',class(h))

end

% =========================================================================
function checkCoordinates
% the image is drawn in micrometres, where the map says it is

[x,y] = ndgrid((0:7)*0.3,(0:10)*0.3);
ebsd = EBSD(vector3d(y(:),x(:),0*x(:)), rotation.rand(numel(x),1), ...
  ones(numel(x),1), {crystalSymmetry('m-3m','mineral','t')}, ...
  struct('bc',(1:numel(x)).'));
ebsd = gridify(ebsd);

mg = mapImage(ebsd.bc,ebsd);

figure; h = plot(mg);

% XData/YData are the true positions, not pixel indices - that is what lets
% it overlay the map without a permutation anywhere
ext = extent(mg);
assert(abs(h.XData(1) - ext(1)) < 1e-9 && abs(h.XData(end) - ext(2)) < 1e-9,...
  'XData is [%g %g], expected [%g %g]',h.XData(1),h.XData(end),ext(1),ext(2))
assert(abs(h.YData(1) - ext(3)) < 1e-9 && abs(h.YData(end) - ext(4)) < 1e-9,...
  'YData is [%g %g], expected [%g %g]',h.YData(1),h.YData(end),ext(3),ext(4))

% and the data itself is not permuted on the way to the screen
assert(isequal(h.CData,mg.img),'plot permuted the image data')

% overlaying the map it came from must not error or move the axes
figure; plot(ebsd,ebsd.bc); hold on; plot(mg,'AlphaData',0.5); hold off

end

% =========================================================================
function checkChannels
% one channel is scalar, three are rgb, anything else needs naming

figure; plot(mapImage(rand(9,9),'dxy',1));
figure; plot(mapImage(rand(9,9,3),'dxy',1));

% a 5 channel forescatter image is a real case and has no single picture
five = mapImage(rand(9,9,5),'dxy',1);

figure; h = plot(five,'channel',2);
assert(isequal(size(h.CData),[9 9]),'naming a channel drew %s',mat2str(size(h.CData)))

% the option is ours and must not reach the graphics call
figure; plot(five,'channel',3,'micronbar','off');

end

% =========================================================================
function checkRefusals
% the two states that have no sensible picture

try
  figure; plot(mapImage(rand(9,9,5),'dxy',1));
  error('a 5 channel image was drawn as a picture')
catch e
  assert(strcmp(e.identifier,'MTEX:mapImage:badChannelCount'),...
    'wrong identifier for a 5 channel image: %s',e.identifier)
end

% a sequence need not share a grid, so there is no one thing to draw
try
  figure; plot([mapImage(rand(4,4),'dxy',1), mapImage(rand(6,6),'dxy',2)]);
  error('an array of images was drawn')
catch e
  assert(strcmp(e.identifier,'MTEX:mapImage:notScalar'),...
    'wrong identifier for an array: %s',e.identifier)
end

end
