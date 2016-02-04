function [xDir,zDir] = getCamera(varargin)
% get xAxis and zAxis position from axis

% get xaxis and zaxis directions

%
if nargin > 0 && all(ishandle(varargin{1}))
  ax = varargin{1};
else
  ax = gca;
end

if isgraphics(ax,'axes') && isappdata(ax,'sphericalPlot')
  sP = getappdata(ax,'sphericalPlot');
  if ~isempty(sP.hgt), ax = sP.hgt; end
end

if isgraphics(ax,'axes')

  [az,el] = view(ax);

  if el<0
    zDir = 'intoPlane';
  else
    zDir = 'outOfPlane';
    az = -az;
  end
else
  
  M = get(ax,'matrix');
  az = atan2(M(2),M(1)) ./ degree;
  if M(3,3)>0
    zDir = 'outOfPlane';
    az = -az;
  else
    zDir = 'intoPlane';    
  end
end
  

xDirs = {'east','north','west','south'};
try
  xDir = xDirs{1+mod(az/90,4)};
catch
  xDir = -az * degree;
end
