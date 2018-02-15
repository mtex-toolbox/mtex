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
% Input
%  grains - @grain2d
%  gB     - @grainBoundary
%  
% Options
%  linewidth
%  linecolor
%

% create a new plot
[mtexFig,isNew] = newMtexFigure(varargin{:});
mP = newMapPlot('scanUnit',gB.scanUnit,'parent',mtexFig.gca,varargin{:});

if get_option(varargin,'linewidth',0) > 3 || check_option(varargin,'smooth')
  plotOrdered(gB,varargin{:});
else
  plotSimple(gB,varargin{:});
end

% if no DisplayName is set remove patch from legend
if ~check_option(varargin,'DisplayName')
  set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
else
  legend('-DynamicLegend','location','NorthEast');
end

try axis(mP.ax,'tight'); end
mP.micronBar.setOnTop

if nargout == 0, clear h; end
if isNew, mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); end
mtexFig.keepAspectRatio = false;

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
    
  color = get_option(varargin,{'linecolor','edgecolor','facecolor'},'k');

  %p = patch(x,y,'r','faceColor','none','hitTest','off','parent',mP.ax,'EdgeColor',color);
  p = line(x,y,'hitTest','off','parent',mP.ax,'color',color,'lineJoin','round');
  
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
    
  obj.EdgeColor = get_option(varargin,{'linecolor','edgecolor','facecolor'},'k');
  
end

obj.hitTest = 'off';

h = optiondraw(patch(obj),varargin{:});

end

end