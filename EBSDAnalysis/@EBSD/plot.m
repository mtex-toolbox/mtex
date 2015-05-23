function [h,mP] = plot(ebsd,varargin)
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
[mtexFig,isNew] = newMtexFigure('datacursormode',{@tooltip,ebsd},varargin{:});
mP = newMapPlot('scanUnit',ebsd.scanUnit,'parent',mtexFig.gca,varargin{:});

% transform orientations to color
if nargin>1 && isa(varargin{1},'orientation')
    
  oM = ipdfHSVOrientationMapping(varargin{1});
  varargin{1} = oM.orientation2color(varargin{1});
  
  disp('  I''m going to colorize the orientation data with the ');
  disp('  standard MTEX colorkey. To view the colorkey do:');
    disp(' ');
  disp('  oM = ipdfHSVOrientationMapping(ori_variable_name)')
  disp('  plot(oM)')
end


% numerical data are given
if nargin>1 && isnumeric(varargin{1})
  
  property = varargin{1};
  
  assert(any(numel(property) == length(ebsd) * [1,3]),...
    'The number of values should match the number of ebsd data!')
  
  h = plotUnitCells([ebsd.prop.x, ebsd.prop.y],...
    property, ebsd.unitCell, 'parent', mP.ax, varargin{:});

else % phase plot

  for k=1:numel(ebsd.phaseMap)
      
    ind = ebsd.phaseId == k;
    
    if ~any(ind), continue; end
    
    color = ebsd.subSet(ind).color;
    
    h(k) = plotUnitCells([ebsd.prop.x(ind), ebsd.prop.y(ind)], color, ebsd.unitCell,...
      'parent', mP.ax, 'DisplayName',ebsd.mineralList{k},varargin{:}); %#ok<AGROW>
  
  end
  
  warning('off','MATLAB:legend:PlotEmpty');
  legend('-DynamicLegend','location','NorthEast');
  warning('on','MATLAB:legend:PlotEmpty');
  
end
  
% keep track of the extend of the graphics
% this is needed for the zoom: TODO maybe this can be done better
%if isNew, ; end % TODO set axis tight removes all the plot
try axis(mP.ax,'tight'); end
set(mP.ax,'zlim',[0,1]);
mP.extend(1) = min(mP.extend(1),min(ebsd.prop.x(:)));
mP.extend(2) = max(mP.extend(2),max(ebsd.prop.x(:)));
mP.extend(3) = min(mP.extend(3),min(ebsd.prop.y(:)));
mP.extend(4) = max(mP.extend(4),max(ebsd.prop.y(:)));

if nargout==0, clear h; end

if isNew
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
end

mtexFig.keepAspectRatio = false;

end

% ----------------------------------------------------------------------
% Tooltip function
function txt = tooltip(empt,eventdata,ebsd) %#ok<INUSL>

[pos,value] = getDataCursorPos(gcm);

try
  id = findByLocation(ebsd,[pos(1) pos(2)]);
catch
  id = [];
end

if ~isempty(id)

  txt{1} = ['id    '  num2str(id)];
  txt{2} = ['phase ', ebsd.mineralList{ebsd.phaseId(id)}];
  txt{3} = ['x,y   ', xnum2str(pos(1)) ', ' xnum2str(pos(2))];
  if ebsd.isIndexed(id)
    txt{4} = ['Euler ' char(ebsd.rotations(id),'nodegree')];
  end
  if ~isempty(value)
    txt{end+1} = ['Value ' xnum2str(value)];
  end
else
  txt = 'no data';
end

end

