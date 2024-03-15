function how2plot = getCamera(ax)
% get current plottingConvention from axes

if nargin == 0, ax = gca; end

outOfScreen = normalize(vector3d(get(ax,'CameraPosition') - get(ax,'CameraTarget')));
north = normalize(vector3d(get(ax,'CameraUpVector')));

how2plot = plottingConvention(outOfScreen,cross(north,outOfScreen));
