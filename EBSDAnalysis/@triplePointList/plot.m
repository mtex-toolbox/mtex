function h = plot(tP,varargin)
% plot triple points
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
%  marker    - square, diamond, circle, asterics, 
%  markerSize - size of the marker
%  markerEdgeColor - edge color
%  markerFaceColor - face color
%  markerColor     - both colors
%  linewidth - edge width of the marker
%
% See also
% <https://www.mathworks.com/help/matlab/ref/matlab.graphics.primitive.patch-properties.html patch properties>

% create a new plot
[mtexFig,isNew] = newMtexFigure(varargin{:});
mP = newMapPlot('scanUnit','um','parent',mtexFig.gca,varargin{:});


numTP = length(tP);

reg = get_option(varargin,'region');
if ~isempty(reg)
  
  ind = tP.x > reg(1) & tP.x < reg(2) &  tP.y > reg(3) & tP.y < reg(4);

  obj.Vertices = tP.V(ind,:);
  
else
  
  obj.Vertices = tP.V;  
end

obj.Faces    = 1:size(obj.Vertices,1);
obj.parent = mP.ax;
obj.FaceColor = 'none';
obj.EdgeColor = 'none';
obj.Marker = 'o';
obj.hitTest = 'off';

% color given by second argument
if nargin > 1 && isnumeric(varargin{1}) && ...
    (size(varargin{1},1) == numTP || size(varargin{1},2) == numTP)

  if size(varargin{1},1) ~= numTP, varargin{1} = varargin{1}.'; end
  
  % extract colorcoding
  cdata = varargin{1};
  if numel(cdata) == numTP
     cdata = reshape(cdata,[],1);
  else
    cdata = reshape(cdata,[],3);
  end
  if ~isempty(reg), cdata = cdata(ind,:); end
  obj.FacevertexCData = cdata;
    
  obj.markerFaceColor = 'flat';
  obj.markerEdgeColor = 'flat';

else % color given directly
    
  obj.MarkerFaceColor = 'none';
  if isNew
    defColor = 'k';
  else
    defColor = 'w';
  end
  obj.MarkerEdgeColor = str2rgb(get_option(varargin,{'color','markerColor'},defColor));
  
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
