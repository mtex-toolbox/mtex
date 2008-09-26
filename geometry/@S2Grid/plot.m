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
%  MarkerSize - diameter for single points plot [double]
%  RANGE    - minimum and maximum for color coding [min,max]
%  CONTOUR  - number of contour lines or list of contour lines
%  CONTOURF - number of contour lines or list of contour lines
%  ROTATE   - rotate plot about z-axis
%  FLIPUD   - FLIP plot upside down
%  FLIPLR   - FLIP plot left to rigth
%  PROJECTION - {EAREA}, EDIST, PLAIN
%
%% Flags
%  NORTH       - plot only points on the north hemisphere (default)
%  SOUTH       - plot only points on the southern hemisphere
%  REDUCED     - project all data to nothern hemisphere
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
% savefigure plot_index Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 


% 3d plot is extern
if check_option(varargin,'3d'), plot3d(S2G,varargin{:});return; end

%% Prepare Axis

washold = ishold;
if ~check_option(varargin,'axis'), newplot;end
if isempty(get(gca,'children')) || all(strcmp(get(get(gca,'children'),'type'),'text'))
  if isappdata(gcf,'projection'), rmappdata(gcf,'projection');end
  if isappdata(gcf,'rotate'), rmappdata(gcf,'rotate');end
  if isappdata(gcf,'flipud'), rmappdata(gcf,'flipud');end
  if isappdata(gcf,'fliplr'), rmappdata(gcf,'fliplr');end
  if isappdata(gcf,'hemisphere'), rmappdata(gcf,'hemisphere');end
end

if nargout > 0, varargout{1} = gca;end

if strcmp(get(gcf,'Tag'),'multiplot')
  varargin = {varargin{:},'annotate'};
else
  adjustToolbar('norotate');
end

set(gca,'Tag','S2Grid','Box','on','DataAspectRatio',[1 1 1],'XTick',[],'YTick',[],...
  'drawmode','fast','layer','top');

% color
if ~check_option(varargin,{'MarkerColor','MarkerFaceColor','CONTOUR','CONTOURF','SMOOTH','DATA'})
  [ls,c] = nextstyle(gca,true,true,~ishold);
  varargin = {'MarkerColor',c,varargin{:}};
end


hold all

%%  GET OPTIONS 

% default plot options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

% S2Resolution
if sum(GridLength(S2G))>20
  varargin = {'scatter_resolution',getResolution(S2G(end)),varargin{:}};
end

% extract data
data = get_option(varargin,'DATA',[]);
if numel(data) == GridLength(S2G)
  
  if isnumeric(data)
    data = reshape(data,GridSize(S2G));
  
    % log plot?
    if check_option(varargin,'logarithmic')
      data = log10(data);
      data(imag(data) ~= 0 | isinf(data)) = nan;
    end
  
    varargin = {'colorrange',[min(data(:)),max(data(:))],varargin{:}};
  end
elseif check_option(varargin,'label')
  
  data = repcell(get_option(varargin,'label'),GridSize(S2G));
  
else
  
  data = [];
  
end


% COLORMAP
if check_option(varargin,'GRAY'),colormap(flipud(colormap('gray'))/1.2);end

%% Prepare Coordinates
% calculate polar coordinates
[theta,rho] = polar(S2G);


%% Which Hemispheres to Plot

if isappdata(gcf,'hemisphere'), 
    
  hemisphere = getappdata(gcf,'hemisphere');
  
elseif check_option(varargin,{'reduced','plain'})
  
  hemisphere = 'reduced';
  
elseif check_option(varargin,{'north','south','reduced'})
  
  hemisphere = extract_option(varargin,{'north','south','reduced'});
   
elseif check_option(S2G,{'north','south','reduced'})
  
  hemisphere = extract_option(S2G(1).options,{'north','south','reduced'});

elseif max(theta(:)) > pi/2+0.001 
  
  hemisphere = {'north','south'};
  
else
  
  hemisphere = 'north';

end

setappdata(gcf,'hemisphere',hemisphere);
  
bounds = [0,0,0,0];


%% Northern Hemisphere

if any(strcmpi(hemisphere,'north')) || any(strcmpi(hemisphere,'reduced'))
  if strcmp(hemisphere,'reduced')
    ind = true(size(theta));    
  else
    ind = theta <= pi/2+0.001;
  end
  bounds = plotHemiSphere(submatrix(theta,ind),submatrix(rho,ind),...
    submatrix(data,ind),0,varargin{:});
end

%% Southern Hemisphere

if any(strcmpi(hemisphere,'south'))
  ind = theta >= pi/2-0.001;
  bounds = plotHemiSphere(pi-submatrix(theta,ind),submatrix(rho,ind),...
    submatrix(data,ind),bounds(3),varargin{:});
end


%% Finish

% Bounding Box
if ~check_option(varargin,{'annotate'})
  if check_option(varargin,'PLAIN')
    xlim([bounds(1),bounds(1)+bounds(3)]);
    ylim([bounds(2),bounds(2)+bounds(4)]);
  else
    xlim([bounds(1)-0.005,bounds(1)+bounds(3)+0.01]);
    ylim([bounds(2)-0.005,bounds(2)+bounds(4)+0.01]);
  end
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
if ~check_option(varargin,'annotate')
  
  if check_option(varargin,'PLAIN') 
    
    plotPlainGrid(theta,rho,varargin{:});    
    
  else
    if (isempty(rho) || isnull(mod(rho(1)-rho(end),2*pi)) || ...
        ~(check_option(varargin,{'CONTOUR','SMOOTH'})))      
      circle(bounds(1)+offset+bounds(3)/2,bounds(2)+bounds(4)/2,bounds(3)/2,'edgecolor','k');
    else
      torte(X+offset,Y);
    end
    
    polarGrid(offset,varargin{:});
  end
end

bounds(3) = bounds(3) + offset;

%% Plot Tort
function torte(X,Y)

line(X(:,1),Y(:,1),'color','k')%,'LineWidth',2)
line(X(:,end),Y(:,end),'color','k')%,'LineWidth',2)
line(X(end,:),Y(end,:),'color','k')%,'LineWidth',2)
line(X(1,:),Y(1,:),'color','k')%,'LineWidth',2)
