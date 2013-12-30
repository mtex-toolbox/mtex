function setCamera(varargin)
% set Camera according to xAxis and zAxis position

%% get xaxis and zaxis directions

%
if nargin > 0 && ~isempty(varargin{1}) && all(ishandle(varargin{1}))
  ax = varargin{1};
else
  ax = gca;
end

% get current state
proj = getappdata(ax,'projection');

% exract x-axis
if check_option(varargin,'xAxisDirection')
  proj.xAxis = get_option(varargin,'xAxisDirection');
elseif isempty(proj) || ~isfield(proj,'xAxis')
  proj.xAxis = getMTEXpref('xAxisDirection');
end

% exract z-axis
if check_option(varargin,'zAxisDirection')
  proj.zAxis = get_option(varargin,'zAxisDirection');
elseif isempty(proj) || ~isfield(proj,'zAxis')
  proj.zAxis = getMTEXpref('zAxisDirection');
end

% store in appdata
setappdata(ax,'projection',proj);

%% set camera according to projection

el = (1-NWSE(proj.xAxis))*90;
az = 90;
if strcmpi(proj.zAxis,'intoPlane')
  el = -el;
  az = -az;
end

view(ax,el,az);
