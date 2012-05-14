function varargout = surf(v,varargin)
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

% extract plot options
projection = plotOptions(ax,v,varargin{:});

% initalize handles
h = [];

% why should I do this?
hfig = get(ax,'parent');
set(hfig,'color',[1 1 1]);

% extract colors 
cdata = varargin{1};

set(gcf,'renderer','zBuffer');
shading interp

%% draw surface


if strcmpi(projection.type,'plain') % plain plot
  
  [xu,yu] = project(v,projection);
  
  w = reshape(w,size(xu));
  [CM,h(end+1)] = contourf(ax,xu,yu,w,contours); %#ok<ASGLU>


else % spherical plot  
  
  hold(ax,'on')
    
  % plot upper hemisphere
  if projection.minTheta < pi/2-0.0001 
  
    % split data according to upper and lower hemisphere
    ind = v.z > -1e-5;
    v_upper = submatrix(v,ind);
    data_upper = reshape(submatrix(cdata,ind),[size(v_upper) 3]);
    
    % project data
    [xu,yu] = project(v_upper,projection);
    
    % plot surface
    h(end+1) = surf(ax,xu,yu,zeros(size(xu)),real(data_upper));
    
  end
  
  % plot lower hemisphere
  if isnumeric(projection.maxTheta) && projection.maxTheta > pi/2 + 1e-4
    
    % split data according to upper and lower hemisphere
    ind = v.z < 1e-5;
    v_lower = submatrix(v,ind);
    data_lower = reshape(submatrix(cdata,ind),[size(v_lower) 3]);
    
    % plot surface
    [xl,yl] = project(v_lower,projection,'equator2south');
    h(end+1) = surf(ax,xl,yl,zeros(size(xl)),real(data_lower));
  end
  
  hold(ax,'off')
end

% set styles
optiondraw(h,'LineStyle','none',varargin{:});
optiondraw(h,'Fill','on',varargin{:});

%% finalize the plot

% plot polar grid
plotGrid(ax,projection,varargin{:});

% plot annotations
plotAnnotate(ax,varargin{:})

% output
if nargout > 0
  varargout{1} = h;
end

