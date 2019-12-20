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

% scale and shift if required
v = v .* get_option(varargin,'scale',1);
v = v + get_option(varargin,'shift',0);


% plot
%v = v .* reshape(data,size(v));
h = surf(v.x,v.y,v.z,reshape(data,size(v,1),size(v,2),[]),'parent',ax,...
  'edgeColor','none');

% colormap
if numel(v) == numel(data), mtexColorMap(ax,getMTEXpref('defaultColorMap')); end


if ~ishold
 
  axis(ax,'equal','vis3d','off');

  set(ax,'XDir','rev','YDir','rev',...
    'XLim',[-1,1],'YLim',[-1,1],'ZLim',[-1,1]);
end
