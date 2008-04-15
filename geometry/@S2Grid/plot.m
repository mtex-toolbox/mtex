function  varargout = plot(S2G,varargin)
% plot spherical data
%
% *S2G/plot* allows to plot data on the sphere in vary differnt kinds
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
%
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

global mtex_plot_options;
varargin = {varargin{:},mtex_plot_options{:}};

if check_option(varargin,'3d')
  plot3d(S2G,varargin{:});return
end

if length(S2G) > 1  
  multiplot(@(i) S2G(i),@(i) ones(1,GridLength(S2G(i))),length(S2G),varargin{:});
  return
end

%% -------------------- GET OPTIONS ----------------------------------------

% data
data = get_option(varargin,'DATA',ones(1,sum(GridLength(S2G))));
if numel(data) == GridLength(S2G)
  data = reshape(data,GridSize(S2G)); 
else
  data = ones(1,sum(GridLength(S2G)));
end

% log plot? 
if check_option(varargin,'logarithmic')
  data = log(data)./log(10);
  data(imag(data) ~= 0) = -inf;
end

% diamter of dots
diameter = get_option(varargin,'DIAMETER',min(0.2,max(0.02,0.75*getResolution(S2G(end)))));


% COLORMAP
if check_option(varargin,'GRAY'),colormap(flipud(colormap('gray'))/1.2);end

%% prepare axis

% Annotation?
if strcmp(get(gca,'tag'),'colorbaraxis') 
  if ishold
  
    ox = gca;
    ax = findobj(gcf,'tag','S2Grid');
  
    for i = 1:length(ax)
      set(gcf,'currentAxes',ax(i));
      hold all;
      plot(S2G,'annotate',varargin{:});
      hold off;
    end
  
    set(gcf,'currentAxes',ox);
    return
    
  else
  
    clf reset;
    
  end  
end
  
if ~ishold
  cla reset
  if nargout > 0, varargout{1} = gca;end
  set(gca,'Tag','S2Grid','Box','on','DataAspectRatio',[1 1 1],'XTick',[],'YTick',[],...
    'drawmode','fast','layer','top');
  hold on
end

%% Prepare Data
% calculate polar coordinates
[theta,rho] = polar(S2G);
if check_option(varargin,'rotate')
  rho = rho + get_option(varargin,'rotate',-pi/2,'double');
end

if check_option(varargin,'flipud')
  rho = 2*pi-rho;
end

% restrict 
if numel(theta) > 100000
  warning('to many data!'); %#ok<WNTAG>
  disp('restrict to first 100000');
  theta = theta(1:100000);
  rho = rho(1:100000);
  data = data(1:100000);
end

%% decide wether one or two plots

if  ((~check_option(S2G.options,'HEMISPHERE') && ~check_option(varargin,{'PLAIN','reduced'}) && ...
    ~isempty(theta)  && max(theta(:))>pi/2+0.001  && min(theta(:)) < pi/2-0.001)) ...
    || ( max(xlim)>3)
  % && check_option(varargin,'annotate')
  % two plots
  
  % nothern hemisphere
  ind = theta <= pi/2+0.001;
  [x1,y1,x2,y2] = ...
    plot_hemi_sphere(submatrix(theta,ind),submatrix(rho,ind),...
    submatrix(data,ind),diameter,0,varargin{:}); %#ok<NASGU>
  
  % southern hemisphere
  ind = theta >= pi/2-0.001;
  [x2,y2,x2,y2] = ...
    plot_hemi_sphere(pi-submatrix(theta,ind),submatrix(rho,ind),...
    submatrix(data,ind),diameter,x2-x1,varargin{:});
  
else % single plot

  [x1,y1,x2,y2] = plot_hemi_sphere(theta,rho,data,diameter,0,varargin{:});

end

% bounding box
if ~check_option(varargin,'annotate'), xlim([x1,x2]);ylim([y1,y2]);end

%rectangle('position',[x1 y1 (x2-x1) (y2-y1)])
hold off

%% --------------------- PROJECTION ---------------------------------------
function [x1,y1,x2,y2] = plot_hemi_sphere(theta,rho,data,diameter,offset,varargin)

if check_option(varargin,'PLAIN')
  X = rho;Y = theta; 
  x1 = min(X(:)); x2 = max(X(:));
  y1 = min(Y(:)); y2 = max(Y(:));
  
  if ~check_option(varargin,'TIGHT')
    set(gca,'XTickmode','auto','YTickmode','auto')
    xlabel('rho');ylabel('theta')
  end
elseif check_option(varargin,'EDIST')
  [X,Y] = stereographicProj(theta,rho);
  X = X +offset;
  x1 = -2; x2 = 2;
  y1 = -2; y2 = 2;
else  
  [X,Y] = SchmidtProj(theta,rho);
  X = X + offset;
  x1 = -1.4142 +offset; x2 = 1.4142 +offset;
  y1 = -1.4142; y2 = 1.4142;
end

%% -------------------- bounds ----------------------------------------
if check_option(varargin,{'contour','contour','smooth'}) && ~check_option(varargin,'PLAIN') && ...
    ~isempty(rho) && ~isnull(mod(rho(1)-rho(end),2*pi))
  x1 = min(X(:)); x2 = max(X(:));
  y1 = min(Y(:)); y2 = max(Y(:));
end

%% -------------------- contour lines --------------------------------------
contours = get_option(varargin,{'contourf','contour'},{},'double');
if ~isempty(contours), contours = {contours};end

% ------------------- OUTPUT ---------------------------------------------
% contour plot
if check_option(varargin,'CONTOUR') 
  
  contour(X,Y,data,contours{:},'k');
  set(gcf,'Renderer','painters');
  
% contour plot
elseif check_option(varargin,'CONTOURF') 
  
  [CM,h] = contourf(X,Y,data,contours{:});
  set(h,'LineStyle','none');
  contour(X,Y,data,contours{:},'k');
  set(gcf,'Renderer','painters');

% sphere
elseif check_option(varargin,'3d')
  R = 20;		% contour radius
  mR = 0.995*R;		% mesh radius
  [x,y,z,c] = sphere3d(data,-pi,pi,-pi/2,pi/2,mR,pi/4,'off','spline',0);
  mesh(x,y,z)
  colormap ([.8 .8 .8]);
  hold on
  sphere3d(data,min(rho(:))-pi,max(rho(:))-pi,min(theta(:))-pi/2,max(theta(:))-pi/2,...
    R,0.25,'contour','spline',0);
%  s = colorbar;
%  delete(s)
  hold off
      
% interpolated 
elseif check_option(varargin,'SMOOTH') 
  
  % interpolated
  if check_option(varargin,'interp')

    pcolor(X,Y,data);

    if numel(data) >= 500, shading interp;end
    %set(gcf,'Renderer','OpenGL');
    set(gcf,'Renderer','zBuffer');
  else  
    %  if numel(data) >= 1000
    if isappr(min(data(:)),max(data(:)))
      ind = convhull(X,Y);
      fill(X(ind),Y(ind),min(data(:)));
    else
      [CM,h] = contourf(X,Y,data,200);
      set(h,'LineStyle','none');
    end
  end
% singular points 
elseif isa(data,'cell') || check_option(varargin,'dots')% || numel(X)<20
  
  set(gcf,'Renderer','painters');
  
  if check_option(varargin,'annotate')
    x = get(gca,'xlim');
    y = get(gca,'ylim');
    ind = find(X >= x(1)-0.0001 & X <= x(2)+0.0001 & Y >= y(1)-0.0001 & Y <= y(2)+0.0001);
  else
    ind = 1:numel(X);
  end  
  
  
  cax = newplot(gca);
  [ls,c,m] = nextstyle(gca);
  for i = ind
    text(X(i),Y(i),'$\bullet$',...
      'FontSize',round(get_option(varargin,'FontSize',12)/2*3),...
      'color',get_option(varargin,'color',c),...
      'HorizontalAlignment','Center','VerticalAlignment','middle','interpreter','latex');
    if isa(data,'cell')
      smarttext(X(i),Y(i),data(i),[x1 x2 y1 y2],...
        'FontSize',get_option(varargin,'FontSize',12),...
        'Interpreter','latex');
    end
  end
elseif check_option(varargin,'scatter')
    
  set(gcf,'Renderer','painters');
  h = scatter(X(:),Y(:),(diameter*100)^2,data(:),'filled');
  set(h,'tag','scatterplot','UserData',diameter/3.2);
  
else
  
  set(gcf,'Renderer','painters');
  cminmax = get_option(varargin,'colorrange',...
    [min(data(data>-inf)),max(data(data<inf))]);
  if length(cminmax)>1 && cminmax(2)>cminmax(1)
    data = 1+round((data-cminmax(1)) / (cminmax(2)-cminmax(1)) * 63);
  else
    data = ones(size(data));
  end
  cmap = colormap;

  for i=1:numel(X)
    if data(i)>= 1 && data(i) <= 64
      rectangle('Position',[X(i)-diameter/2,Y(i)-diameter/2,diameter,diameter],...
        'Curvature',[1,1],'FaceColor',cmap(data(i),:),'EdgeColor',cmap(data(i),:));
    else
      rectangle('Position',[X(i)-diameter/2,Y(i)-diameter/2,diameter,diameter],...
        'Curvature',[1,1],'FaceColor','white','EdgeColor','black');
    end
  end
end


%-------------------- bounding box ----------------------------------------
if ~check_option(varargin,{'PLAIN','annotate'})
  if (isempty(rho) || isnull(mod(rho(1)-rho(end),2*pi)) || ...
      ~(check_option(varargin,{'CONTOUR','SMOOTH'})))
    circle((x1+x2)/2,(y1+y2)/2,(x2-x1)/2);
  else
    torte(X,Y);
  end
end



function circle(x,y,r)

rectangle('Position',[x-r,y-r,2*r,2*r],...
  'Curvature',[1,1])%,'LineWidth',2);

function torte(X,Y)

line(X(:,1),Y(:,1),'color','k')%,'LineWidth',2)
line(X(:,end),Y(:,end),'color','k')%,'LineWidth',2)
line(X(end,:),Y(end,:),'color','k')%,'LineWidth',2)
line(X(1,:),Y(1,:),'color','k')%,'LineWidth',2)
