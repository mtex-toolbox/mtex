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
%   plot(gB('Forsterite','Forsterite'),color)
%
% Input
%  grains - @grain2d
%  gB     - @grainBoundary
%  color  - n x 3 list of RGB values
%  
% Options
%  linewidth - line width
%  LineColor - line color
%  edgeAlpha - (list of) transparency values between 0 and 1
%  region    - [xmin xmax ymin ymax] plot only a subregion
%  DisplayName - label to appear in the legend
%  smooth      - try to make a smooth connections at the vertices
%

reg = get_option(varargin,'region');
if ~isempty(reg)
  
  V = gB.allV.xyz;
  F = gB.F;
  ind = V(F(:,1),1) > reg(1) & V(F(:,1),1) < reg(2)  & ...
    V(F(:,2),1) > reg(1) & V(F(:,2),1) < reg(2) & ...
    V(F(:,1),2) > reg(3) & V(F(:,1),2) < reg(4)  & ...
    V(F(:,2),2) > reg(3) & V(F(:,2),2) < reg(4);
  
  gB = gB.subSet(ind);
  
end

% create a new plot
pC = gB.how2plot; % a value class - this is already a private copy
if isnull(dot(pC.outOfScreen,gB.N)), pC.outOfScreen = gB.N; end
mtexFig = newMtexFigure(varargin{:});
[mP,isNew] = newMapPlot('scanUnit',gB.scanUnit,'parent',mtexFig.gca,varargin{:},pC);

if get_option(varargin,'linewidth',0) > 3 || check_option(varargin,'smooth')
  plotOrdered2(gB,varargin{:});
else
  plotSimple(gB,varargin{:});
end

% if no DisplayName is set remove patch from legend
if ~check_option(varargin,'DisplayName')
  % h is empty if the boundary was empty and nothing has been drawn
  if ~isempty(h), h(1).Annotation.LegendInformation.IconDisplayStyle = 'off'; end
else
  legend('-DynamicLegend','location','NorthEast');
end

% apply the plotting convention to the axis
mP.how2plot.setView(mP.ax);

if isNew, try axis(mP.ax,'tight'); end, end
mP.micronBar.setOnTop

if nargout == 0, clear h; end

% finalize plot
if ~isstruct(mtexFig)  
  if isNew, mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); end
  if isscalar(mtexFig.children), mtexFig.keepAspectRatio = false; end
end


function plotOrdered2(gB,varargin)

% Segments are stored in walk order, so each chain is a contiguous block of
% rows and its polyline is simply its segments one after another. Emitting
% both vertices of every segment keeps the line continuous - consecutive
% segments repeat the shared vertex - while giving each segment its own pair
% of entries to carry its own colour. A NaN after each chain breaks the line.
nF = length(gB);
isEnd = gB.isChainEnd;
pos = 2*(1:nF).' - 1 + cumsum([0; double(isEnd(1:end-1))]);

xyz = gB.allV.xyz;
XYZ = nan(2*nF + nnz(isEnd),3);
XYZ(pos,:) = xyz(gB.F(:,1),:);
XYZ(pos+1,:) = xyz(gB.F(:,2),:);

x = XYZ(:,1); y = XYZ(:,2); z = XYZ(:,3);
z(isnan(z)) = 0; % x and y already break the line at the separators

% color given by second argument
if nargin > 1 && isnumeric(varargin{1}) && ...
    (size(varargin{1},1) == length(gB) || size(varargin{1},2) == length(gB))

  if size(varargin{1},1) ~= length(gB), varargin{1} = varargin{1}.'; end
  data = reshape(varargin{1},length(gB),[]);

  % MATLAB interpolates colours between vertices, but both entries of a
  % segment get that segment's colour, so the interpolation is constant
  % along it and no colour bleeds across a segment boundary
  color = nan(numel(x),size(data,2));
  color(pos,:) = data;
  color(pos+1,:) = data;
  color = reshape(color,size(color,1),1,size(color,2));

   % subdivion
  % for some reason it is important to subdivide it into parts
  p = gobjects(1,ceil(length(x)/1000));
  for k = 1:ceil(length(x)/1000) 
    
    subId = max(1,(k-1)*1000) : min(k*1000,length(x));
  
    % plot the line
    %z = zeros(length(subId),2);
    p(k) = surface([x(subId),x(subId)],[y(subId),y(subId)],[z(subId),z(subId)],...
      repmat(color(subId,:,:),1,2,1),...
      'FaceColor','none','EdgeColor','interp','parent',mP.ax);
    
    if k>1
      p(k).Annotation.LegendInformation.IconDisplayStyle = 'off';      
    end
    
  end
  
else % color given directly
    
  color = str2rgb(get_option(varargin,{'linecolor','edgecolor','facecolor'},'k'));
    
  %p = patch(x,y,'r','faceColor','none','hitTest','off','parent',mP.ax,'EdgeColor',color);
  
  % subdivion
  % for some reason it is important to subdivide it into parts
  p = gobjects(1,ceil(length(x)/2000));
  for k = 1:ceil(length(x)/2000) 
    subId = max(1,(k-1)*2000) : min(k*2000,length(x));
    p(k) = line(x(subId),y(subId),z(subId),...
      'hitTest','off','parent',mP.ax,'color',color,'lineJoin','round');
    
    if k>1
      p(k).Annotation.LegendInformation.IconDisplayStyle = 'off';
    end
    
  end
  
end

h = optiondraw(p,varargin{:});

end


function plotSimple(gB,varargin)
obj.Faces    = gB.F;
obj.Vertices = gB.allV.xyz;
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