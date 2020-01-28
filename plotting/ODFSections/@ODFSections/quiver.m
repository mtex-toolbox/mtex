function quiver(oS,varargin)
% plot data into ODF sections
%
% Syntax
%   quiver(oS,ori,v)
%
%   grid = oS.makeGrid;
%   values = odf.eval(grid)
%   plot(oS,values)
%
% Input
%  oS    - @ODFSections
%  ori   - @orientation
%  v     - @orientation
%  fibre - @fibre
%

[mtexFig,isNew] = newMtexFigure('ensureAppdata',{{'ODFSections',oS}},varargin{:});

add2all = check_option(varargin,'add2all') || ...
  (numSections(oS)>1 && length(mtexFig.children)>1);

if ~isNew && add2all 
  wasHold = ishold;
  for axx = mtexFig.children.'  
    hold(axx,'on');
  end
  mtexFig.currentId = 1;
end
varargin = delete_option(varargin,'add2all');

% extract orientations
if nargin>1 && isa(varargin{1},'quaternion')
  ori = orientation(varargin{1},oS.CS1,oS.CS2);
  numData = length(ori);
  varargin(1) = [];
elseif ~isempty(oS.plotGrid)
  numData = oS.gridSize(end);
else 
  ori = orientation;
  numData = 0;
end
secData = {};

% extract data
[data,varargin] = extract_data(numData,varargin);

  
% subsample to reduce size
if (~check_option(varargin,'all') && numData > 2000 && ...
    ~check_option(varargin,{'smooth','contourf','contour','pcolor'})) || ...
    check_option(varargin,'points')
  points = fix(get_option(varargin,'points',2000));
  disp(['  plotting ', int2str(points) ,' random orientations out of ', ...
    int2str(length(ori)),' given orientations']);
  
  samples = discretesample(length(ori),points);
  ori = ori(samples);
  if ~isempty(data), data = data(samples,:); end
end

if length(ori)>1 && ~isempty(data)
  opt = 'preserveOrder';
else
  opt = '';
end
[vec,secAngle] = project(oS,ori,opt,varargin{:});

vec.resolution = min(10*degree,max(1*degree,...
  round(500000*degree/(numSym(oS.SS)*numSym(oS.CS)*length(ori)).^(1/3))));

for s = 1:oS.numSections
  
  if s>1, mtexFig.nextAxis; end
  
  ind = find(secAngle == s);
  if isa(vec,'vector3d')
    iv = vec(ind);
  else
    iv = vec;
    iv.phi1 = iv.phi1(ind);
    iv.phi2 = iv.phi2(ind);
  end
  if isempty(iv) % make sure we add something for the legend
    iv = vector3d.nan;
    if ~isempty(data), secData = {vector3d.nan}; end
  else
    if ~isempty(data), secData = {data(1+mod(ind-1,length(ori)),:)}; end
  end
  
  quiverSection(oS,mtexFig.gca,s,iv,secData,varargin{:});
  
  % maybe there is also a lower hemisphere
  if oS.upperAndLower && add2all
    mtexFig.nextAxis;
    quiverSection(oS,mtexFig.gca,s,iv,secData,varargin{:});
  end
  
end

mtexFig.CLim('equal');

%if isNew || check_option(varargin,'figSize')
mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
  
dcm = datacursormode(mtexFig.parent);
set(dcm,'enable','on')
hcmenu = get(dcm,'UIContextMenu') ;
uimenu(hcmenu, 'Label', 'Mark equivalent orientations', 'Callback', @markEquivalent);
set(dcm,'UIContextMenu',hcmenu)

set(dcm,'UpdateFcn',@tooltip)
   
if ~isNew && add2all && ~wasHold 
  for axx = mtexFig.children.'
    hold(axx,'off');
  end
end

%end


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
