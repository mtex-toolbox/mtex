function [h,mP] = plot(ebsd,varargin)
% spatial EBSD plot
%
% Syntax
%
%   % colorize according to phase
%   plot(ebsd)
%
%   % colorize according to arbitrary value - here MAD
%   plot(ebsd,ebsd.mad)
%
%   % colorize according to orientation
%   plot(ebsd('phaseName'),ebsd('phaseName').orientation)
%
%   % colorize according to custom color
%   oM = ipfColorKey(ebsd('phaseName'))
%   color = oM.orientation2color(ebsd('phaseName').orientations);
%   plot(ebsd('phaseName'),color)
%
%   % specify the color directly and show in Legend
%   badMAD = ebsd.mad > 1;
%   plot(ebsd(badMAD),'faceColor','black,'DisplayName','bad values')
%
% Input
%  ebsd - @EBSD
%  color - length(ebsd) x 3 vector of RGB values
%
% Options
%  micronbar - 'on'/'off'
%  DisplayName - add a legend entry
%  
% Flags
%  points   - plot dots instead of unitcells
%  exact    - plot exact unitcells, even for large maps
%
% Example
%
%   mtexdata forsterite
%   plot(ebsd)
%
%   % colorize accoding to orientations
%   plot(ebsd('Forsterite'),ebsd('Forsterite').orientations)
%
%   % colorize according to MAD
%   plot(ebsd,ebsd.mad,'micronbar','off')
%
% See also
% EBSDSpatialPlots

%
if isempty(ebsd), return; end

% create a new plot
mtexFig = newMtexFigure('datacursormode',{@tooltip,ebsd},varargin{:});
[mP,isNew] = newMapPlot('scanUnit',ebsd.scanUnit,'parent',mtexFig.gca,varargin{:});

% transform orientations to color
if nargin>1 && isa(varargin{1},'orientation')
    
  oM = ipfColorKey(varargin{1});
  varargin{1} = oM.orientation2color(varargin{1});
  
  if ~getMTEXpref('generatingHelpMode')
    disp('  I''m going to colorize the orientation data with the ');
    disp('  standard MTEX ipf colorkey. To view the colorkey do:');
    disp(' ');
    disp('  ipfKey = ipfColorKey(ori_variable_name)')
    disp('  plot(ipfKey)')
  end
end

% translate logical into numerical data
if nargin>1 && islogical(varargin{1}), varargin{1} = double(varargin{1}); end

% numerical data are given
if nargin>1 && isnumeric(varargin{1})
  
  property = varargin{1};
    
  assert(any(numel(property) == length(ebsd) * [1,3]),...
    'The number of values should match the number of ebsd data!')
  
  h = plotUnitCells(ebsd, property, 'parent', mP.ax, varargin{:});
  
elseif nargin>1 && isa(varargin{1},'crystalShape')
  
  cS = varargin{1};
  plot(ebsd.prop.x,ebsd.prop.y,zUpDown * cS.diameter,ebsd.orientations * cS,varargin{2:end});
  
else % phase plot

  for k=1:numel(ebsd.phaseMap)
      
    ind = ebsd.phaseId == k;
    
    if ~any(ind), continue; end
    
    if check_option(varargin,'grayScale')
      color = 1 - (k-1)/(numel(ebsd.phaseMap)) * [1,1,1];
    else
      color = ebsd.subSet(ind).color;
    end
    
    h(k) = plotUnitCells(ebsd.subSet(ind), color,...
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
%set(mP.ax,'zlim',[0,1.1]);
mP.extend(1) = min(mP.extend(1),min(ebsd.prop.x(:)));
mP.extend(2) = max(mP.extend(2),max(ebsd.prop.x(:)));
mP.extend(3) = min(mP.extend(3),min(ebsd.prop.y(:)));
mP.extend(4) = max(mP.extend(4),max(ebsd.prop.y(:)));

if nargout==0, clear h; end

if isNew && ~isstruct(mtexFig)
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
else
  mP.micronBar.setOnTop  
end

if ~isstruct(mtexFig)  && length(mtexFig.children)== 1
  mtexFig.keepAspectRatio = false; 
end

end

% ----------------------------------------------------------------------
% Tooltip function
function txt = tooltip(empt,eventdata,ebsd) %#ok<INUSL>

[pos,~,value] = getDataCursorPos(gcm);

try
  id = findByLocation(ebsd,[pos(1) pos(2)]);
catch
  id = [];
end

if ~isempty(id)

  txt{1} = ['index = '  num2str(id)];
  txt{2} = ['Id = '  num2str(ebsd.id(id))];
  txt{3} = ['phase = ', ebsd.mineralList{ebsd.phaseId(id)}];
  txt{4} = ['(x,y) = (' xnum2str(pos(1:2),'delimiter',', ') ')'];
  if ebsd.isIndexed(id)
    txt{5} = ['Euler = ' char(ebsd.rotations(id),'nodegree')];
  end
  try
    txt{end+1} = ['grainId = ' xnum2str(ebsd.grainId(id))];
  end
  if ~isempty(value)
    txt{end+1} = ['Value = ' xnum2str(value)];
  end
else
  txt = 'no data';
end

end

