function [pos,value,ax] = getDataCursorPos(mtexFig)
% get the position and value of the data cursor
%

dcm_obj = datacursormode(mtexFig.parent);

% get position
try
  pos = dcm_obj.getCursorInfo.Position;
catch
 pos = dcm_obj.CurrentDataCursor.getCursorInfo.Position;
end

% get value
try
  target = dcm_obj.getCursorInfo.Target;
catch
  target = dcm_obj.CurrentDataCursor.getCursorInfo.Target;
end
xd = get(target,'xdata');
yd = get(target,'ydata');
zd = get(target,'zdata');
if isempty(zd)
  zd = get(target,'CData');
end

if size(xd,1) ~= 1 && size(xd,2) == numel(zd)   
  xd = mean(xd);
  yd = mean(yd);  
end

[~,value] = min((xd-pos(1)).^2 + (yd-pos(2)).^2);

if numel(zd) == numel(xd), value = zd(value); end

% convert pos to vector3d for spherical plots
ax = get(target,'Parent');

% for spherical plots convert to polar coordinates
sP = getappdata(ax,'sphericalPlot');
if ~isempty(sP)
  pos = sP.proj.iproject(pos(1),pos(2));
end
 
end

