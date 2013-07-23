function plotGrid(ax, projection, extend, varargin)
% plot Polar Grid

if ~isappdata(ax,'grid') % there is no grid yet

  % generate grid
  if strcmpi(projection.type,'plain')
    grid = plotPlainGrid(ax,projection,extend,varargin{:});
    set(ax,'box','on');
  else
    grid = plotPolarGrid(ax,projection,extend,varargin{:});

    % hide grid
    optiondraw(grid.boundary,'color','k');
    
    if check_option(varargin,'grid') && ~strcmp(get_option(varargin,'grid'),'off')
      vis = 'on';
    else
      vis = 'off';
    end
    optiondraw(grid.grid,'visible',vis,'linestyle',':','color',[.4 .4 .4]);
    optiondraw(grid.ticks,'fontsize',8,'FontName','times','visible','off');

    set(ax,'box','on','XTick',[],'YTick',[]);
  end

  setappdata(ax,'grid',grid);

else % bring grid into front again

  grid = getappdata(ax,'grid');
  if ~isempty(grid)
    childs = allchild(ax);
    s = structfun(@(x) ismember(childs,x),grid,'uniformoutput',false);

    isgrid = s.boundary | s.grid | s.ticks;
    istext = strcmp(get(childs,'type'),'text');

    set(ax,'Children',[childs(istext); childs(isgrid); childs(~isgrid & ~istext)]);
  end

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

end

%%
function g = plotPlainGrid(ax,projection,extend,varargin)

  dgrid = get_option(varargin,'grid_res',30*degree);

  set(ax,'XTick',round((extend.minRho:dgrid:extend.maxRho)/degree))
  set(ax,'YTick',round((extend.minTheta:dgrid:extend.maxTheta)/degree))

  interpreter = getMTEXpref('textInterpreter');

  xlabel(ax,get_option(varargin,'xlabel','rho'),'interpreter',interpreter,'FontSize',12,'VerticalAlignment','bottom');
  ylabel(ax,get_option(varargin,'ylabel','theta'),'interpreter',interpreter,'FontSize',12,'VerticalAlignment','top');

  g = [];

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
if isnumeric(extend.maxTheta)
  [hm,tm] = arrayfun(@(t) merid(ax,projection,extend,x,y,t),rho);
  h = [h hm];
  t = [t tm];
end


grid.boundary = hb;
grid.grid     = h;
grid.ticks    = t;

end

function [h,t] = merid(ax,projection,extend,x,y,rho,varargin)

maxTheta = min(extend.maxTheta,pi/2);

[X,Y] = project(sph2vec(maxTheta,rho),projection,extend,varargin{:});

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

end

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

end
