function [h,ax] = smooth(v,varargin)
% low level function for plotting functions on the sphere
%
% Syntax
%   smooth(v,values)
%
% Input
%
% Output
%
% Options
%
% See also
%

h = [];

% initialize spherical plot
opt = delete_option(varargin,{'lineStyle','lineColor','lineWidth','color'},1);
sP = newSphericalPlot(v,opt{:},'doNotDraw');

for j = 1:numel(sP)
  
  % ---------------- extract colors --------------------------

  % color given by the first argument?
  if ~isempty(varargin) && isnumeric(varargin{1}) && ~isempty(varargin{1})

    cdata = varargin{1};
    S2G = v;
    
  else % no color given -> do kernel density estimation

    sR = sP(j).sphericalRegion;
    if isfield(v.opt,'region'), sR = [sR,v.opt.region]; end
    S2G = plotS2Grid(sR);

    cdata = calcDensity(v(:),S2G,'halfwidth',5*degree,varargin{:});    
    cdata = reshape(cdata,size(S2G));
    
  end

  sP(j).updateMinMax(cdata);
  
  % interpolate if no regular grid was given
  if ~isOption(S2G,'plot') || ~S2G.opt.plot
    
    if size(S2G,1) == 1 || size(S2G,2) == 1

      S2G = plotS2Grid(sP(j).sphericalRegion,varargin{:});
      cdata = interp(v,cdata,S2G,'cutOutside',varargin{:});
      
    elseif ~isa(sP(j).proj,'plainProjection')
      
      % close the gap between 0 and 2*pi
      varargin = set_option(varargin,'correctContour');
      
    end
  end
  
  % scale the data
  [cdata,colorRange] = scaleData(cdata,varargin{:});
  if ~any(isnan(colorRange)), caxis(sP(j).ax,colorRange);end

  % ------------- compute contour lines ------------------------

  % number of contour lines
  contours = get_option(varargin,'contours',50);
  contours = get_option(varargin,{'contourf','contour'},contours,'double');
  
  % specify contourlines explicitely
  if length(contours) == 1
    contours = linspace(colorRange(1),colorRange(2),contours);
  end

  % ----------------- draw contours ------------------------------

  washold = ishold(sP(j).ax);
  hold(sP(j).ax,'on')

  % project data
  [x,y] = project(sP(j).proj,S2G,'noAntipodal');

  % extract non nan data
  data = reshape(cdata,size(x));

  % plot contours
  h = [h,betterContourf(sP(j).hgt,x,y,data,contours,varargin{:})]; %#ok<AGROW>
  
  if ~washold, hold(sP(j).ax,'off'); end
  
  % --------------- finalize the plot ---------------------------

  % adjust caxis according to colorRange
  if ~any(isnan(colorRange)), caxis(sP(j).ax,colorRange); end

  % colormap
  if ~strcmpi(get_option(varargin,'fill'),'off')
    mtexColorMap(sP(j).ax,getMTEXpref('defaultColorMap'));
  end

  % bring grid in front
  sP(j).doGridInFront;

  sP(j).plotAnnotate(varargin{:})
  
end

% set styles
varargin = delete_option(varargin,'parent',1);
optiondraw(h,varargin{:});

if isappdata(sP(1).parent,'mtexFig')
  mtexFig = getappdata(sP(1).parent,'mtexFig');
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
end

if nargout == 0
  clear h; 
else
  ax = [sP.ax];
end

end

% ------------------------------------------------------------
function h = betterContourf(ax,X,Y,data,contours,varargin)

if numel(unique(data)) == 1, data(1) = data(1) + 2*eps; end

% workauround for a MATLAB Bug
%if mean(X(:,1)) > mean(X(:,end))
%  X = fliplr(X);
%  Y = fliplr(Y);
%  data = flipdim(data,2);
%end

% contour correction
if check_option(varargin,'correctContour')
  X = [X;X(1,:)];
  Y = [Y;Y(1,:)];
  data = [data;data(1,:)];
end

if check_option(varargin,'pcolor')
  
  opt = {};
  if numel(data) >= 500
    opt = {'LineStyle','none','FaceColor','interp'};    
  end
  
  % pcolor is actually surface
  h = surface(X,Y,zeros(size(X)),data,opt{:},'parent',ax);

else

  % extract style
  opt = extract_argoption([{'LineStyle','none','Fill','on'},varargin],{'LineStyle','Fill','LineColor'});
  
  if ~check_option(varargin,'contour')
    [CM,h] = contourf(X,Y,data,contours,opt{:},'parent',ax); %#ok<ASGLU>
  else
    [CM,h] = contour(X,Y,data,contours,opt{:},'parent',ax); %#ok<ASGLU>
  end
  
  
end

% do not display in the legend
set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

end
