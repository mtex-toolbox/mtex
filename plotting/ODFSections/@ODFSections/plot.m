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
[data,varargin] = extract_data(numData,varargin);


%
if exist('ori','var') || isempty(oS.plotGrid)
  
  % subsample to reduce size
  if (~check_option(varargin,'all') && length(ori) > 2000 && ...
      ~check_option(varargin,{'smooth','contourf','contour','pcolor'})) || ...
      check_option(varargin,'points')
    points = fix(get_option(varargin,'points',2000));
    disp(['  plotting ', int2str(points) ,' random orientations out of ', ...
      int2str(length(ori)),' given orientations']);

    samples = discretesample(length(ori),points);
    ori = ori(samples);
    if ~isempty(data), data = data(samples,:); end
  end
  
  [vec,secAngle] = project(oS,ori,varargin{:});
  
  vec.resolution = min(10*degree,max(1*degree,...
    round(500000*degree/(length(oS.SS)*length(oS.CS)*length(ori)).^(1/3))));
  
  for s = 1:oS.numSections
    
    if s>1, mtexFig.nextAxis; end
    
    ind = find(secAngle == s);
    if ~isempty(data), secData = {data(1+mod(ind-1,length(ori)),:)}; end
    plotSection(oS,mtexFig.gca,s,vec(ind),secData,varargin{:});
    
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
    
    plotSection(oS,mtexFig.gca,s,secS2Grid,secData,varargin{:});
    
  end
      
end

mtexFig.CLim('equal');

if isNew || check_option(varargin,'figSize')
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); 
  
  dcm = datacursormode(mtexFig.parent);
  set(dcm,'enable','on')  
  hcmenu = get(dcm,'UIContextMenu') ;
  uimenu(hcmenu, 'Label', 'Mark equivalent orientations', 'Callback', @markEquivalent);
  set(dcm,'UIContextMenu',hcmenu)

  set(dcm,'UpdateFcn',@tooltip)
     
end


% --------------- Tooltip function -------------------------------
  function txt = tooltip(varargin)   
    [thisOri,vec] = currentOrientation;
    txt = [xnum2str(vec) ' at ' char(thisOri,'nodegree')];    
  end

  function markEquivalent(varargin)
    annotate(currentOrientation);
  end

  function [ori,value] = currentOrientation
    [pos,value,ax] = getDataCursorPos(mtexFig);
    ori = oS.iproject(pos.rho,pos.theta,mtexFig.children == ax);
  end
  
end
  


