function [xDir,zDir] = getCamera(varargin)
% get xAxis and zAxis position from axis

% get xaxis and zaxis directions

%
if nargin > 0 && all(ishandle(varargin{1}))
  ax = varargin{1};
else
  ax = gca;
end

[az,el] = view(ax);

if el<0
  zDir = 'intoPlane';
else
  zDir = 'outOfPlane';
  az = -az;
end

xDirs = {'east','north','west','south'};
xDir = xDirs{1+mod(az/90,4)};
