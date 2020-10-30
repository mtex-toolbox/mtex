function [h,mP] = plot(gB,varargin)
% plot grain boundaries
%
% The function plots grain boundaries.
%
% Syntax
%   plot(grains.boundary)
%   plot(grains.innerBoundary,'linecolor','r')
%   plot(gB('Forsterite','Forsterite'),gB('Forsterite','Forsterite').misorientation.angle)
%
%   % colorize segments according to a list of RGB values
%   plot(gB('Forsterite','Forsterite'),colorList)
%
% Input
%  grains - @grain2d
%  gB     - @grainBoundary
%  colorList - n x 3 list of RGB values
%  
% Options
%  linewidth - line width
%  linecolor - line color
%  edgeAlpha - (list of) transparency values between 0 and 1
%  region    - [xmin xmax ymin ymax] plot only a subregion
%  displayName - label to appear in the legend
%  smooth      - try to make a smooth connections at the vertices
%

reg = get_option(varargin,'region');
if ~isempty(reg)
  
  V = gB.V;
  F = gB.F;
  ind = V(F(:,1),1) > reg(1) & V(F(:,1),1) < reg(2)  & ...
    V(F(:,2),1) > reg(1) & V(F(:,2),1) < reg(2) & ...
    V(F(:,1),2) > reg(3) & V(F(:,1),2) < reg(4)  & ...
    V(F(:,2),2) > reg(3) & V(F(:,2),2) < reg(4);
  
  gB = gB.subSet(ind);
  
end

% create a new plot
mtexFig = newMtexFigure(varargin{:});
[mP,isNew] = newMapPlot('scanUnit',gB.scanUnit,'parent',mtexFig.gca,varargin{:});

if get_option(varargin,'linewidth',0) > 3 || check_option(varargin,'smooth')
  plotOrdered2(gB,varargin{:});
else
  plotSimple(gB,varargin{:});
end

% if no DisplayName is set remove patch from legend
if ~check_option(varargin,'DisplayName')
  set(get(get(h(1),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
else
  legend('-DynamicLegend','location','NorthEast');
end

try axis(mP.ax,'tight'); end
mP.micronBar.setOnTop

if nargout == 0, clear h; end

% finalize plot
if ~isstruct(mtexFig)  
  if isNew, mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); end
  if length(mtexFig.children)== 1, mtexFig.keepAspectRatio = false; end
end

function plotOrdered(gB,varargin)

% add a nan vertex at the end - patch should not close the faces
V = [gB.V;nan(1,2)];

% extract the edges
F = gB.F;

% detect where the edges are not consistent
breaks = F(2:end,1) ~= F(1:end-1,2);

% generate a new list of edges
% which has a nan pointer at every point of inconsistency
% first a full list of nan pointers
FF = size(V,1) * ones(size(F,1) + sum(breaks),2);

% insert the edges at the right positions
newpos = (1:length(breaks)+1).' + cumsum([0;breaks]);
FF(newpos,:) = F;

% remove duplicated
F = reshape(FF.',[],1);
dF = [true;diff(F)~=0];
F = F(dF);

% extract x and y values
x = V(F,1).';
y = V(F,2).';

% color given by second argument
if nargin > 1 && isnumeric(varargin{1}) && ...
    (size(varargin{1},1) == length(gB) || size(varargin{1},2) == length(gB))

  if size(varargin{1},1) ~= length(gB), varargin{1} = varargin{1}.'; end
  data = reshape(varargin{1},length(gB),[]);
  
  alpha = 0.01;
  
  % for colorizing the segments with different colors we have to make a lot
  % of efford
  % 1. colors are asigned to vertices in Matlab not to edges
  % 2. therefore we replace every vertex by two vertices 
  x = repelem(x,1,2);
  x(1) = []; x(end)=[];
  xx = x;
  x(2:2:end-1) = (1-alpha)*xx(2:2:end-1) + alpha*xx(1:2:end-2);
  x(3:2:end-1) = (1-alpha)*xx(3:2:end-1) + alpha*xx(4:2:end);
  x(end+1) = NaN;

  y = repelem(y,1,2);
  y(1) = []; y(end)=[];
  yy = y;
  y(2:2:end-1) = (1-alpha)*yy(2:2:end-1) + alpha*yy(1:2:end-2);
  y(3:2:end-1) = (1-alpha)*yy(3:2:end-1) + alpha*yy(4:2:end);
  y(end+1) = NaN;

  % align the data
  data = repelem(data,2,1);
  color = nan(length(y),size(data,2));
  color(~isnan(y),:) = data;

  % plot the line
  p = patch('XData',x(:),'YData',y(:),'FaceVertexCData',color,...
    'faceColor','none','hitTest','off','parent',...
    mP.ax,'EdgeColor','interp');

  % this makes the line connectors more nice
  try
    pause(0.01)
    e = p.Edge;
    e.LineJoin = 'round';
  end
  
else % color given directly
    
  color = str2rgb(get_option(varargin,{'linecolor','edgecolor','facecolor'},'k'));
    
  %p = patch(x,y,'r','faceColor','none','hitTest','off','parent',mP.ax,'EdgeColor',color);  
  p = line(x,y,'hitTest','off','parent',mP.ax,'color',color,'lineJoin','round');
  
end

h = optiondraw(p,varargin{:});

end

function plotOrdered2(gB,varargin)

% add a nan vertex at the end - patch should not close the faces
V = [gB.V;nan(1,2)];

% extract the edges
F = gB.F;

% computed Euler cycles
[EC,Fid] = EulerCycles2(F);

x = NaN(length(EC),1); y = x;
x(~isnan(EC)) = V(EC(~isnan(EC)),1);
y(~isnan(EC)) = V(EC(~isnan(EC)),2);

% color given by second argument
if nargin > 1 && isnumeric(varargin{1}) && ...
    (size(varargin{1},1) == length(gB) || size(varargin{1},2) == length(gB))

  if size(varargin{1},1) ~= length(gB), varargin{1} = varargin{1}.'; end
  data = reshape(varargin{1},length(gB),[]);
  
  alpha = 0.01;
  
  % for colorizing the segments with different colors we have to make a lot
  % of efford
  % 1. in Matlab colors are asigned to vertices not to edges
  % 2. therefore we replace every vertex by two vertices 
  x = repelem(x(:).',1,2);
  x(1) = []; x(end)=[];
  xx = x;
  x(2:2:end-1) = (1-alpha)*xx(2:2:end-1) + alpha*xx(1:2:end-2);
  x(3:2:end-1) = (1-alpha)*xx(3:2:end-1) + alpha*xx(4:2:end);
  x(end+1) = NaN;

  y = repelem(y(:).',1,2);
  y(1) = []; y(end)=[];
  yy = y;
  y(2:2:end-1) = (1-alpha)*yy(2:2:end-1) + alpha*yy(1:2:end-2);
  y(3:2:end-1) = (1-alpha)*yy(3:2:end-1) + alpha*yy(4:2:end);
  y(end+1) = NaN;

  % align the data
  data = repelem(data(Fid(~isnan(Fid)),:),2,1);
  color = nan(length(y),size(data,2));
  color(~isnan(y),:) = data;

  % plot the line
  
  
  % subdivion
  % for some reason it is important to subdivide it into parts
  for k = 1:ceil(length(x)/2000) 
    subId = max(1,(k-1)*2000) : min(k*2000,length(x));
      
    p(k) = patch('XData',[x(subId),NaN],'YData',[y(subId),NaN],'FaceVertexCData',[color(subId,:);NaN(1,size(color,2))],...
    'faceColor','none','hitTest','off','parent',...
    mP.ax,'EdgeColor','interp');
    
    if k>1
      set(get(get(p(k),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
    
  end
  
  % this makes the line connectors more nice
  try
    pause(0.01)
    e = p.Edge;
    e.LineJoin = 'round';
  end
  
else % color given directly
    
  color = str2rgb(get_option(varargin,{'linecolor','edgecolor','facecolor'},'k'));
    
  %p = patch(x,y,'r','faceColor','none','hitTest','off','parent',mP.ax,'EdgeColor',color);
  
  % subdivion
  % for some reason it is important to subdivide it into parts
  for k = 1:ceil(length(x)/2000) 
    subId = max(1,(k-1)*2000) : min(k*2000,length(x));
    p(k) = line(x(subId),y(subId),'hitTest','off','parent',mP.ax,'color',color,'lineJoin','round');
    
    if k>1
      set(get(get(p(k),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
    
  end
  
end

h = optiondraw(p,varargin{:});

end


function plotSimple(gB,varargin)
obj.Faces    = gB.F;
obj.Vertices = gB.V;
obj.parent = mP.ax;
obj.FaceColor = 'none';

% color given by second argument
if nargin > 1 && isnumeric(varargin{1}) && ...
    (size(varargin{1},1) == length(gB) || size(varargin{1},2) == length(gB))

  if size(varargin{1},1) ~= length(gB), varargin{1} = varargin{1}.'; end
  
  obj.Faces(:,3) = size(obj.Vertices,1)+1;
  obj.Vertices(end+1,:) = NaN;
  obj.Vertices = obj.Vertices(obj.Faces',:);
  obj.Faces = 1:size(obj.Vertices,1);
  
  obj.EdgeColor = 'flat';
  color = squeeze(varargin{1});
  obj.FaceVertexCData = reshape(repmat(color,1,3)',size(color,2),[])';
  
else % color given directly
    
  obj.EdgeColor = str2rgb(get_option(varargin,{'linecolor','edgecolor','facecolor'},'k'));
  
end

obj.hitTest = 'off';

if check_option(varargin,'edgeAlpha')
  obj.AlphaDataMapping = 'none';
  obj.edgeAlpha = 'flat';
  obj.FaceVertexAlphaData = get_option(varargin,'edgeAlpha');
  varargin = delete_option(varargin,'edgeAlpha');
end

h = optiondraw(patch(obj),varargin{:});

end

end