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
% vector3d/scatter3d plotSphericalGrid savefigure

% -------------------- GET OPTIONS ----------------------------------------

% where to plot
if check_option(varargin,'parent')
  ax = get_option(varargin,'parent');
else
  ax = gca;
end

% a Miller index marks the plot as living in crystal coordinates, where the
% X / Y / Z of the specimen would be meaningless - Miller/scatter tells the
% two dimensional plots the very same way, but the three dimensional ones
% never go through it. Note this before v is scaled below.
if isa(v,'Miller'), csArg = {v.CS}; else, csArg = {}; end

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

  % A convention handed in wins - that is what passing one is for. It used
  % to be ignored here, because the plot methods append the convention of
  % their data as a trailing fallback (S2FunHarmonicSym/plot does, see
  % plottingConvention.fromOption) and reading the option list at all would
  % have picked that fallback up: it is a screen alignment meant for a
  % projected plot, looking straight down the polar axis, which shows a
  % sphere at its worst. Hence the test below rather than a plain
  % fromOption - a convention that is merely the session default is taken
  % as that appended fallback and replaced by the tilted default3D,
  % anything else is taken as deliberate.
  pC = plottingConvention.fromOption(varargin,plottingConvention.default);
  if pC == plottingConvention.default, pC = plottingConvention.default3D; end
  pC.setView(ax);

  % the spherical grid - off unless asked for, exactly as on a projected
  % plot, where sphericalPlot hides it without the 'grid' flag. It goes a
  % hair outside the data, which sits on the unit sphere, so that the two
  % do not fight over the same depth - and hence outside the axis limits,
  % which is why the clipping has to go.
  if check_option(varargin,'grid')
    ax.Clipping = 'off';
    plotSphericalGrid(ax,varargin{:},'radius',1.002*scale,'center',shift);
  end

  % annotate the axes of the reference frame the way every two dimensional
  % spherical plot does - here as arrows in space, since there is no
  % sphericalPlot on a three dimensional axis to do it for us
  annotateFrame(ax,varargin{:},csArg{:});

end
