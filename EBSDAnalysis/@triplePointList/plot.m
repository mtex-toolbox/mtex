function h = plot(tP,varargin)
% plot grain boundaries
%
% Syntax
%   plot(grains.triplePoints)
%   plot(grains.triplePoints,'color','r')
%   plot(grains('Forsterite').triplePoints,gB('Forsterite','Forsterite').misorientation.angle)
%
% Input
%  tP  - @triplePointList
%  
% Options
%  linewidth
%  linecolor
%

% create a new plot
[mtexFig,isNew] = newMtexFigure(varargin{:});
mP = newMapPlot('scanUnit','um','parent',mtexFig.gca,varargin{:});

obj.Faces    = 1:length(tP.V);
obj.Vertices = tP.V;
obj.parent = mP.ax;
obj.FaceColor = 'none';
obj.EdgeColor = 'none';
obj.Marker = 'o';
obj.hitTest = 'off';

% color given by second argument
if nargin > 1 && isnumeric(varargin{1}) && ...
    (size(varargin{1},1) == length(tP) || size(varargin{1},2) == length(tP))

  if size(varargin{1},1) ~= length(tP), varargin{1} = varargin{1}.'; end
  
    % extract colorpatchArgs{3:end}coding
  cdata = varargin{1};
  if numel(cdata) == length(tP)
    obj.FacevertexCData = reshape(cdata,[],1);
  else
    obj.FacevertexCData = reshape(cdata,[],3);
  end

  obj.markerFaceColor = 'flat';
  obj.markerEdgeColor = 'flat';

else % color given directly
    
  obj.MarkerFaceColor = 'none';
  if isNew
    defColor = 'k';
  else
    defColor = 'w';
  end
  obj.MarkerEdgeColor = get_option(varargin,{'color'},defColor);
  
end

h = optiondraw(patch(obj),varargin{:});

set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    
% since the legend entry for patch object is not nice we draw an
% invisible scatter dot just for legend
if check_option(varargin,'DisplayName') && exist('defColor','var')
  holdState = get(mP.ax,'nextPlot');
  set(mP.ax,'nextPlot','add');
  optiondraw(scatter(0,0,'parent',mP.ax,'visible','off',...
    'MarkerFaceColor',get(h,'MarkerFaceColor'),...
    'MarkerEdgeColor',get(h,'MarkerEdgeColor')),varargin{:});
  set(mP.ax,'nextPlot',holdState);
  
  legend('-DynamicLegend','location','NorthEast');
end

try axis(mP.ax,'tight'); end
mP.micronBar.setOnTop

if nargout == 0, clear h; end
if isNew, mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); end
mtexFig.keepAspectRatio = false;
