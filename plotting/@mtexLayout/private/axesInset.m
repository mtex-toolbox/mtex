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
% camera has been placed, so a placed camera is measured a second time with
% the camera mode on auto and the larger of the two is taken.
%
% See also
% mtexLayout/measure

inset = baseInset(ax);

% a placed camera makes TightInset lie - measure again without one
if isa(ax,'matlab.graphics.axis.Axes') && ...
    strcmp(ax.PlotBoxAspectRatioMode,'manual') && ...
    strcmp(ax.CameraPositionMode,'manual')

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

% reading an extent in pixels corrupts the position, so put it back. One set
% for all of them: switching a text object's units forces a graphics update,
% and doing it per object made this the most expensive thing in the layout.
pos = ensurecell(get(txt,'position'));
set(txt,'Units','pixels')
ext = cell2mat(ensurecell(get(txt,'extent')));
set(txt,'Units','data')
set(txt,{'Position'},pos(:))

ap = get(ax,'position');
inset(1:2) = max([0 0; -ext(:,1:2)]);
inset(3:4) = max([0 0; ext(:,1:2)+ext(:,3:4)-repmat(ap(3:4),size(ext,1),1)]);

end

% -------------------------------------------------------------------------
function inset = autoCameraInset(ax)
% measure with the camera on auto, then put the camera back exactly
%
% The numbers describe the auto projection rather than the placed one, so
% this is a good proxy and not the truth - but the truth is [0 0 0 0].

camPos = ax.CameraPosition; camTgt = ax.CameraTarget;
camUp = ax.CameraUpVector; pbar = ax.PlotBoxAspectRatio;

ax.CameraPositionMode = 'auto';
drawnow limitrate
inset = baseInset(ax);

ax.CameraPosition = camPos; ax.CameraTarget = camTgt;
ax.CameraUpVector = camUp;  ax.PlotBoxAspectRatio = pbar;
ax.CameraPositionMode = 'manual';

end
