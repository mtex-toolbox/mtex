function [x y lx ly] = fixMTExscreencoordinates(x,y,varargin)
%
%
%
%

plotoptions = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

dx = xvector; dy = yvector;
if appDataOption(plotoptions,'flipud',false), dy = -dy; end
if appDataOption(plotoptions,'fliplr',false), dx = -dx; end
rot = appDataOption(plotoptions,'rotate',0);
dx = axis2quat(zvector,rot) * dx;
dy = axis2quat(zvector,rot) * dy;
lx = 'x'; ly = 'y';
  
if isappr(dot(dx,xvector),0)
 % [dx,dy] = swap(dx,dy);
  [x,y] = swap(x,y);  
  [lx,ly] = swap(lx,ly);
end

if getx(dx) < 0, set(gca,'XDir','reverse'); else set(gca,'XDir','normal');end
if gety(dy) < 0, set(gca,'YDir','reverse'); else set(gca,'YDir','normal');end