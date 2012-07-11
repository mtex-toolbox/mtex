function plotGrid( ax, projection ,varargin)
% plot Polar Grid


if ~isappdata(ax,'grid') % there is not grid yet
  
  % generate grid
  grid = plotPolarGrid(ax,projection, varargin{:});
  
  optiondraw(grid.boundary,'color','k');
  optiondraw(grid.grid,'visible','on','linestyle',':','color',[.4 .4 .4]);
  optiondraw(grid.ticks,'fontsize',8,'FontName','times','visible','off');
  
  set(ax,'box','on','XTick',[],'YTick',[]);
  %axis(ax,'equal');
  
  setappdata(ax,'grid',grid);
  
else % do something - to be documented
  
  grid = getappdata(ax,'grid');
  childs = get(ax,'children');
  s = structfun(@(x) ismember(childs,x),grid,'uniformoutput',false);
  
  isgrid = s.boundary | s.grid | s.ticks;
  
  set(ax,'Children',[childs(isgrid); childs(~isgrid)]);
  
end
return


% control legend entry
try
  hAnnotation = get(l,'Annotation');
  hLegendEntry = get([hAnnotation{:}],'LegendInformation');
  set([hLegendEntry{:}],'IconDisplayStyle','off')
catch %#ok<CTCH>
end

%% labels


if any(isnan(X)), return;end
if check_option(varargin,'ticks'), v = 'on';else v = 'off';end


% set back color index
if isappdata(gca,'PlotColorIndex')
  if isempty(colorIndex)
    setappdata(gca,'PlotColorIndex',1);
  else
    setappdata(gca,'PlotColorIndex',colorIndex);
  end
end


%% -------------------------------------------------------------------
function grid = plotPolarGrid(ax,projection,varargin)
% generate grid for axes ax

% stepsize
dgrid = get_option(varargin,'grid_res',30*degree);
dgrid = pi/round((pi)/dgrid);

% discretize theta
theta = dgrid:dgrid:(pi/2-dgrid);

% discretize rho
if projection.maxRho > projection.minRho
  rho = projection.minRho:dgrid:(projection.maxRho-dgrid);
else
  rho = mod(projection.minRho:dgrid:(projection.maxRho+2*pi-dgrid),2*pi);
end
if projection.maxRho ~= 2*pi, rho(1) = [];end

% initalize handles for grid
hb = []; h = []; t = [];

% plain grid
if strcmpi(projection.type,'plain')
  
  [x,y] = project(zvector,projection);
  
%   h = [h arrayfun(@(t) circ(ax,projection,x,y,t),pi)];

  [hm tm] = arrayfun(@(t) merid(ax,projection,x,y,t),rho);   
  h = [h hm];
  t = [t tm];
  
  
else % polar grid
  
  % plot grid in northern hemisphere
  if projection.minTheta < pi/2-1e-3
    
    % center point
    [x,y] = project(zvector,projection);
    
    % draw outer circ
    if isnumeric(projection.maxTheta)
      maxTheta = min(projection.maxTheta,pi/2);
    else
      maxTheta = projection.maxTheta;
    end
    hb = [hb circ(ax,projection,x,y,maxTheta,'boundary')];
    
    % draw small circles
    h = [h arrayfun(@(t) circ(ax,projection,x,y,t),theta)];
    
    % draw meridians
    if isnumeric(projection.maxTheta) && projection.maxTheta > pi/2-1e-6
      [hm tm] = arrayfun(@(t) merid(ax,projection,x,y,t),rho);
      h = [h hm];
      t = [t tm];    
    end
  end
  
  % plot grid in southern hemisphere
  if isnumeric(projection.maxTheta) && projection.maxTheta > pi/2 + 1e-6
    
    % draw outer circ
    [x,y] = project(-zvector,projection);
    hb = [hb circ(ax,projection,x,y,pi/2,'boundary')];
    
    %,'equator2south'
    % draw small circles
    h = [h arrayfun(@(t) circ(ax,projection,x,y,t),theta)];
    
    % draw meridians
    [hm tm] = arrayfun(@(t) merid(ax,projection,x,y,t),rho);
    
    h = [h hm];
    t = [t tm];
  end
end

grid.boundary = hb;
grid.grid     = h;
grid.ticks    = t;


function [h t] = merid(ax,projection,x,y,rho,varargin)

[X,Y] = project(sph2vec(pi/2,rho),projection,varargin{:});

% vertical/horizontal alignment
va = {'middle','bottom','middle','top'};
ha = {'left','center','right','center'};
r = mod(round(atan2(Y(1,:),X(1,:))/pi*2),4)+1;

X = x+X; Y = y+Y;

if strcmpi(projection.type,'plain'),
  x = X;
  options = [{'HorizontalAlignment','center','VerticalAlignment','bottom'},varargin];
else
  options = [{'HorizontalAlignment',ha{r},'VerticalAlignment',va{r}},varargin];
end

% grid
h = line([x X],[y Y],'parent',ax,'handlevisibility','off');

%plot tick markers
% TODO
%   if check_mtex_option('noLaTex')
s = [xnum2str(rho/degree) mtexdegchar];
t = optiondraw(text(X,Y,s,'parent',ax,'interpreter','tex','handlevisibility','off'),options{:});
%   else
%     s = ['$' xnum2str(rho(k)/degree) '^\circ$'];
%     t(k) = optiondraw(text(X,Y,s,'interpreter','latex'),options{:});
%   end


function h = circ(ax,projection,x,y,theta,varargin)

% if isappr(projection.maxRho-projection.minRho,2*pi)
%   r = project(sph2vec(theta,0),projection);
%   h = optiondraw(builtin('rectangle','Position',[x-r,y-r,2*r,2*r],'Curvature',[1,1]),varargin{:});
% else

n   = abs(projection.maxRho-projection.minRho)/(.5*degree);
rho = linspace(projection.minRho,projection.maxRho,n);

if isa(theta,'function_handle')
  theta = theta(rho);
else
  theta = theta*ones(size(rho));
end

if check_option(varargin,'boundary') ...
    && ~isappr(projection.maxRho-projection.minRho,2*pi) ...
    && ~strcmpi(projection.type,'plain')
  rho = [0,rho,0];
  theta = [0,theta,0];
end

[dx,dy] = project(sph2vec(theta,rho),projection,varargin{:});

h = line(x+dx,y+dy,'parent',ax,'handlevisibility','off');
