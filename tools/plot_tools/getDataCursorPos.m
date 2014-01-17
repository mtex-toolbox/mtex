function [pos,value,ax,iax] = getDataCursorPos(fig)
% get the position and value of the data cursor
%

dcm_obj = datacursormode(fig);

% get position
pos = dcm_obj.CurrentDataCursor.getCursorInfo.Position;

% get value
target = dcm_obj.CurrentDataCursor.getCursorInfo.Target;
xd = get(target,'xdata');
yd = get(target,'ydata');
zd = get(target,'zdata');
if isempty(zd)
  zd = get(target,'CData');
end

if numel(zd) == numel(xd)
  value = zd(pos(1) == xd & pos(2) == yd);
  value = value(1);
else
  value = find(pos(1) == xd & pos(2) == yd);
end

% convert pos to vector3d for spherical plots
ax = target.parent;

% extract position in multiplot axes
if isappdata(fig,'multiplotAxes')
  all_ax = getappdata(fig,'multiplotAxes');
  iax = ax == all_ax;
else
  iax = 1;
end

% for spherical plots convert to polar coordinates
if ~isappdata(ax,'projection'), return;end
projection = getappdata(ax,'projection');

if ~isfield(projection,'type'), return;end
  
[theta,rho] = projectInv(pos(1),pos(2),projection.type);
pos = [theta,rho];

end

