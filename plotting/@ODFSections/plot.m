function plot(oS,varargin)
      
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
    
  [v,secAngle] = project(oS,ori);
        
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

if isNew, mtexFig.drawNow(varargin{:}); end

end
  
