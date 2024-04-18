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
  
  V = gB.V.xyz;
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

if isNew, try axis(mP.ax,'tight'); end, end
mP.micronBar.setOnTop

if nargout == 0, clear h; end

% finalize plot
if ~isstruct(mtexFig)  
  if isNew, mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); end
  if isscalar(mtexFig.children), mtexFig.keepAspectRatio = false; end
end


function plotOrdered2(gB,varargin)

% add a nan vertex at the end - patch should not close the faces
V = [gB.V.xyz; nan(1,3)];

% extract the edges
F = gB.F;

% computed Euler cycles
[EC,Fid] = EulerCycles2(F);

x = NaN(length(EC),1); y = x;
z = zeros(size(x));
x(~isnan(EC)) = V(EC(~isnan(EC)),1);
y(~isnan(EC)) = V(EC(~isnan(EC)),2);
if size(V,2) == 3, z(~isnan(EC)) = V(EC(~isnan(EC)),3); end

% color given by second argument
if nargin > 1 && isnumeric(varargin{1}) && ...
    (size(varargin{1},1) == length(gB) || size(varargin{1},2) == length(gB))

  if size(varargin{1},1) ~= length(gB), varargin{1} = varargin{1}.'; end
  data = reshape(varargin{1},length(gB),[]);
  
  alpha = 0.01;
  
  % for colorizing the segments with different colors we have to make a lot
  % of effort
  % 1. in MATLAB colors are assigned to vertices not to edges
  % 2. therefore we replace every vertex by two vertices 
  x = repelem(x(:).',1,2).';
  x(1) = []; x(end)=[];
  xx = x;
  x(2:2:end-1) = (1-alpha)*xx(2:2:end-1) + alpha*xx(1:2:end-2);
  x(3:2:end-1) = (1-alpha)*xx(3:2:end-1) + alpha*xx(4:2:end);
  x(end+1) = NaN;

  y = repelem(y(:).',1,2).';
  y(1) = []; y(end)=[];
  yy = y;
  y(2:2:end-1) = (1-alpha)*yy(2:2:end-1) + alpha*yy(1:2:end-2);
  y(3:2:end-1) = (1-alpha)*yy(3:2:end-1) + alpha*yy(4:2:end);
  y(end+1) = NaN;

  z = repelem(z(:).',1,2).';
  z(1) = []; z(end)=[];
  zz = z;
  z(2:2:end-1) = (1-alpha)*zz(2:2:end-1) + alpha*zz(1:2:end-2);
  z(3:2:end-1) = (1-alpha)*zz(3:2:end-1) + alpha*zz(4:2:end);
  z(end+1) = NaN;

  % align the data
  data = repelem(data(Fid(~isnan(Fid)),:),2,1);
  color = nan(length(y),size(data,2));
  color(~isnan(y),:) = data;
  color = reshape(color,size(color,1),1,size(color,2));
  
   % subdivion
  % for some reason it is important to subdivide it into parts
  for k = 1:ceil(length(x)/1000) 
    
    subId = max(1,(k-1)*1000) : min(k*1000,length(x));
  
    % plot the line
    %z = zeros(length(subId),2);
    p(k) = surface([x(subId),x(subId)],[y(subId),y(subId)],[z(subId),z(subId)],...
      repmat(color(subId,:,:),1,2,1),...
      'FaceColor','none','EdgeColor','interp','parent',mP.ax);
    
    if k>1
      set(get(get(p(k),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
    
  end
  
else % color given directly
    
  color = str2rgb(get_option(varargin,{'linecolor','edgecolor','facecolor'},'k'));
    
  %p = patch(x,y,'r','faceColor','none','hitTest','off','parent',mP.ax,'EdgeColor',color);
  
  % subdivion
  % for some reason it is important to subdivide it into parts
  for k = 1:ceil(length(x)/2000) 
    subId = max(1,(k-1)*2000) : min(k*2000,length(x));
    p(k) = line(x(subId),y(subId),z(subId),...
      'hitTest','off','parent',mP.ax,'color',color,'lineJoin','round');
    
    if k>1
      set(get(get(p(k),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
    
  end
  
end

h = optiondraw(p,varargin{:});

end


function plotSimple(gB,varargin)
obj.Faces    = gB.F;
obj.Vertices = gB.V.xyz;
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