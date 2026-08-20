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
  if ~isempty(varargin) && ~isempty(varargin{1}) ...
      && (islogical(varargin{1}) || isnumeric(varargin{1})) 

    cdata = double(varargin{1});
    S2G = v;
    
  else % no color given -> do kernel density estimation

    sR = sP(j).sphericalRegion;
    if isfield(v.opt,'region'), sR = [sR,v.opt.region]; end %#ok<AGROW> 
    S2G = plotS2Grid(sR,varargin{:});

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
  %if ~any(isnan(colorRange)), caxis(sP(j).ax,colorRange);end

  % ------------- compute contour lines ------------------------

  % number of contour lines
  contours = get_option(varargin,'contours',50);
  contours = get_option(varargin,{'contourf','contour'},contours,'double');
  
  % specify contour lines explicitly
  if isscalar(contours)
    if check_option(varargin,'log')
      % a contoured ODF routinely has a small negative minimum, and log10 of
      % a non positive bound returns complex levels which contourf then
      % rejects - start at the smallest positive value instead
      lowerBound = colorRange(1);
      if ~(lowerBound > 0), lowerBound = min(cdata(cdata > 0)); end
    else
      lowerBound = [];
    end

    % nothing positive to space logarithmically -> stay linear
    if ~isempty(lowerBound) && colorRange(2) > lowerBound
      contours = logspace(log10(lowerBound),log10(colorRange(2)),contours);
    else
      contours = linspace(colorRange(1),colorRange(2),contours);
    end
  end

  % ----------------- draw contours ------------------------------

  hG = holdOn(sP(j).ax); %#ok<NASGU>

  % project data
  [x,y] = project(sP(j).proj,S2G,'noAntipodal');

  % extract non nan data
  data = reshape(cdata,size(x));

  % plot contours
  h = [h,betterContourf(sP(j).ax,x,y,data,contours,varargin{:})]; %#ok<AGROW>

  clear hG

  % --------------- finalize the plot ---------------------------

  % adjust clim according to colorRange
  if ~any(isnan(colorRange)) && diff(colorRange)>0
    clim(sP(j).ax,colorRange); 
  end
  % both spellings, as in optionplot and setColorRange - the flag documented
  % on plotPDF, plotIPDF and plotSection is the long one
  if check_option(varargin,{'logarithmic','log'})
    sP(j).ax.ColorScale = 'log';
  end

  % colormap
  if ~strcmpi(get_option(varargin,'fill'),'off')
    mtexColorMap(sP(j).ax,getMTEXpref('defaultColorMap'));
    if size(sP(j).ax.Colormap,1) < length(contours)
      oldMap = sP(j).ax.Colormap;
      xOld = linspace(0,1,size(oldMap,1));
      xNew = linspace(0,1,length(contours));
      newMap = interp1(xOld,oldMap,xNew,'linear');
      mtexColorMap(newMap)
    end
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

% A plotting grid may consist of several strips separated by columns of
% NaN, since a disconnected region can not be swept by a single one. Unlike
% surface, contourf does not skip the cells around such a column but draws
% garbage across the gap - so draw one contour object per strip.
if ~check_option(varargin,'pcolor')
  sep = find(all(~isfinite(X),1));
  if ~isempty(sep)
    bnd = [0,sep,size(X,2)+1];
    h = gobjects(1,0);
    for k = 1:numel(bnd)-1
      ind = bnd(k)+1:bnd(k+1)-1;
      if numel(ind) < 2, continue; end
      h = [h,betterContourf(ax,X(:,ind),Y(:,ind),data(:,ind),contours,varargin{:})]; %#ok<AGROW>
    end
    return
  end
end

if isscalar(unique(data)), data(1) = data(1) + 2*eps; end

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
h.Annotation.LegendInformation.IconDisplayStyle = 'off';

end
