function h = quiver(grains,dir,varargin)
% plot directions at grain centers
%
% Syntax
%   quiver(grains,dir,'color','r')
%
%   mtexdata forsterite
%   grains = calcGrains(ebsd)
%   quiver(grains,grains.meanRotation.axis,'color','r')
%
% Description
% Arrows that point into the screen would be hidden below the map. Those are
% shifted such that the arrow tip ends at the grain center and the tail
% sticks out of the map. Use the option |noShift| to switch this off.
%
% Since a shifted arrow no longer starts at the grain center, the center it
% refers to is marked by a small filled dot - switch it off with |noMarker|.
%
% MATLAB scales the arrow head with the length of the arrow, which turns the
% head of a long arrow into a fork. The heads drawn here are proportional
% only up to an upper bound of |headSize| points on the screen. Use |noHead|
% for the MATLAB head.
%
% Input
%  grains - @grain2d
%  dir    - @vector3d
%
% Options
%  antipodal   - plot directions or axes
%  maxHeadSize - head length relative to the arrow (default 0.25)
%  headSize    - upper bound for the head length in points (default 8)
%  project2Plane - project direction into plane
%  noHead       - use the MATLAB arrow head, i.e. scale it with the arrow
%  noShift      - do not shift arrows pointing into the screen
%  noMarker     - do not mark the grain centers
%  centerMarker - marker symbol for the grain centers (default 'o')
%  markerSize   - size of the grain center markers
%  markerFaceColor, markerEdgeColor - by default the color of the arrow
%

pos = grains.centroid;

% the direction the viewer looks from - note that this is not the normal of
% the map grains.N, which is what project2plane refers to
oS = grains.how2plot.outOfScreen;

% with autoScale off dir is the vector that is actually drawn - only then we
% know the arrow length and may shift the arrows below the map
isScaled = ~check_option(varargin,'noScaling');

if isScaled

  dir = 0.2*grains.diameter .* normalize(dir) * ...
    get_option(varargin,'autoScaleFactor',1);
  varargin = ['linewidth',2,'autoScale','off',varargin];
else
  varargin = ['linewidth',2,'autoScaleFactor',0.25,varargin];
end

if check_option(varargin,'project2plane')
  N = grains.N.normalize;
  dir = dir - dot(dir,N)*N;
end

% get color
c = get_option(varargin,'color');

isAntipodal = check_option(varargin,'antipodal') || dir.antipodal;

if isAntipodal

  varargin = [{'MaxHeadSize',0},varargin];

  % double color;
  if isnumeric(c) && length(c) == length(dir), c = [c;c]; end

  pos = [pos;pos];
  dir = [dir(:);-dir(:)];

end

% the arrows may be shifted away from the grain centers - keep the centers
% for the markers that tell which point an arrow belongs to
posC = pos;

if ~isAntipodal && isScaled && ~check_option(varargin,'noShift')

  % arrows pointing into the screen are hidden below the map - shift them
  % such that the arrow tip ends at the grain center and the tail sticks out
  % of the map
  isBelow = dot(dir,oS,'noAntipodal') < 0;
  pos = pos - dir .* double(isBelow);

end

% mark the grain centers, so that one sees where an arrow is anchored
doMarker = ~check_option(varargin,'noMarker');

% MATLAB scales the arrow head with the length of the arrow, so the head of
% a long arrow grows into a fork. Draw the heads ourselves, with an upper
% bound. This needs the drawn arrow length, so it is restricted to the
% scaled case just as the shift above.
doHead = isScaled && ~isAntipodal && ~check_option(varargin,'noHead');

if doHead
  % read the relative size before MaxHeadSize is overwritten below
  frac = get_option(varargin,'maxHeadSize',0.25);

  % switch the MATLAB head off - ours wins as set() applies in order
  varargin = [varargin,{'MaxHeadSize',0}];
end

% if different color are given - separate them
[c,~,id] = unique(c,'rows');

if length(id) == length(dir)

  varargin = delete_option(varargin,'color',1);

  hG = holdOn(gca); %#ok<NASGU>
  for i = 1:size(c,1)
    h(i) = optiondraw(quiver3(pos.x(id == i),pos.y(id == i),pos.z(id == i),...
      dir.x(id == i),dir.y(id == i),dir.z(id == i)),varargin{:},'color',c(i,:));  %#ok<AGROW>

    if doMarker, centerMarker(posC(id == i),c(i,:),varargin{:}); end
  end
  clear hG

else
  h = optiondraw(quiver3(pos.x,pos.y,pos.z,dir.x,dir.y,dir.z),varargin{:});

  % note that line() adds to the axes irrespective of the hold state
  if doMarker, centerMarker(posC,h.Color,varargin{:}); end
end

% The heads come last: their upper bound is given in points on the screen,
% which is known only once the arrows have set the axis limits.
if doHead

  headLen = headLength(gca,dir,oS,frac,varargin{:});

  if length(id) == length(dir)
    for i = 1:size(c,1)
      arrowHead(pos(id == i),dir(id == i),oS,headLen(id == i),c(i,:),varargin{:});
    end
  else
    arrowHead(pos,dir,oS,headLen,h.Color,varargin{:});
  end
end

if nargout == 0, clear h; end

end

% ------------------------------------------------------------------------

function l = headLength(ax,dir,N,frac,varargin)
% the length of the arrow heads
%
% Proportional to the arrow for short arrows, but bounded for long ones, so
% that a long arrow does not end in a fork. The bound is given in points on
% the screen, just as the line width and the marker size, so that it does
% not depend on the size of the map.

axUnit = ax.Units; ax.Units = 'points';
cap = get_option(varargin,'headSize',8) * diff(ax.XLim) / ax.Position(3);
ax.Units = axUnit;

% the length of an arrow as it appears on the screen
lenS = norm(dir - dot(dir,N,'noAntipodal') .* N);

l = min(frac .* lenS, cap);

end

% ------------------------------------------------------------------------

function hH = arrowHead(pos,dir,N,l,color,varargin)
% the two barbs of the arrow heads, all of them in one line
%
% This is the MATLAB arrow head - an open V of two lines - only that its
% length l is prescribed instead of being a fixed fraction of the arrow. The
% head is drawn in the plane of the screen and along the direction that is
% seen there, i.e. along the projection of dir, so that a foreshortened
% arrow gets a correspondingly foreshortened head.

tip = pos + dir;
u = dir - dot(dir,N,'noAntipodal') .* N; % what is seen on the screen

% arrows pointing straight at the viewer have no direction on the screen
ind = norm(u) > 1e-6 * norm(dir);
if ~any(ind), hH = gobjects(0); return; end

len = norm(u(ind));
u = u(ind) ./ len;
s = cross(N,u); % perpendicular to the arrow, in the plane of the screen
l = l(ind);

% A head that ends in the plane of the map is a tie for the depth sorting,
% which may then draw the map on top of it. Lift it marginally towards the
% viewer - as the projection is orthographic this does not move it on the
% screen.
tip = tip(ind) + 1e-2 .* len .* N;

% the barbs, at 22.5 degree to the arrow, separated by NaN
b = tip - l.*u;
w = tan(22.5*degree) .* l;
b1 = b + w.*s; b2 = b - w.*s;
gap = NaN(size(l(:)));

X = [b1.x(:) tip.x(:) b2.x(:) gap].';
Y = [b1.y(:) tip.y(:) b2.y(:) gap].';
Z = [b1.z(:) tip.z(:) b2.z(:) gap].';

hH = line(X(:),Y(:),Z(:),'parent',gca,...
  'color',color,'lineWidth',get_option(varargin,'lineWidth',2),...
  'lineJoin','miter',...
  'tag','arrowHead','hitTest','off','pickableParts','none');

% the heads belong to the arrows - no extra legend entry
hH.Annotation.LegendInformation.IconDisplayStyle = 'off';

end

% ------------------------------------------------------------------------

function hM = centerMarker(pos,color,varargin)
% mark the grain centers the arrows refer to
%
% Since arrows pointing into the screen are drawn with their tip at the
% grain center and their tail above the map, the position of an arrow alone
% no longer tells which point it belongs to - the marker does.
%
% Antipodal axes hand in every center twice - the two markers coincide
% exactly, so there is nothing to see and nothing to merge.

hM = line(pos.x,pos.y,pos.z,'parent',gca,...
  'lineStyle','none',...
  'marker',get_option(varargin,'centerMarker','o'),...
  'markerSize',get_option(varargin,'markerSize',5),...
  'markerFaceColor',get_option(varargin,'markerFaceColor',color),...
  'markerEdgeColor',get_option(varargin,'markerEdgeColor',color),...
  'lineWidth',get_option(varargin,'lineWidth',1),...
  'tag','grainCenter','hitTest','off','pickableParts','none');

% the markers belong to the arrows - no extra legend entry
hM.Annotation.LegendInformation.IconDisplayStyle = 'off';

end
