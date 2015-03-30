function h = smooth(v,varargin)
%
% Syntax
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
sP = newSphericalPlot(v,varargin{:});

for j = 1:numel(sP)
  
  % ---------------- extract colors --------------------------

  % color given by the first argument?
  if ~isempty(varargin) && isnumeric(varargin{1}) && ~isempty(varargin{1})

    cdata = varargin{1};
    S2G = v;
    
  else % no color given -> do kernel density estimation

    S2G = plotS2Grid(sP(j).sphericalRegion);

    cdata = kernelDensityEstimation(v(:),S2G,'halfwidth',5*degree,varargin{:});    
    cdata = reshape(cdata,size(S2G));
    
  end

  % interpolate if no regular grid was given
  if ~isOption(S2G,'plot') || ~S2G.opt.plot
    
    if size(S2G,1) == 1 || size(S2G,2) == 1

      S2G = plotS2Grid(sP(j).sphericalRegion,'resolution',2.5*degree,varargin{:});
      cdata = interp(v,cdata,S2G);
      
    elseif ~isa(sP.proj,'plainRojection')
      
      % close the gap between 0 and 2*pi
      varargin = set_option(varargin,'correctContour');
      
    end
  end
  
  % scale the data
  [cdata,colorRange,minData,maxData] = scaleData(cdata,varargin{:});
  if ~any(isnan(colorRange)), caxis(sP(j).ax,colorRange);end

  % ------------- compute contour lines ------------------------

  % number of contour lines
  contours = get_option(varargin,'contours',50);

  % specify contourlines explicitely
  if length(contours) == 1
    contours = linspace(colorRange(1),colorRange(2),contours);
  end

  % ----------------- draw contours ------------------------------

  hold(sP(j).ax,'on')

  % project data
  [x,y] = project(sP(j).proj,S2G,'removeAntipodal');

  % extract non nan data
  ind = ~isnan(x);
  x = submatrix(x,ind);
  y = submatrix(y,ind);
  data = reshape(submatrix(cdata,ind),size(x));

  % plot contours
  h = [h,betterContourf(sP(j).ax,x,y,data,contours,varargin{:})];
  
  hold(sP(j).ax,'off')
  
  % --------------- finalize the plot ---------------------------

  % adjust caxis according to colorRange
  if ~any(isnan(colorRange)), caxis(sP(j).ax,colorRange); end

  % colormap
  colormap(sP(j).ax,getMTEXpref('defaultColorMap'));

  % add annotations
  if check_option(varargin,'minmax')
    varargin = [{'BL',{'Min:',xnum2str(minData,0.2)},...
      'TL',{'Max:',xnum2str(maxData,0.2)}} varargin]; %#ok<AGROW>
  end

  % bring grid in front
  sP(j).doGridInFront;

  sP(j).plotAnnotate(varargin{:})
  
end

% set styles
varargin = delete_option(varargin,'parent');
optiondraw(h,'LineStyle','none','Fill','on',varargin{:});

if isappdata(sP(1).parent,'mtexFig')
  mtexFig = getappdata(sP(1).parent,'mtexFig');
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
end

if nargout == 0, clear h; end

end

% ------------------------------------------------------------
function h = betterContourf(ax,X,Y,data,contours,varargin)

h = [];

if numel(unique(data)) > 1

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
    h = pcolor(ax,X,Y,data);
    
    % do not display in the legend
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    
    if numel(data) >= 500
     if length(unique(data))<50
       shading flat;
     else
       shading interp;
       set(gcf,'Renderer','zBuffer');
     end
    else
      set(gcf,'Renderer','painters');
    end
  else
    [CM,h] = contourf(ax,X,Y,data,contours); %#ok<ASGLU>
    
    % do not display in the legend
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
  end

elseif ~check_option(varargin,'fill',[],'off')
  % transpose here seems to be needed due to a MATLAB bug
  h = fill(X.',Y.',data.','LineStyle','none','parent',ax);
end

end
