function setCamera(varargin)
% set Camera according to xAxis and zAxis position

% get xaxis and zaxis directions

%
if nargin > 0 && ~isempty(varargin{1}) && ...
    numel(varargin{1})==1 && all(ishandle(varargin{1}))
  ax = varargin{1};
else
  ax = gca;
end

if check_option(varargin,'default')
  xAxis = getMTEXpref('xAxisDirection');
  zAxis = getMTEXpref('zAxisDirection');
else
  [xAxis,zAxis] = getCamera(ax);
end

% exract x- and z-axis direction
xAxis = get_option(varargin,'xAxisDirection',xAxis);
zAxis = get_option(varargin,'zAxisDirection',zAxis);

% set camera according to projection
if ischar(xAxis)
  el = (1-NWSE(xAxis))*90;
else
  el = round(-xAxis / degree);
end
az = 90;
if strcmpi(zAxis,'intoPlane')
  el = -el;
  az = -az;
end

%view(ax,el,az);
%set(ax,'CameraTarget',[0,0,0])
%set(ax,'CameraPosition',[0,0,10000])
%set(ax,'CameraPositionMode','manual')
%set(ax,'CameraUpVector',[sin((-el)*degree),cos((-el)*degree),0])