function [h,mP] = plot(mg,varargin)
% plot a mapImage on its specimen coordinates
%
% Draws the image where it sits on the specimen, in micrometres rather than
% pixels, with the screen orientation taken from the frame. So an image and
% the map it is aligned to plot on top of each other without either being
% permuted first - MTEX moves the camera, not the data.
%
% Syntax
%
%   plot(mg)
%   plot(mg,'channel',2)
%   plot(mg,'micronbar','off')
%
%   plot(ebsd,ebsd.bc); hold on; plot(mg,'AlphaData',0.5)
%
% Input
%  mg - @mapImage
%
% Output
%  h  - handle to the graphics object
%  mP - @mapPlot
%
% Options
%  channel   - which channel to draw, default all of them
%  micronbar - 'on'/'off'
%
% Description
% One channel is drawn as a scalar field through the current colormap; three
% are drawn as RGB. Any other channel count has no single meaning as a
% picture, so name a channel.
%
% See also
% mapImage EBSD/plot

if isempty(mg), return; end

assert(isscalar(mg),'MTEX:mapImage:notScalar',...
  ['plot draws one image. For a sequence, loop or use nextAxis - '...
  'plot(mg(k)) - since the entries need not share a grid.']);

mtexFig = newMtexFigure(varargin{:});
[mP,~] = newMapPlot('scanUnit','um','parent',mtexFig.gca,varargin{:},...
  mg.how2plot,mg.frame);

d = mg.img;

ch = get_option(varargin,'channel',[]);
if ~isempty(ch), d = d(:,:,ch); end

assert(size(d,3) == 1 || size(d,3) == 3,'MTEX:mapImage:badChannelCount',...
  ['A %d channel image is not a picture on its own. Name one with '...
  '''channel'',k, or take three for RGB.'],size(d,3));

% rgb has to be in [0,1] or image() clips it without saying so
if size(d,3) == 3, d = rescale(d); end

pos = mg.pos;

if isAxisAligned(mg)

  % the fast path - a regular axis aligned grid is what image() draws, and
  % XData/YData carry the true coordinates so no permutation is needed
  h = image('XData',[pos.x(1,1) pos.x(end,end)],...
    'YData',[pos.y(1,1) pos.y(end,end)],...
    'CData',d,'parent',mP.ax);

  if size(d,3) == 1, set(mP.ax,'CLim',[min(d,[],'all') max(d,[],'all')]); end

else

  % rotated against the specimen axes, so the pixels are not rows and
  % columns of the picture - draw the actual quadrilaterals
  h = surface(pos.x,pos.y,zeros(size(pos.x)),d,...
    'EdgeColor','none','parent',mP.ax);
  view(mP.ax,0,90);

end

% only the options that name a property of what was drawn - the rest are
% ours, or newMapPlot's, and image() would reject them
h = optiondraw(h,varargin{:});

if nargout == 0, clear h; end

end

% =========================================================================
function tf = isAxisAligned(mg)
% whether rows and columns run along the specimen y and x axes

tf = abs(dot(normalize(mg.d1),vector3d.X)) < 1e-6 && ...
     abs(dot(normalize(mg.d2),vector3d.Y)) < 1e-6;

end
