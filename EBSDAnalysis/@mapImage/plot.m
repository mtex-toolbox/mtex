function [h,mP] = plot(mg,varargin)
% plot one image, or a whole sequence, on its specimen coordinates
%
% Draws each image where it sits on the specimen, in micrometres rather than
% pixels, with the screen orientation taken from its frame. So an image and
% the map it is aligned to plot on top of each other without either being
% permuted first - MTEX moves the camera, not the data.
%
% Given an array, one axis per image, named by mg(k).name. That is the quick
% check that a sequence covers the same area and is stored the same way up.
%
% Syntax
%
%   plot(mg)
%   plot(imgList)                      % one axis per image
%   plot(imgList,'edge')               % the edge transform of each
%   plot(mg,'channel',2)
%   plot(mg,'micronbar','off')
%
%   plot(ebsd,ebsd.bc); hold on; plot(mg,'AlphaData',0.5)
%
% Input
%  mg - @mapImage, one or an array
%
% Output
%  h  - handle to the graphics object, one per image
%  mP - @mapPlot of the last axis
%
% Options
%  channel   - which channel to draw, default all of them
%  micronbar - 'on'/'off'
%  figSize   - 'huge' (the default here), 'large', 'normal', 'small', 'tiny'
%              or a fraction of the screen. A new figure is made full screen,
%              because a sequence tiles one axis per image and the usual
%              default leaves each too small to read
%
% Flags
%  edge - draw edgeMap(mg) instead of the values, which is what a
%         registration actually matches on. Contrast is stretched over the
%         2nd to 98th percentile rather than the full range, because an edge
%         transform's bright tail would otherwise crush the picture to black
%
% Description
% One channel is drawn as a scalar field through the current colormap; three
% are drawn as RGB. Any other channel count has no single meaning as a
% picture, so name a channel.
%
% See also
% mapImage mapImage/edgeMap EBSD/plot

if isempty(mg), return; end

[mtexFig,newFigure] = newMtexFigure(varargin{:});

h = gobjects(1,numel(mg));

for k = 1:numel(mg)

  if k > 1, mtexFig.nextAxis; end

  [h(k),mP] = plotOne(mg(k),mtexFig,varargin{:});

  % a sequence is worth labelling, a single image speaks for itself
  if ~isscalar(mg) && ~isempty(mg(k).name)
    title(mP.ax,mg(k).name);
  end

end

% An image is there to be looked at, and a sequence of them tiles into one
% axis each, so the default figure leaves every panel too small to read. Take
% the whole screen. get_option keeps the LAST match, so an explicit figSize
% still wins, and a figure that already existed is left as the user sized it
% rather than being resized underneath a hold.
if newFigure
  mtexFig.drawNow('figSize','huge',varargin{:});
else
  mtexFig.drawNow(varargin{:});
end

if nargout == 0, clear h; end

end

% =========================================================================
function [h,mP] = plotOne(mg,mtexFig,varargin)

mP = newMapPlot('scanUnit',mg.scanUnit,'parent',mtexFig.gca,varargin{:}, ...
  mg.how2plot,mg.frame);

if check_option(varargin,'edge')
  d = edgeMap(mg);
else
  d = mg.img;
end

ch = get_option(varargin,'channel',[]);
if ~isempty(ch), d = d(:,:,ch); end

assert(size(d,3) == 1 || size(d,3) == 3,'MTEX:mapImage:badChannelCount',...
  ['A %d channel image is not a picture on its own. Name one with '...
  '''channel'',k, or take three for RGB.'],size(d,3));

% rgb has to be in [0,1] or image() clips it without saying so
if size(d,3) == 3, d = rescale(d); end

pos = mg.pos;

% Colour limits, decided before the branch so both ways of drawing get them -
% surface() would otherwise be left on CLimMode auto, which is the full range
% again.
%
% An edge transform is not a picture: it is heavily right skewed, a thin tail
% of bright boundary pixels over a bulk near zero. Scaling it to its full
% range lets the tail set the top, and on WC-Co that puts 85-90% of every
% forescatter panel in the bottom tenth of the colormap - the boundaries are
% all there, and the figure reads as black. Scale it the way edgeMap scales
% its own input instead. A real image keeps its true range, which is what a
% picture wants.
[lo,hi] = deal(NaN);
if size(d,3) == 1
  if check_option(varargin,'edge')
    lim = percentileOf(d,[2 98]);
    lo = lim(1); hi = lim(2);
  else
    lo = min(d,[],'all'); hi = max(d,[],'all');
  end
end

if isAxisAligned(mg)

  % the fast path - a regular axis aligned grid is what image() draws, and
  % XData/YData carry the true coordinates so no permutation is needed
  % 'scaled', not image()'s default of 'direct'. Direct mapping indexes the
  % colormap by the VALUE, so an image on [0,1] - which is what rescale
  % returns, and what most of these are - lands entirely on row 1 and comes
  % out uniform, while one on [38,180] happens to look right.
  h = image('XData',[pos.x(1,1) pos.x(end,end)],...
    'YData',[pos.y(1,1) pos.y(end,end)],...
    'CData',d,'CDataMapping','scaled','parent',mP.ax);

else

  % rotated against the specimen axes, so the pixels are not rows and
  % columns of the picture - draw the actual quadrilaterals
  h = surface(pos.x,pos.y,zeros(size(pos.x)),d,...
    'EdgeColor','none','parent',mP.ax);
  view(mP.ax,0,90);

end

% the frame decides where the picture points on screen, as it does for a map
mP.how2plot.setView(mP.ax);

% NaN limits mean truecolor, which uses no colormap and so has none to set
if hi > lo, set(mP.ax,'CLim',[lo hi]); end

% grey by default: an image is a picture, not a scalar field with a meaning
% attached to its colour. A later mtexColorMap call overrides it, and a
% three channel image is truecolor and uses no colormap at all
if size(d,3) == 1 && ~check_option(varargin,'colormap')
  mtexColorMap(mP.ax,'gray');
end

% only the options that name a property of what was drawn - the rest are
% ours, or newMapPlot's, and image() would reject them
h = optiondraw(h,varargin{:});

end

% =========================================================================
function tf = isAxisAligned(mg)
% whether rows and columns run along the specimen y and x axes

tf = abs(dot(normalize(mg.d1),vector3d.X)) < 1e-6 && ...
     abs(dot(normalize(mg.d2),vector3d.Y)) < 1e-6;

end
