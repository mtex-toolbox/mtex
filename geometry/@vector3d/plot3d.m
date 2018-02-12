function [h,ax] = plot3d(v,data,varargin)
% plot spherical data
%
% Syntax
%   plot3d(v,data)
%
% Input
%
% See also
% savefigure

% -------------------- GET OPTIONS ----------------------------------------

% where to plot
if check_option(varargin,'parent')
  ax = get_option(varargin,'parent');
else
  ax = gca;
end

% plot
%v = v .* reshape(data,size(v));
h = surf(v.x,v.y,v.z,reshape(data,size(v,1),size(v,2),[]),'parent',ax);

% colormap
mtexColorMap(ax,getMTEXpref('defaultColorMap'));

shading(ax,'interp');
axis(ax,'equal','vis3d','off');

set(ax,'XDir','rev','YDir','rev',...
  'XLim',[-1,1],'YLim',[-1,1],'ZLim',[-1,1]);
