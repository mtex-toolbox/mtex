function [pos,value,ax,iax] = getDataCursorPos(fig)
% get the position and value of the data cursor
%

dcm_obj = datacursormode(fig);

% get position
pos = dcm_obj.CurrentDataCursor.getCursorInfo.Position;

% get value
xd = get(dcm_obj.CurrentDataCursor.getCursorInfo.Target,'xdata');
yd = get(dcm_obj.CurrentDataCursor.getCursorInfo.Target,'ydata');
zd = get(dcm_obj.CurrentDataCursor.getCursorInfo.Target,'zdata');

value = zd(pos(1) == xd & pos(2) == yd);
value = value(1);

% convert pos to vector3d for spherical plots
ax = dcm_obj.CurrentDataCursor.getCursorInfo.Target.parent;

% extract position in multiplot axes
if isappdata(fig,'multiplotAxes')
  all_ax = getappdata(fig,'multiplotAxes');
  iax = ax == all_ax;
else
  iax = 1;
end

% for spherical plots convert to polar coordinates
if isappdata(ax,'projection')
  projection = getappdata(ax,'projection');
  [theta,rho] = projectInv(pos(1),pos(2),projection.type);
  pos = [theta,rho];
end

end
