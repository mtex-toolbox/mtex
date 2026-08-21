function [width,height] = calcAxesSize(mtexFig,figSize,nc,nr,varargin)
% determine best partition of equally sized axes within a figure
%
% Input
%  mtexFig - @mtexFigure
%  nc - number of columns
%  nr - number of rows
%
% Output
%  width, height - width of an axis

if nargin <= 2, nc = mtexFig.ncols; nr = mtexFig.nrows; end

if isa(mtexFig.children(1),'matlab.graphics.axis.PolarAxes')

  % polar axes are circular and have no camera to derive a ratio from
  axesRatio = 1;

else

  % shape the axes like the shadow of the plot box along the viewing direction
  ax = mtexFig.children(1);
  axesSize = ax.PlotBoxAspectRatio;

  % the camera is given in data coordinates - divide by the data aspect
  % ratio to get plot box coordinates, which is what is seen on screen
  camDir = (ax.CameraPosition - ax.CameraTarget) ./ ax.DataAspectRatio;
  camUp = ax.CameraUpVector ./ ax.DataAspectRatio;
  camRight = cross(camDir,camUp);

  if norm(camRight) < 1e-10 % camera looks along its own up vector

    axesRatio = 1;

  else

    camDir = camDir ./ norm(camDir);
    camRight = camRight ./ norm(camRight);
    camUp = cross(camRight,camDir);

    % the corners of the plot box
    [x,y,z] = ndgrid([0,1],[0,1],[0,1]);
    corner = [x(:),y(:),z(:)] .* axesSize;

    shadow = corner * [camRight(:),camUp(:)];
    shadow = max(shadow,[],1) - min(shadow,[],1);
    width = shadow(1); height = shadow(2);

    axesRatio = height/width;

  end

end

width = (figSize(1)-(nc-1)*mtexFig.innerPlotSpacing - nc*sum(mtexFig.tightInset([1,3])))/nc;
height = (figSize(2)-(nr-1)*mtexFig.innerPlotSpacing - nr*sum(mtexFig.tightInset([2,4])))/nr;

if mtexFig.keepAspectRatio
  width = ceil(min(width,height/axesRatio));
  height = ceil(width*axesRatio);
end
  
end
