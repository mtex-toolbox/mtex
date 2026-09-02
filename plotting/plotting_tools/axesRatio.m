function ratio = axesRatio(ax)
% height to width ratio an axis should be shaped with
%
% The shape comes from the camera, not from the data: an axis is as wide and
% as high as the shadow its plot box casts along the viewing direction.
%
% Input
%  ax - axes handle
%
% Output
%  ratio - height / width
%
% See also
% mtexLayout/measure mtexFigure/drawNow

% polar axes are circular and have no camera to derive a ratio from
if isa(ax,'matlab.graphics.axis.PolarAxes'), ratio = 1; return; end

axesSize = ax.PlotBoxAspectRatio;

% the camera is given in data coordinates - divide by the data aspect
% ratio to get plot box coordinates, which is what is seen on screen
camDir = (ax.CameraPosition - ax.CameraTarget) ./ ax.DataAspectRatio;
camUp = ax.CameraUpVector ./ ax.DataAspectRatio;
camRight = cross(camDir,camUp);

% camera looks along its own up vector
if norm(camRight) < 1e-10, ratio = 1; return; end

camDir = camDir ./ norm(camDir);
camRight = camRight ./ norm(camRight);
camUp = cross(camRight,camDir);

% the corners of the plot box
[x,y,z] = ndgrid([0,1],[0,1],[0,1]);
corner = [x(:),y(:),z(:)] .* axesSize;

shadow = corner * [camRight(:),camUp(:)];
shadow = max(shadow,[],1) - min(shadow,[],1);

ratio = shadow(2)/shadow(1);

end
