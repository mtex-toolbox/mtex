function [h,ax] = plot3d(v,data,varargin)
% plot spherical data on the sphere itself, not on a projection of it
%
% Syntax
%
%   plot3d(v,data)
%   plot3d(v,data,'grid','grid_res',10*degree)
%
% Input
%  v    - @vector3d
%  data - values at v
%
% Options
%  scale    - radius of the sphere the data is drawn on
%  shift    - center of that sphere
%  grid_res - spacing of the spherical grid, default 15 degree
%
% Flags
%  grid    - draw a spherical grid over the data
%  noLabel - do not annotate the axes of the reference frame
%
% See also
% vector3d/scatter3d plotSphericalGrid saveFigure

% -------------------- GET OPTIONS ----------------------------------------

% where to plot
if check_option(varargin,'parent')
  ax = get_option(varargin,'parent');
else
  ax = gca;
end

% a Miller index marks the plot as living in crystal coordinates, any other
% frame names the axes of the annotation - note it before scaling
if isa(v,'Miller'), csArg = {v.CS}; else, csArg = {'dataFrame',v.frame}; end

% scale and shift if required
scale = get_option(varargin,'scale',1);
shift = get_option(varargin,'shift',vector3d(0,0,0));
v = v .* scale;
v = v + shift;


% plot
%v = v .* reshape(data,size(v));
h = surf(v.x,v.y,v.z,reshape(double(data),size(v,1),size(v,2),[]),...
  'parent',ax,'FaceColor','interp','edgeColor','none');

% colormap
if numel(v) == numel(data), mtexColorMap(ax,getMTEXpref('defaultColorMap')); end

if ~ishold

  axis(ax,'equal','vis3d','off');

  set(ax,'XDir','rev','YDir','rev',...
    'XLim',[-1,1],'YLim',[-1,1],'ZLim',[-1,1]);

  % a convention handed in wins, but not one a plot method appended for its own
  % data - that one is meant for a projected plot, where default3D is the better
  % picture. fromOption reports the origin, so the value does not decide (#481)
  [pC,isExplicit] = plottingConvention.fromOption(varargin,plottingConvention.default);
  if ~isExplicit, pC = plottingConvention.default3D; end
  pC.setView(ax);

  % the spherical grid - off unless asked for, and drawn just outside the data
  if check_option(varargin,'grid')
    ax.Clipping = 'off';
    plotSphericalGrid(ax,varargin{:},'radius',1.002*scale,'center',shift);
  end

  % annotate the reference frame as arrows, there is no sphericalPlot to do it
  annotateFrame(ax,varargin{:},csArg{:});

end
