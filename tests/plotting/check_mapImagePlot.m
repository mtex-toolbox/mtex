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
checkScaling
checkArray
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
function checkScaling
% the colour scale has to follow the data, whatever range it is on
%
% image() maps CData through the colormap by VALUE unless told otherwise, so
% an image on [0,1] - which is what rescale returns - used to land entirely
% on the first colormap row and come out uniform, while one on [38,180]
% happened to look right.

rng(11);

for rangeCase = {[0 1],[38 180],[-3 -1]}
  r = rangeCase{1};
  v = r(1) + (r(2)-r(1))*rand(20,25);

  figure; h = plot(mapImage(v,'dxy',1));

  assert(strcmp(h.CDataMapping,'scaled'),...
    'CData on [%g %g] is mapped ''%s'', which ignores the colour limits',...
    r(1),r(2),h.CDataMapping)

  ax = ancestor(h,'axes');
  assert(abs(ax.CLim(1)-min(v(:))) < 1e-9 && abs(ax.CLim(2)-max(v(:))) < 1e-9,...
    'CLim is [%g %g] for data on [%g %g]',ax.CLim,min(v(:)),max(v(:)))
end

% a flat image has no range, and CLim must not be set to a degenerate one
figure; hf = plot(mapImage(0.5*ones(8,8),'dxy',1));
axf = ancestor(hf,'axes');
assert(axf.CLim(2) > axf.CLim(1),'a constant image gave CLim %s',mat2str(axf.CLim))

% grey by default - an image is a picture, not a scalar field
figure; hg = plot(mapImage(rand(9,9),'dxy',1));
cm = colormap(ancestor(hg,'axes'));
assert(max(abs(cm(:,1)-cm(:,2))) < 1e-9 && max(abs(cm(:,2)-cm(:,3))) < 1e-9,...
  'the default colormap is not grey')

end

% =========================================================================
function checkArray
% an array of images gets one axis each, named

seq = [mapImage(rand(10,12),'dxy',0.5,'name','a'), ...
       mapImage(rand(10,12),'dxy',0.5,'name','b'), ...
       mapImage(rand(8,8),  'dxy',1.0,'name','c')];

figure; h = plot(seq);

assert(numel(h) == 3,'plotting 3 images returned %d handles',numel(h))

ax = findobj(gcf,'Type','axes');
assert(numel(ax) >= 3,'3 images drew %d axes',numel(ax))

titles = sort(string(arrayfun(@(a) string(a.Title.String),ax)));
assert(all(ismember(["a" "b" "c"],titles)),...
  'the axes are not named after the images: %s',strjoin(titles,', '))

% a single image is not titled - it needs no distinguishing
figure; plot(seq(1));
ax1 = findobj(gcf,'Type','axes');
assert(isempty(char(ax1(1).Title.String)),'a lone image was given a title')

% the edge flag draws the transform rather than the values
figure; he = plot(seq(1),'edge');
assert(max(abs(he.CData - edgeMap(seq(1))),[],'all') < 1e-12,...
  '''edge'' did not draw the edge transform')

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
% the state that has no sensible picture

try
  figure; plot(mapImage(rand(9,9,5),'dxy',1));
  error('a 5 channel image was drawn as a picture')
catch e
  assert(strcmp(e.identifier,'MTEX:mapImage:badChannelCount'),...
    'wrong identifier for a 5 channel image: %s',e.identifier)
end

% a sequence whose entries do not share a grid is still fine - one axis each
figure; plot([mapImage(rand(4,4),'dxy',1), mapImage(rand(6,6),'dxy',2)]);

end
