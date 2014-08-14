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

  else % no color given -> do kernel density estimation

    out = plotS2Grid(sP.sphericalRegion);

    cdata = kernelDensityEstimation(v(:),out,'halfwidth',5*degree,varargin{:});
    v = out;

    cdata = reshape(cdata,size(v));
  end

  % -------------- interpolate if no regular grid was given ---------

  % may be externalize this into a funtion interp of S2Grid
  if ~isOption(v,'plot') || ~v.opt.plot

    if size(v,1) == 1 || size(v,2) == 1

      % specify a plotting grid
      theta = polar(v);
      res = max(2.5*degree,v.resolution);

      minTheta = min(theta);
      maxTheta = max(theta);
      if minTheta < 1*degree, minTheta = 0;end
      if abs(maxTheta-pi/2)<1*degree, maxTheta = pi/2;end
      if abs(maxTheta-pi)<1*degree, maxTheta = pi;end
      extend.minTheta = max(extend.minTheta,minTheta);
      if isnumeric(extend.maxTheta)
        extend.maxTheta = min(extend.maxTheta,maxTheta);
      end

      myPlotGrid = plotS2Grid('resolution',res,...
        'minTheta',extend.minTheta,...
        'maxTheta',extend.maxTheta,...
        'minRho',extend.minRho,...
        'maxRho',extend.maxRho,...
        'restrict2minmax',varargin{:});

      % interpolate on the plotting grid
      [ind,d] = find(v,vector3d(myPlotGrid)); % nearest neighbour interpolation
      cdata = cdata(ind);
      cdata(d < cos(2*res)) = nan;
      v = myPlotGrid;
      clear myPlotGrid;
      cdata = reshape(cdata,size(v));
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

  % specify contourlines explicetly
  if length(contours) == 1
    contours = linspace(colorRange(1),colorRange(2),contours);
  end

  % ----------------- draw contours ------------------------------

  hold(sP(j).ax,'on')

  % project data
  [x,y] = project(sP(j).proj,v,'removeAntipodal');

  % extract non nan data
  ind = ~isnan(x);
  x = submatrix(x,ind);
  y = submatrix(y,ind);
  data = reshape(submatrix(cdata,ind),size(x));

  % plot contours
  h(end+1) = betterContourf(sP(j).ax,x,y,data,contours,varargin{:});   
  
  hold(sP(j).ax,'off')
  
  % --------------- finalize the plot ---------------------------

  % adjust caxis according to colorRange
  if ~any(isnan(colorRange)), caxis(sP(j).ax,colorRange); end

  % colormap
  colormap(sP(j).ax,getMTEXpref('defaultColorMap'));

  % add annotations
  if strcmpi(get_option(varargin,'minmax'),'on')
    varargin = [{'BL',{'Min:',xnum2str(minData,0.2)},'TL',{'Max:',xnum2str(maxData,0.2)}} varargin];
  end

  % bring grid in front
  sP(j).doGridInFront;

  sP(j).plotAnnotate(varargin{:})
  
end

% set styles
optiondraw(h,'LineStyle','none','Fill','on',varargin{:});


if nargout == 0, clear h; end

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
  h = fill(X,Y,data,'LineStyle','none','parent',ax);
end
