function h = plot(ebsd,varargin)
% spatial EBSD plot
%
% Input
%  ebsd - @EBSD
%
% Options
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
%   plot(ebsd)
%
%   plot(ebsd('Forsterite'))
%
%   plot(ebsd,ebsd.mad)
%
% See also
% EBSD/plot

% create a new plot
mP = newMapPlot(varargin{:});

% what to plot
if nargin>1 && isnumeric(varargin{1})
  property = varargin{1};
elseif numel(ebsd.indexedPhasesId)==1 
  
  ebsd = ebsd.subSet(ebsd.phaseId == ebsd.indexedPhasesId);
  
  oM = ipdfHSVOrientationMapping(ebsd);
  property = oM.orientation2color(ebsd.orientations);
  disp('  I''m going to colorize the ebsd data with the ');
  disp('  standard MTEX colorkey. To view the colorkey do:');
    disp(' ');
  disp('  oM = ipdfHSVOrientationMapping(ebsd_variable_name)')
  disp('  plot(oM)')
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
  legend(h(idPlotted),ebsd.mineralList(idPlotted),'location','NorthEast');
  
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

drawNow(gcm,varargin{:})

if nargout==0, clear h; end

end
