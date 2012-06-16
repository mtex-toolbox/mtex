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
[ax,v,varargin] = getAxHandle(v,varargin{:});

% extract projection
projection = getProjection(ax,v,varargin{:});

% initalize handles
h = [];

% why should I do this?
hfig = get(ax,'parent');
set(hfig,'color',[1 1 1]);

%% extract colors

% color given by the first argument?
if ~isempty(varargin) && isnumeric(varargin{1})
  
  cdata = varargin{1};
  
else % no color given -> do kernel density estimation
  
  
  out = S2Grid('plot',...
    'minTheta',projection.minTheta,...
    'maxTheta',projection.maxTheta,...
    'minRho',projection.minRho,...
    'maxRho',projection.maxRho);
  
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
    
    myPlotGrid = S2Grid('plot','resolution',res,...
      'mintheta',min(theta),'maxtheta',max(theta),'restrict2minmax',varargin{:});
    
    % interpolate on the plotting grid
    [ind,d] = find(v,vector3d(myPlotGrid)); % nearest neighbour interpolation
    cdata = cdata(ind); 
    cdata(d < cos(2*res)) = nan;
    v = myPlotGrid;
    clear myPlotGrid;
    cdata = reshape(cdata,size(v));
    
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

if strcmpi(projection.type,'plain') % plain plot
  
  [xu,yu] = project(v,projection);
  
  cdata = reshape(cdata,size(xu));
  [CM,h(end+1)] = contourf(ax,xu,yu,cdata,contours); %#ok<ASGLU>


else % spherical plot  
  
  hold(ax,'on')
    
  % plot upper hemisphere
  if projection.minTheta < pi/2-0.0001 
  
    % split data according to upper and lower hemisphere
    ind = v.z > -1e-5;
    v_upper = submatrix(v,ind);
    data_upper = reshape(submatrix(cdata,ind),size(v_upper));
    
    % project data
    [xu,yu] = project(v_upper,projection);
    
    % plot filled contours
    [~,h(end+1)] = contourf(ax,xu,yu,data_upper,contours);
    
  end
  
  % plot lower hemisphere
  if isnumeric(projection.maxTheta) && projection.maxTheta > pi/2 + 1e-4 ...
      && any(v.z(:) < -1e-4);
    
    % split data according to upper and lower hemisphere
    ind = v.z < 1e-5;
    v_lower = submatrix(v,ind);
    data_lower = reshape(submatrix(cdata,ind),size(v_lower));
    
    % plot filled contours
    [xl,yl] = project(v_lower,projection,'equator2south');
    [CM,h(end+1)] = contourf(ax,xl,yl,data_lower,contours); %#ok<ASGLU>
    
  end
  
  hold(ax,'off')
end

% set styles
optiondraw(h,'LineStyle','none',varargin{:});
optiondraw(h,'Fill','on',varargin{:});

%% finalize the plot

% adjust caxis according to colorRange
if ~any(isnan(colorRange)), caxis(ax,colorRange); end

% colormap
colormap(ax,getpref('mtex','defaultColorMap'));

% plot polar grid
plotGrid(ax,projection,varargin{:});

% add annotations
opts = {'BL',{'Min:',xnum2str(minData)},'TL',{'Max:',xnum2str(maxData)}};

plotAnnotate(ax,opts{:},varargin{:})

% output
if nargout > 0
  varargout{1} = h;
end

