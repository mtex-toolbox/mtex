function [pos,id,value,ax] = getDataCursorPos(mtexFig,maxId)
% get the position and value of the data cursor
%

dcm_obj = datacursormode(mtexFig.parent);

% get position
try
  pos = dcm_obj.getCursorInfo.Position;
catch
  pos = dcm_obj.CurrentDataCursor.getCursorInfo.Position;
end

% get graphical object
try
  target = dcm_obj.getCursorInfo.Target;
catch
  target = dcm_obj.CurrentDataCursor.getCursorInfo.Target;
end

% convert pos to vector3d for spherical plots
ax = get(target,'Parent');

if ~isgraphics(ax,'axes')
  M = get(ax,'matrix');
  %pos = M(1:2,1:2).' * pos(1:2).';
  ax = get(ax,'parent');
end

% get coordinates
xd = get(target,'xdata');
yd = get(target,'ydata');

% maybe data are stored in zdata
try  
  values = get(target,'zdata');
catch
  values = [];
end

% maybe data are stored in cdata
if numel(values) ~=  numel(xd) && (numel(values) ~= size(xd,2) || size(xd,1) == 1)
  try values = get(target,'cdata'); end %#ok<TRYNC>
end

% for patches take the mean over the vertices, this gives something close
% to the center
if size(xd,1) ~= 1 && size(xd,2) == numel(values)   
  xd = mean(xd);
  yd = mean(yd);  
end

% find closes coordinate
if numel(xd)>2
  [~,id] = min((xd(:)-pos(1)).^2 + (yd(:)-pos(2)).^2);

  if numel(values) == numel(xd)
    value = values(id);
  else
    value = [];
  end
 
  % for spherical plots convert to polar coordinates
  sP = getappdata(ax,'sphericalPlot');
  if ~isempty(sP)
    pos = sP.proj.iproject(pos(1),pos(2));
  end
else
  value = [];
  id = 1;
end

if nargin > 1
  id = ceil(id*maxId/numel(xd));
end

end

