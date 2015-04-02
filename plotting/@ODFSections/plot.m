function plot(oS,varargin)
% plot data into ODF sections
%
% Syntax
%

[mtexFig,isNew] = newMtexFigure('ensureAppdata',{{'ODFSections',oS}},varargin{:});

% extract orientations
if nargin>1 && isa(varargin{1},'quaternion')
  ori = orientation(varargin{1},oS.CS1,oS.CS2);
  numData = length(ori);
  varargin(1) = [];
elseif ~isempty(oS.plotGrid)
  numData = oS.gridSize(end);
else 
  numData = 0;
end
secData = {};

% extract data
if ~isempty(varargin) && ...
    (prod(size(varargin{1})) == numData || ...
    prod(size(varargin{1})) == 3 * numData) && ... % for rgb coloring
    (isnumeric(varargin{1}) || isa(varargin{1},'vector3d')) %#ok<*PSIZE>
  data = varargin{1};
else
  data = get_option(varargin,'property');
end
if ~isempty(data), data = reshape(data,numData,[]); end

%
if exist('ori','var') || isempty(oS.plotGrid)

  % subsample to reduce size
  if ~check_option(varargin,'all') && length(ori) > 2000 || check_option(varargin,'points')
    points = fix(get_option(varargin,'points',2000));
    disp(['  plotting ', int2str(points) ,' random orientations out of ', ...
      int2str(length(ori)),' given orientations']);

    samples = discretesample(length(ori),points);
    ori = ori(samples);
    if ~isempty(data), data = data(samples,:); end
  end
  
  [v,secAngle] = project(oS,ori);
  %TODO: v.resolution = ori.resolution;      
  
  for s = 1:oS.numSections
    
    if s>1, mtexFig.nextAxis; end
    
    ind = secAngle == s;
    if ~isempty(data), secData = {data(ind,:)}; end
    plotSection(oS,mtexFig.gca,s,v(ind),secData,varargin{:},'parent',mtexFig.gca);
    
  end
  
else
  
  for s = 1:oS.numSections
    
    if s>1, mtexFig.nextAxis; end
    
    % the data
    if ~isempty(data)
      secData = {data(1 + oS.gridSize(s):oS.gridSize(s+1),:)};
    end
    
    % the plotting grid
    if iscell(oS.plotGrid)
      secS2Grid = oS.plotGrid{s};
    else
      secS2Grid = oS.plotGrid;
    end
    
    plotSection(oS,mtexFig.gca,s,secS2Grid,secData,varargin{:},'parent',mtexFig.gca);
    
  end
    
end

if isNew || check_option(varargin,'figSize')
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); 
end

end
  
% --------------- Tooltip function -------------------------------
% ,'datacursormode',@tooltip


function txt = tooltip(varargin)

% 
dcm_obj = datacursormode(mtexFig.parent);

hcmenu = dcm_obj.createContextMenu;
%hcmenu = dcm_obj.CurrentDataCursor.uiContextMenu;
if numel(get(hcmenu,'children'))<10
  uimenu(hcmenu, 'Label', 'Mark equivalent orientations', 'Callback', @markEquivalent);
  mcolor = uimenu(hcmenu, 'Label', 'Marker color', 'Callback', @display);
  msize = uimenu(hcmenu, 'Label', 'Marker size', 'Callback', @display);
  mshape = uimenu(hcmenu, 'Label', 'Marker shape', 'Callback', @display);
end

%
[ori,v] = currentOrientation;

txt = [xnum2str(v) ' at ' char(ori,'nodegree')];

end

%
function markEquivalent(varargin)

annotate(currentOrientation);

end


function [ori,value] = currentOrientation

[pos,value,ax] = getDataCursorPos(mtexFig);

iax = mtexFig.children == ax;

switch getappdata(gcf,'SectionType')
  case 'phi1'
    euler1 = sec(iax);
    euler2 = pos.theta;
    euler3 = pos.rho;
    convention = 'Bunge';
  case 'phi2'
    euler3 = sec(iax);
    euler2 = pos.theta;
    euler1 = pos.rho;
    convention = 'Bunge';
  case 'alpha'
    euler3 = sec(iax);
    euler2 = pos.theta;
    euler1 = pos.rho;
    convention = 'Matthies';
  case 'sigma'
    euler1 = pos.rho;
    euler2 = pos.theta;
    euler3 = sec(iax) - pos.rho;
    convention = 'Matthies';
  otherwise
    error('unknown sectioning!')
end

ori = orientation('Euler',euler1,euler2,euler3,convention,odf.CS,odf.SS);

end


