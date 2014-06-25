function h = plotspatial(ebsd,varargin)
% spatial EBSD plot
%
% Input
%  ebsd - @EBSD
%
% Options
%  property - property used for coloring (default: orientation), other properties may be
%     |'phase'| for achieving a spatial phase map, or an properity field of the ebsd
%     data set, e.g. |'bands'|, |'bc'|, |'mad'|.
%
%  colocoding - [[orientation2color.html,colorize orientation]] according to
%    a colorization of the inverse pole figure
%
%    * |'ipdfHSV'|
%    * |'ipdfHKL'|
%    * |'ipdfAngle'|
%    * |'ipdfCenter'|
%
%    other color codings
%
%    * |'angle'|
%    * |'BungeRGB'|
%    * |'RodriguesHSV'|
%    * |'orientationCenter'|
%
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]] when
%     using inverse PoleFigure colorization
%
% Flags
%  points   - plot dots instead of unitcells
%
% Example
% plot a EBSD data set spatially with custom colorcoding
%
%   mtexdata forsterite
%   plot(ebsd,'colorcoding','ipdfHKL')
%
%   plot(ebsd,'property','phase')
%
%   plot(ebsd,'property','mad')
%
% See also
% EBSD/plot

% create a new plot
mP = newMapPlot(varargin{:});

% what to plot
if nargin>1 && isnumeric(varargin{1})
  property = varargin{1};
else
  property = get_option(varargin,'property','phase');
end

% phase plot
if ischar(property) && strcmpi(property,'phase')

  for k=1:numel(ebsd.phaseMap)
      
    ind = ebsd.phaseId == k;
    
    if ~any(ind), continue; end
    
    color = ebsd.subSet(ind).color;
    
    h(k) = plotUnitCells([ebsd.prop.x(ind), ebsd.prop.y(ind)],...
    color, ebsd.unitCell, 'parent', mP.ax, varargin{:}); %#ok<AGROW>  
    
  end

  idPlotted = unique(ebsd.phaseId);
  legend(h(idPlotted),ebsd.allMinerals(idPlotted),'location','NorthEast');
  
else % plot numeric property
  
  if ~any(numel(property) == length(ebsd) * [1,3])
    ebsd = ebsd.subSet(~isNotIndexed(ebsd));
  end
  
  assert(any(numel(property) == length(ebsd) * [1,3]),...
    'The number of values should match the number of ebsd data!')
  
  h = plotUnitCells([ebsd.prop.x, ebsd.prop.y],...
    property, ebsd.unitCell, 'parent', mP.ax, varargin{:});
  
end
  
% keep track of the extend of the graphics
% this is needed for the zoom: TODO maybe this can be done better
axis(mP.ax,'tight')
mP.extend(1) = min(mP.extend(1),min(ebsd.prop.x(:)));
mP.extend(2) = max(mP.extend(2),max(ebsd.prop.x(:)));
mP.extend(3) = min(mP.extend(3),min(ebsd.prop.y(:)));
mP.extend(4) = max(mP.extend(4),max(ebsd.prop.y(:)));

if nargout==0, clear h; end

end
