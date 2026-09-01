function plan = solveLayout(spec)
% where every axes, colorbar and legend goes, as arithmetic
%
% Syntax
%   plan = mtexLayout.solveLayout(spec)
%
% Input
%  spec - what was measured off the figure, see below
%
% Output
%  plan - where everything goes, in pixels
%
% Description
% The whole layout is one function: n axes of equal size and equal aspect
% ratio on a grid, each wrapped in a decoration band, the grid wrapped in an
% outer band that also holds a global colorbar, an outside legend and an
% sgtitle. No graphics handle goes in and none comes out, so this runs -
% and is tested - without a figure.
%
% Either the figure size is given and the axes size follows, or
% fixedAxisHeight is given and plan.figSize says how big the figure has to
% grow for it to fit.
%
% spec fields, all in pixels, all optional but n
%
%  n               - number of axes
%  ratio           - height/width one axes should be shaped with
%  inset           - n x 4 or 1 x 4 decoration band [l b r t] per axes
%  figInset        - 1 x 4 outer band
%  spacing         - gap between neighbouring axes
%  figSize         - [w h] available
%  keepAspectRatio - shape the axes by ratio rather than filling
%  fixedAxisHeight - force this height and grow the figure instead
%  layoutMode      - 'auto' to choose the grid, 'user' to be told it
%  ncols, nrows    - the grid, when layoutMode is 'user'
%  plotBox         - where an axes draws in its rectangle, as fractions of it
%  cBar            - .n (0, 1 or n), .side, .thickness, .gap, .labelRoom, .drop
%  legend          - .size [w h], .side, .spacing
%
% plan fields
%
%  ncols, nrows    - the grid it settled on
%  axisWidth/Height- size of one axes
%  pos             - n x 4, where the axes go
%  cBarPos         - 0, 1 or n rows
%  legendPos       - 1 x 4, or empty
%  inset, figInset - the bands after the colorbar and legend were reserved
%  figSize         - the size the figure needs to hold all of it
%
% See also
% mtexLayout mtexFigure/drawNow

spec = withDefaults(spec);

% what the decorations alone need. inset grows below to hold a colorbar as
% well, but the bar is placed against the decorations, so keep this apart
decor = max(spec.inset,[],1);
inset = decor;
figInset = spec.figInset;

% reserve the band the colorbar sits in: one per axes eats into every cell,
% a single global one eats into the figure
if spec.cBar.n > 0
  band = sideBand(spec.cBar.side, ...
    spec.cBar.gap + spec.cBar.thickness + spec.cBar.labelRoom);
  if spec.cBar.n == spec.n
    inset = inset + band;
  else
    figInset = figInset + band;
  end
end

% and the band for a legend outside the axes
if ~isempty(spec.legend.size)
  isVertical = any(strcmp(spec.legend.side,{'east','west'}));
  extent = spec.legend.size(2 - isVertical) + spec.legend.spacing;
  figInset = figInset + sideBand(spec.legend.side,extent);
end

avail = spec.figSize - [figInset(1)+figInset(3), figInset(2)+figInset(4)];

% a fixed axis height grows the figure, and a figure the screen cannot hold is
% a figure the window manager shrinks and the snapshot then squeezes
spec.maxAvail = spec.maxSize - [figInset(1)+figInset(3), figInset(2)+figInset(4)];

[nc,nr] = partition(spec,avail,inset);
[aw,ah] = axesSize(spec,avail,inset,nc,nr);

plan = struct('ncols',nc,'nrows',nr,'axisWidth',aw,'axisHeight',ah, ...
  'inset',inset,'figInset',figInset);

% ---- the axes ------------------------------------------------------------
cellW = aw + spec.spacing + inset(1) + inset(3);
cellH = ah + spec.spacing + inset(2) + inset(4);

used = [nc*cellW, nr*cellH] - spec.spacing;

% the size the figure needs - what a fixed axis height grows it to
plan.figSize = used + [figInset(1)+figInset(3), figInset(2)+figInset(4)];

% the grid hangs from the top of the space it will actually have: that is the
% space available, except when a fixed height is growing the figure to fit
if isempty(spec.fixedAxisHeight), top = avail(2); else, top = used(2); end

pos = zeros(spec.n,4);
for i = 1:spec.n
  [col,row] = ind2sub([nc nr],i);
  pos(i,:) = [figInset(1) + 1 + (col-1)*cellW + inset(1), ...
    figInset(2) + 1 + top - row*cellH + spec.spacing + inset(2), ...
    aw, ah];
end
pos(pos<0) = 0;
plan.pos = pos;

% ---- the colorbars -------------------------------------------------------
% everything below hangs off the bounding box of the axes, the way the
% legend always did - the grid is uniform, so one rule covers all four sides
% a 3d axes draws in a box smaller than the rectangle it was given, so the
% bar goes on what is drawn - for everything else the two are the same
drawn = [pos(:,1:2) + spec.plotBox(1:2).*pos(:,3:4), spec.plotBox(3:4).*pos(:,3:4)];

plan.cBarPos = zeros(0,4);
if spec.cBar.n == spec.n && spec.n > 0

  plan.cBarPos = zeros(spec.n,4);
  for i = 1:spec.n
    plan.cBarPos(i,:) = attach(drawn(i,:),spec.cBar,decor);
  end

elseif spec.cBar.n == 1

  bar = attach(boundingBox(drawn),spec.cBar,decor);

  % a ruler exponent is drawn past the end of the bar and needs the room
  isVertical = any(strcmp(spec.cBar.side,{'east','west'}));
  bar(3 + isVertical) = bar(3 + isVertical) - spec.cBar.drop;
  plan.cBarPos = bar;

end

% ---- the legend ----------------------------------------------------------
plan.legendPos = zeros(0,4);
if ~isempty(spec.legend.size)

  box = boundingBox(drawn);
  w = spec.legend.size(1); h = spec.legend.size(2);
  s = spec.legend.spacing;

  switch spec.legend.side
    case 'east'
      plan.legendPos = [box(1)+box(3)+s, box(2)+(box(4)-h)/2, w, h];
    case 'west'
      plan.legendPos = [box(1)-s-w, box(2)+(box(4)-h)/2, w, h];
    case 'north'
      plan.legendPos = [box(1)+(box(3)-w)/2, box(2)+box(4)+s, w, h];
    case 'south'
      plan.legendPos = [box(1)+(box(3)-w)/2, box(2)-s-h, w, h];
  end
end

end

% =========================================================================
function [nc,nr] = partition(spec,avail,inset)
% the grid that makes the axes as wide as possible

if ~strcmp(spec.layoutMode,'auto')
  nc = spec.ncols; nr = spec.nrows;
  % a grid too small to hold them would drop axes off the end silently
  if nc*nr < spec.n, nc = ceil(spec.n / nr); end
  return
elseif spec.n <= 1
  nc = max(spec.n,1); nr = 1;
  return
end

% plain arithmetic per candidate; the axes ratio is a constant here, so
% there is nothing to re-measure and no reason to call out of this loop
nc = spec.n; nr = 1;
best = axesSize(spec,avail,inset,nc,nr);

for r = 2:spec.n
  c = ceil(spec.n / r);
  w = axesSize(spec,avail,inset,c,r);
  if w > best
    best = w; nc = c; nr = r;
  end
end

end

% -------------------------------------------------------------------------
function [w,h] = axesSize(spec,avail,inset,nc,nr)
% size of one axes on an nc x nr grid

if ~isempty(spec.fixedAxisHeight)

  % the room one cell has on this grid, decorations and gaps taken off
  room = (spec.maxAvail + spec.spacing) ./ [nc nr] - spec.spacing - ...
    [inset(1)+inset(3), inset(2)+inset(4)];

  h = floor(min([spec.fixedAxisHeight, room(2), room(1)*spec.ratio]));
  w = h / spec.ratio;
  return
end

w = (avail(1) - (nc-1)*spec.spacing - nc*(inset(1)+inset(3))) / nc;
h = (avail(2) - (nr-1)*spec.spacing - nr*(inset(2)+inset(4))) / nr;

if spec.keepAspectRatio
  w = ceil(min(w,h / spec.ratio));
  h = ceil(w * spec.ratio);
end

end

% -------------------------------------------------------------------------
function pos = attach(box,cBar,inset)
% put a bar of the given thickness alongside box, clear of its decorations
%
% Clear of the decorations, not of the box: a title sits above the axes, so a
% northoutside bar hung off the box itself lands on top of it.

switch cBar.side
  case 'west'
    pos = [box(1)-inset(1)-cBar.gap-cBar.thickness, box(2), cBar.thickness, box(4)];
  case 'north'
    pos = [box(1), box(2)+box(4)+inset(4)+cBar.gap, box(3), cBar.thickness];
  case 'south'
    pos = [box(1), box(2)-inset(2)-cBar.gap-cBar.thickness, box(3), cBar.thickness];
  otherwise % east
    pos = [box(1)+box(3)+inset(3)+cBar.gap, box(2), cBar.thickness, box(4)];
end

end

% -------------------------------------------------------------------------
function band = sideBand(side,extent)
% extent put on one side of a [left bottom right top] band

band = zeros(1,4);
switch side
  case 'west',  band(1) = extent;
  case 'south', band(2) = extent;
  case 'north', band(4) = extent;
  otherwise,    band(3) = extent; % east
end

end

% -------------------------------------------------------------------------
function box = boundingBox(pos)

if isempty(pos), box = zeros(1,4); return; end

ll = min(pos(:,1:2),[],1);
box = [ll, max(pos(:,1:2)+pos(:,3:4),[],1) - ll];

end

% -------------------------------------------------------------------------
function spec = withDefaults(spec)

def = struct('n',0,'ratio',1,'inset',[0 0 0 0],'figInset',[10 10 10 10], ...
  'spacing',10,'figSize',[560 420],'keepAspectRatio',true,'maxSize',[Inf Inf], ...
  'fixedAxisHeight',[],'layoutMode','auto','ncols',1,'nrows',1, ...
  'plotBox',[0 0 1 1]);

for f = fieldnames(def).'
  if ~isfield(spec,f{1}) || isempty(spec.(f{1})) && ~strcmp(f{1},'fixedAxisHeight')
    spec.(f{1}) = def.(f{1});
  end
end

cBar = struct('n',0,'side','east','thickness',15,'gap',10,'labelRoom',0,'drop',0);
if ~isfield(spec,'cBar'), spec.cBar = struct; end
for f = fieldnames(cBar).'
  if ~isfield(spec.cBar,f{1}), spec.cBar.(f{1}) = cBar.(f{1}); end
end

lgd = struct('size',[],'side','east','spacing',spec.spacing);
if ~isfield(spec,'legend'), spec.legend = struct; end
for f = fieldnames(lgd).'
  if ~isfield(spec.legend,f{1}), spec.legend.(f{1}) = lgd.(f{1}); end
end

% one row per axes, whether it was measured once or n times
if size(spec.inset,1) == 1, spec.inset = repmat(spec.inset,max(spec.n,1),1); end

end
