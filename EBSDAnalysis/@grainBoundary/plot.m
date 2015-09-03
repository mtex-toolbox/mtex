function [h,mP] = plot(gB,varargin)
% plot grain boundaries
%
% The function plots grain boundaries where the boundary is determined by
% the function <GrainSet.specialBoundary.html specialBoundary>
%
% Syntax
%   plot(grains.boundary)
%   plot(grains.innerBoundary,'linecolor','r')
%   plot(gB('Forsterite','Forsterite'),gB('Forsterite','Forsterite').misorientation.angle)
%
% Input
%  grains  - @grainBoundary
%  
% Options
%  linewidth
%  linecolor
%


% create a new plot
[mtexFig,isNew] = newMtexFigure(varargin{:});
mP = newMapPlot('scanUnit',gB.scanUnit,'parent',mtexFig.gca,varargin{:});

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

% if no DisplayName is set remove patch from legend
if ~check_option(varargin,'DisplayName')
  set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
end
warning('off','MATLAB:legend:PlotEmpty');
legend('-DynamicLegend','location','NorthEast');
warning('on','MATLAB:legend:PlotEmpty');

try axis(mP.ax,'tight'); end
set(mP.ax,'zlim',[0,1]);
mP.micronBar.setOnTop

if nargout == 0, clear h; end
if isNew, mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); end
mtexFig.keepAspectRatio = false;
