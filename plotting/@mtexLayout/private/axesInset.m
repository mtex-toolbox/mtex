function inset = axesInset(ax)
% room the decorations of one axes need around it, in pixels [l b r t]
%
% Input
%  ax - axes handle, already in pixel units
%
% Output
%  inset - [left bottom right top]
%
% Description
% TightInset is the only thing MATLAB measures - OuterPosition is always the
% plot box plus a fixed LooseInset, so it reports the same numbers whatever
% the axes carries. TightInset in turn reports [0 0 0 0] for an axes whose
% camera has been placed, so an axes that draws rulers under a placed camera
% is measured a second time with the camera on auto and the larger of the two
% is taken. An invisible axes draws no rulers and is measured by its texts.
%
% See also
% mtexLayout/measure

inset = baseInset(ax);

% a placed camera makes TightInset lie - measure again without one
if isa(ax,'matlab.graphics.axis.Axes') && strcmpi(ax.Visible,'on') && ...
    any(strcmp(get(ax,{'CameraPositionMode','CameraViewAngleMode'}),'manual'))

  inset = max(inset,autoCameraInset(ax));

end

end

% =========================================================================
function inset = baseInset(ax)

% a polar axes has none of the tick and label properties below, but reports
% a tight inset of its own
if isa(ax,'matlab.graphics.axis.PolarAxes')
  inset = [0 0 0 0];
  if isprop(ax,'TightInset'), inset = get(ax,'TightInset'); end
  return
end

if strcmpi(get(ax,'visible'),'off') || strcmpi(get(ax,'XColor'),'none')

  % tick labels are not drawn, so they must not reserve room either. Stripping
  % them forces two relayouts, so only do it when there is something to strip
  xtl = get(ax,'xTickLabel');
  ytl = get(ax,'yTickLabel');
  if isempty(xtl) && isempty(ytl)
    inset = get(ax,'tightInset');
  else
    set(ax,'xTickLabel',[],'yTickLabel',[]);
    inset = get(ax,'tightInset');
    set(ax,'xTickLabel',xtl,'yTickLabel',ytl);
  end

  inset = max(inset,dataTextInset(ax));

elseif all(get(ax,'ticklength') == 0)

  xt = get(ax,'xtick');
  yt = get(ax,'ytick');
  if isempty(xt) && isempty(yt)
    inset = get(ax,'tightInset');
  else
    set(ax,'xtick',[],'ytick',[]);
    inset = get(ax,'tightInset');
    set(ax,'xtick',xt,'ytick',yt);
  end

else

  inset = get(ax,'tightInset');

end

end

% -------------------------------------------------------------------------
function inset = dataTextInset(ax)
% how far text placed in data units sticks out of the axes

inset = [0 0 0 0];

txt = findall(ax,'type','text','unit','data');
if isempty(txt), return; end

s = ensurecell(get(txt,'string'));
txt = txt(~cellfun(@isempty,s));
if isempty(txt), return; end

ap = get(ax,'position');

if isPlainView(ax)

  % on an axes seen straight on, pixels are data units times the axes scale,
  % and an extent read this way is free - switching a text object to pixel
  % units costs a graphics update per object, 20 ms each over a contour
  [sx,sy] = dataScale(ax,ap);
  xl = get(ax,'XLim'); yl = get(ax,'YLim');
  ext = cell2mat(ensurecell(get(txt,'Extent')));
  ext = [(ext(:,1)-xl(1))*sx+1, (ext(:,2)-yl(1))*sy+1, ext(:,3)*sx, ext(:,4)*sy];

else

  % reading an extent in pixels corrupts the position, so put it back. One set
  % for all of them: switching a text object's units forces a graphics update,
  % and doing it per object made this the most expensive thing in the layout.
  pos = ensurecell(get(txt,'position'));
  set(txt,'Units','pixels')
  ext = cell2mat(ensurecell(get(txt,'extent')));
  set(txt,'Units','data')
  set(txt,{'Position'},pos(:))

end

inset(1:2) = max([0 0; -ext(:,1:2)]);
inset(3:4) = max([0 0; ext(:,1:2)+ext(:,3:4)-repmat(ap(3:4),size(ext,1),1)]);

end

% -------------------------------------------------------------------------
function tf = isPlainView(ax)
% true if the data to pixel map is the axis aligned scale
%
% A two dimensional spherical plot qualifies whatever its plotting
% convention, because the convention lives in the projection and never
% reaches the camera - a plot(...,'3d'), which turns the camera and reverses
% XDir and YDir, does not.

d = ax.CameraPosition - ax.CameraTarget;
up = ax.CameraUpVector;

tf = d(3) > 0 && norm(d(1:2)) <= 1e-9 * d(3) && ...
  up(2) > 0 && norm(up([1 3])) <= 1e-9 * up(2) && ...
  strcmp(get(ax,'XDir'),'normal') && strcmp(get(ax,'YDir'),'normal');

end

% -------------------------------------------------------------------------
function [sx,sy] = dataScale(ax,ap)
% pixels per data unit along x and y
%
% A pinned data aspect ratio ties the two together, and the axes is then
% only as wide as the aspect allows - whichever direction runs out first
% sets the scale for both.

xl = get(ax,'XLim'); yl = get(ax,'YLim');
sx = ap(3) / diff(xl);
sy = ap(4) / diff(yl);

if strcmp(get(ax,'DataAspectRatioMode'),'manual')
  dar = get(ax,'DataAspectRatio');
  s = min(sx * dar(1), sy * dar(2));
  sx = s / dar(1);
  sy = s / dar(2);
end

end

% -------------------------------------------------------------------------
function inset = autoCameraInset(ax)
% measure with the camera on auto, then put the camera back exactly
%
% The numbers describe the auto projection rather than the placed one, so
% this is a good proxy and not the truth - but the truth is [0 0 0 0].

props = {'CameraPosition','CameraTarget','CameraUpVector','CameraViewAngle',...
  'PlotBoxAspectRatio','DataAspectRatio'};
modes = strcat(props,'Mode');
val = get(ax,props); mode = get(ax,modes);

set(ax,modes,repmat({'auto'},1,numel(modes)));
drawnow limitrate
inset = baseInset(ax);

% the values first, since assigning one switches its mode back to manual
set(ax,props,val); set(ax,modes,mode);

end
