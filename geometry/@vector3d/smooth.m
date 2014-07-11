function varargout = smooth(v,varargin)
%
%% Syntax
%
%% Input
%
%% Output
%
%% Options
%
%% See also
%

%% get input

% where to plot
[ax,v,varargin] = splitNorthSouth(v,varargin{:},'smooth');
if isempty(ax), return;end

% extract projection
[projection,extend] = getProjection(ax,v,varargin{:});

% why should I do this?
%hfig = get(ax,'parent');
%set(hfig,'color',[1 1 1]);

%% extract colors

% color given by the first argument?
if ~isempty(varargin) && isnumeric(varargin{1})

  cdata = varargin{1};

else % no color given -> do kernel density estimation


  out = S2Grid('plot',...
    'minTheta',extend.minTheta,...
    'maxTheta',extend.maxTheta,...
    'minRho',extend.minRho,...
    'maxRho',extend.maxRho,varargin{:});

  cdata = kernelDensityEstimation(v(:),out,'halfwidth',5*degree,varargin{:});
  v = out;

  cdata = reshape(cdata,size(v));
end

%% interpolate if no regular grid was given

% may be externalize this into a funtion interp of S2Grid
if ~check_option(v,'plot')

  if size(v,1) == 1 || size(v,2) == 1

    % specify a plotting grid
    theta = polar(v);
    res = max(2.5*degree,get(v,'resolution'));

    minTheta = min(theta);
    maxTheta = max(theta);
    if minTheta < 1*degree, minTheta = 0;end
    if abs(maxTheta-pi/2)<1*degree, maxTheta = pi/2;end
    if abs(maxTheta-pi)<1*degree, maxTheta = pi;end
    extend.minTheta = max(extend.minTheta,minTheta);
    if isnumeric(extend.maxTheta)
      extend.maxTheta = min(extend.maxTheta,maxTheta);
    end

    myPlotGrid = S2Grid('plot','resolution',res,...
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
  elseif ~strcmp(projection.type,'plain')
    varargin = set_option(varargin,'correctContour');
  end
end


%% scale the data

[cdata,colorRange,minData,maxData] = scaleData(cdata,varargin{:});
if ~any(isnan(colorRange)), caxis(ax,colorRange);end


%% compute contour lines

% number of contour lines
contours = get_option(varargin,'contours',50);

% specify contourlines explicetly
if length(contours) == 1
  contours = linspace(colorRange(1),colorRange(2),contours);
end

%% draw contours

hold(ax,'on')

% project data
[x,y] = project(v,projection,extend,'removeAntipodal');

% extract non nan data
ind = ~isnan(x);
x = submatrix(x,ind);
y = submatrix(y,ind);
data = reshape(submatrix(cdata,ind),size(x));

% plot contours
h = betterContourf(ax,x,y,data,contours,varargin{:});

hold(ax,'off')

% set styles
optiondraw(h,'LineStyle','none','Fill','on',varargin{:});

%% finalize the plot

% adjust caxis according to colorRange
if ~any(isnan(colorRange)), caxis(ax,colorRange); end

% colormap
colormap(ax,getMTEXpref('defaultColorMap'));

% plot polar grid
plotGrid(ax,projection,extend,varargin{:});

% add annotations
if ~strcmpi(get_option(varargin,'minmax'),'off')
  varargin = [{'BL',{'Min:',xnum2str(minData,0.2)},'TL',{'Max:',xnum2str(maxData,0.2)}} varargin];
end

plotAnnotate(ax,varargin{:})

% output
if nargout > 0
  varargout{1} = h;
end

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
  end



elseif ~check_option(varargin,'fill',[],'off')
  h = fill(X,Y,data,'LineStyle','none','parent',ax);
end
