function plotGrid(ax, projection, extend, varargin)
% plot Polar Grid

if ~isappdata(ax,'grid') % there is not grid yet
  
  % generate grid
  grid = plotPolarGrid(ax,projection,extend,varargin{:});
  
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
function grid = plotPolarGrid(ax,projection,extend,varargin)
% generate grid for axes ax

% stepsize
dgrid = get_option(varargin,'grid_res',30*degree);
dgrid = pi/round((pi)/dgrid);

% discretize rho
if extend.maxRho > extend.minRho
  rho = extend.minRho:dgrid:(extend.maxRho-dgrid);
else
  rho = mod(extend.minRho:dgrid:(extend.maxRho+2*pi-dgrid),2*pi);
end
if extend.maxRho ~= 2*pi, rho(1) = [];end

% initalize handles for grid
hb = []; h = []; t = [];

% plain grid
if strcmpi(projection.type,'plain')
  
  [x,y] = project(zvector,projection,extend);
  
%   h = [h arrayfun(@(t) circ(ax,projection,x,y,t),pi)];

  [hm,tm] = arrayfun(@(t) merid(ax,projection,extend,x,y,t),rho);   
  h = [h hm];
  t = [t tm];
  
  
else % polar grid
  
  % northern hemisphere
  if extend.minTheta < pi/2-1e-3
    center = zvector;
    maxTheta = extend.maxTheta;
    minTheta = 0;
    theta = dgrid:dgrid:(pi/2-dgrid);
  else % southern hemisphere
    center = -zvector;
    maxTheta = extend.minTheta;
    minTheta = pi;
    theta = pi/2+(dgrid:dgrid:(pi/2-dgrid));
  end
  
  % center point
  [x,y] = project(center,projection,extend);
    
  % draw outer circ
  hb = [hb circ(ax,projection,extend,minTheta,maxTheta,'boundary')];
  
  % draw small circles
  h = [h arrayfun(@(t) circ(ax,projection,extend,minTheta,t),theta)];
    
  % draw meridians
  [hm,tm] = arrayfun(@(t) merid(ax,projection,extend,x,y,t),rho);
  h = [h hm];
  t = [t tm];
      
end

grid.boundary = hb;
grid.grid     = h;
grid.ticks    = t;


function [h,t] = merid(ax,projection,extend,x,y,rho,varargin)

[X,Y] = project(sph2vec(pi/2,rho),projection,extend,varargin{:});

% vertical/horizontal alignment
va = {'middle','bottom','middle','top'};
ha = {'left','center','right','center'};
r = mod(round(atan2(Y(1,:),X(1,:))/pi*2),4)+1;

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


function h = circ(ax,projection,extend,theta0,theta,varargin)

n   = abs(extend.maxRho-extend.minRho)/(.5*degree);
rho = linspace(extend.minRho,extend.maxRho,n);

if isa(theta,'function_handle')
  theta = theta(rho);
else
  theta = theta*ones(size(rho));
end

if check_option(varargin,'boundary') ...
    && ~isappr(extend.maxRho-extend.minRho,2*pi) ...
    && ~strcmpi(projection.type,'plain')
  rho = [0,rho,0];
  theta = [theta0,theta,theta0];
end

[dx,dy] = project(sph2vec(theta,rho),projection,extend,varargin{:});

h = line(dx,dy,'parent',ax,'handlevisibility','off');
