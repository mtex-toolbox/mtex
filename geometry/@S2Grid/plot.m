function  varargout = plot(S2G,varargin)
% plot spherical data
%
% *S2G/plot* plots data on the sphere
%
%% Syntax
%  plot(S2G,<options>)
%
%% Input
%  S2G - @S2Grid
%
%% Options
%  DATA     - coloring of the points [double] or {string}
%  DIAMETER - diameter for single points plot [double]
%  RANGE    - minimum and maximum for color coding [min,max]
%  CONTOUR  - number of contour lines or list of contour lines
%  CONTOURF - number of contour lines or list of contour lines
%  ROTATE   - rotate plot about z-axis
%  FLIPUD   - FLIP plot upside down
%  FLIPLR   - FLIP plot left to rigth
%  PROJECTION - {EAREA}, EDIST, PLAIN
%  HEMISPHERE - {NORTH | SOUTH | BOTH | IDENTIFIED}
%
%% Flags
%  NORTH       - plot only points on the north hemisphere (default)
%  SOUTH       - plot only points on the southern hemisphere
%  DOTS        - single points (default) 
%  SMOOTH      - interpolated plot 
%  CONTOUR     - contour plot
%  CONTOURF    - filled contour plot
%  EAREA       - equal-area projection (default)
%  EDIST       - equal-distance projection  
%  PLAIN       - no projection    
%  GRAY        - colormap - gray 
%  LOGARITHMIC - log plot
%
%% See also
% savefigure

% 3d plot is extern
if check_option(varargin,'3d'), plot3d(S2G,varargin{:});return; end

%% Prepare Axis

washold = ishold;
if ~check_option(varargin,'axis'), newplot;end
if isempty(get(gca,'children'))
  if isappdata(gcf,'projection'), rmappdata(gcf,'projection');end
  if isappdata(gcf,'hemisphere'), rmappdata(gcf,'hemisphere');end
end

if nargout > 0, varargout{1} = gca;end

if strcmp(get(gcf,'Tag'),'multiplot')
  varargin = {varargin{:},'annotate'};
end

set(gca,'Tag','S2Grid','Box','on','DataAspectRatio',[1 1 1],'XTick',[],'YTick',[],...
  'drawmode','fast','layer','top');

hold all

%%  GET OPTIONS 

% default plot options
global mtex_plot_options; 
varargin = {varargin{:},mtex_plot_options{:}};

% default diameter
varargin = {varargin{:},'diameter',min(0.2,max(0.02,0.75*getResolution(S2G(end))))};

% extract data
data = get_option(varargin,'DATA',[]);
if numel(data) == GridLength(S2G)
  data = reshape(data,GridSize(S2G)); 
else
  data = [];
end

% log plot? 
if check_option(varargin,'logarithmic')
  data = log10(data);
  data(imag(data) ~= 0) = -inf;
end

% COLORMAP
if check_option(varargin,'GRAY'),colormap(flipud(colormap('gray'))/1.2);end

% color
[ls,c] = nextstyle(gca);
varargin = {varargin{:},'color',c};


%% Prepare Coordinates
% calculate polar coordinates
[theta,rho] = polar(S2G);
if check_option(varargin,'rotate')
  rho = rho + get_option(varargin,'rotate',-pi/2,'double');
end

if check_option(varargin,'flipud')
  rho = 2*pi-rho;
end


%% Which Hemispheres to Plot

if isappdata(gcf,'hemisphere'), 
    
  hemisphere = getappdata(gcf,'hemisphere');
  
elseif check_option(varargin,{'reduced','plain','identified'})
  
  hemisphere = 'identified';
  
elseif check_option(varargin,'hemisphere','char')
  
  hemisphere = get_option(varargin,'hemisphere','char');
   
elseif check_option(S2G,'hemisphere','char')
  
  hemisphere = get_option(S2G(1).options,'hemisphere');

elseif max(theta(:)) > pi/2+0.001 
  
  hemisphere = 'both';
  
else
  
  hemisphere = 'north';

end

setappdata(gcf,'hemisphere',hemisphere);
  
bounds = [0,0,0,0];


%% Northern Hemisphere

if any(strcmpi(hemisphere,{'north','both','identified'}))
  if strcmp(hemisphere,'identified')
    ind = true(size(theta));    
  else
    ind = theta <= pi/2+0.001;
  end
  bounds = plotHemiSphere(submatrix(theta,ind),submatrix(rho,ind),...
    submatrix(data,ind),0,varargin{:});
end

%% Southern Hemisphere

if any(strcmpi(hemisphere,{'south','both'}))
  ind = theta >= pi/2-0.001;
  bounds = plotHemiSphere(pi-submatrix(theta,ind),submatrix(rho,ind),...
    submatrix(data,ind),bounds(3),varargin{:});
end


%% Finish

% Bounding Box
if ~check_option(varargin,{'annotate'})
  xlim([bounds(1),bounds(1)+bounds(3)]);
  ylim([bounds(2),bounds(2)+bounds(4)]);
end

if check_option(varargin,'plain') && ~check_option(varargin,'TIGHT')
  set(gca,'XTickmode','auto','YTickmode','auto')
  xlabel('rho');ylabel('theta')
end

% crop if neccary
if ~check_option(varargin,{'axis','annotate'})
  f = bounds(3) / bounds(4);
  set(gca,'units','normalized');
  set(gca,'position',[0.05/f 0.05 1-0.1/f 0.9]);
%  set(gca,'units','points');
  set(gcf,'units','points');
  fpos = get(gcf,'position');

  f = (f+0.1)/1.1;
  
  b = min(fpos(3) / f,fpos(4));
  set(gcf,'position',[fpos(1:2),b*f,b]);
  set(gcf,'Color',[1 1 1]);
  axis off;
end

% set hold back
if ~washold, hold off;end


%% Plot Hemisphere
function bounds = plotHemiSphere(theta,rho,data,offset,varargin)

% projection
[X,Y,bounds] = projectData(theta,rho,varargin{:});

% plot
box = bounds+[offset,0,bounds(1)+offset,bounds(2)];
plotData(X+offset,Y,data,box,varargin{:});

% bounding box
if ~check_option(varargin,{'PLAIN','annotate'})
  
  if (isempty(rho) || isnull(mod(rho(1)-rho(end),2*pi)) || ...
      ~(check_option(varargin,{'CONTOUR','SMOOTH'})))
    circle(bounds(1)+offset+bounds(3)/2,bounds(2)+bounds(4)/2,bounds(3)/2);
  else
    torte(X+offset,Y);
  end
  
end
bounds(3) = bounds(3) + offset;

%% Plot Circle
function circle(x,y,r)

rectangle('Position',[x-r,y-r,2*r,2*r],'Curvature',[1,1]);

%% Plot Tort
function torte(X,Y)

line(X(:,1),Y(:,1),'color','k')%,'LineWidth',2)
line(X(:,end),Y(:,end),'color','k')%,'LineWidth',2)
line(X(end,:),Y(end,:),'color','k')%,'LineWidth',2)
line(X(1,:),Y(1,:),'color','k')%,'LineWidth',2)
