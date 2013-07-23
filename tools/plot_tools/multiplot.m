function a = multiplot(nplots,varargin)
% plot multiple graphs
%
%% Syntax
%   multiplot(nplots,@(i) coordinates(i),@(i) data(i))
%   multiplot(nplots,,data,'COLORCODING','equal','FONTSIZE',fontsize)
%   multiplot(nplots,'COLORCODING',[cmin cmax])
%   multiplot(nplots,'ANOTATION',string)
%
%% Input
%  x      - grid (@S1Grid, @S2Grid, @SO3Grid)
%  y      - vector of plot data
%  nplots - number of plots
%
%% Options
%  [cmin cmax] - minimum and maximum value for color coding
%  string      - some anotation to be added to the plot
%  outerPlotSpacing -
%  innerPlotSpacing -
%
%% Flags
%  silent - no output
%
%% See also
% S2Grid/plot savefigure

%% if axes are alrady given plot into it and skip the rest
if ~isempty(nplots) && all(ishandle(nplots)) && strcmp(get(nplots(1),'type'),'axes')

  varargin(1) = [];
  efun = find(cellfun('isclass',varargin,'function_handle'));
  for kfun = 1:numel(efun)
    varargin{efun(kfun)} = varargin{efun(kfun)}(1);
  end

  plot(nplots,varargin{:});
  return;
end

%% prepare plot

washold = getHoldState;

% get existing axes
a = findobj(gcf,'type','axes');
ma = getappdata(gcf,'multiplotAxes');


% get axes from former multiplot
if ~strcmp(washold,'off') && ~isempty(ma) && all(numel(ma) == nplots) && ...
    all(ishandle(ma))
  a = ma;
  nplots = numel(a);

% make normal axes multiplot axes
elseif ishold && ~isempty(a) && all(nplots == numel(a)) && ...
    all(ishandle(a))
  nplots = numel(a);

else % make new axes
  rmallappdata
  for k=1:numel(a), cla(a(k));end
  for k=numel(a)+1:nplots, a(k) = axes('visible','off'); end
end

% distribute hold state over all axes
for k=1:nplots, hold(a(k),washold); end

% set figure options
if check_option(varargin,'position')
  position = get_option(varargin,'position');
  varargin = delete_option(varargin,'position');
  set(gcf,'position',position);
elseif strcmp(washold,'off')
  % determine optimal size
  screenExtend = get(0,'MonitorPositions');
  screenExtend = screenExtend(1,:); % consider only the first monitor
  [bx,by,l] = bestfit(screenExtend(3),screenExtend(4),1,nplots,30,30);
  l = min(l,300);
  bx = bx*l;
  by = by*l;
  position = [(screenExtend(3)-bx)/2,(screenExtend(4)-by)/2,bx,by];
  set(gcf,'position',position);
end



%% extract data
if nargin>=3 && isa(varargin{2},'function_handle')
  data = cell(nplots,1);
  for k = 1:nplots
    data{k} = feval(varargin{2},k);
  end
  varargin(2) = []; %remove argument

  % for equal colorcoding determine min and max of data
  contours = get_option(varargin,{'contourf','contour'},[],'double');
  if isempty(contours) && check_option(varargin,'colorRange',[],'equal')
    minData = nanmin(cellfun(@(x) nanmin(x(:)),data));
    maxData = nanmax(cellfun(@(x) nanmax(x(:)),data));

    % set colorcoding explicitly
    varargin = set_option(varargin,'colorRange',[minData maxData]);
  end
else
  data = [];
end

%% make plots
efun = find(cellfun('isclass',varargin,'function_handle'));
nfun = numel(efun);

for k=1:nplots
  targin = varargin;
  for kfun = 1:nfun
    targin{efun(kfun)} = varargin{efun(kfun)}(k);
  end

  % reinsert data
  if ~isempty(data) && ~isempty(data{k}), targin = {targin{1},data{k},targin{2:end}};end

  plot(a(k),targin{:});
end

%% invisible axes for adding a colorbar
if ~isappdata(gcf,'colorbaraxis')
  d = axes('visible','off','position',[0 0 1 1],...
    'tag','colorbaraxis');

  % bring invisible axis in back
  ch = allchild(gcf);
  ch = [ch(ch ~= d);ch(ch == d)];
  set(gcf,'children',ch,'currentAxes',ch(1));
  set(d,'HandleVisibility','callback');

  setappdata(gcf,'colorbaraxis',d);
end

% set correct colorrange for colorbar axis
if check_option(varargin,{'logarithmic','log'})
  set(d,'ZScale','log');
end

%% post process figure

% ensure same marker size in all scatter plots
if check_option(varargin,'unifyMarkerSize')
  ax = findobj(a,'tag','dynamicMarkerSize');
  if ~isempty(ax)
    markerSize = ensurecell(get(ax,'UserData'));
    set(ax,'UserData',min([markerSize{:}]));
  end
end

set(gcf,'ResizeFcn',@(src,evt) figResize(src,evt,a));

if ~isappdata(gcf,'multiplotAxes')

  setappdata(gcf,'multiplotAxes',a);
  setappdata(gcf,'autofit',get_option(varargin,'autofit','on'));
  setappdata(gcf,'outerPlotSpacing',get_option(varargin,'outerPlotSpacing',getMTEXpref('outerPlotSpacing')));
  setappdata(gcf,'innerPlotSpacing',get_option(varargin,'innerPlotSpacing',getMTEXpref('innerPlotSpacing')));

  figResize(gcf,[],a);

  if ~check_option(varargin,'uncropped')
    set(gcf,'Units','pixels');
    pos = get(gcf,'Position');
    si = get(gcf,'UserData');
    pos([3,4]) = si;
    set(gcf,'Position',pos);
  end
end

set(gcf,'color',[1 1 1],'nextPlot','replace');

% make axes visible
set(a,'Visible','on');


end
%% ================== private functions =========================

%% resize figure and reorder subfigs
function figResize(fig,evt,a) %#ok<INUSL,INUSL>

old_units = get(fig,'Units');
set(fig,'Units','pixels');

if strcmp(getappdata(fig,'autofit'),'on')

  figpos = get(fig,'Position');

  innerPlotSpacing = getappdata(fig,'innerPlotSpacing');
  outerPlotSpacing = getappdata(fig,'outerPlotSpacing');


  figpos(4) = figpos(4)-2*outerPlotSpacing;
  figpos(3) = figpos(3)-2*outerPlotSpacing;
  dxdy = get(a(1),'PlotBoxAspectRatio');
  % correct for xAxisDirection
  if find(get(a(1),'CameraUpVector'))==1
    dxdy(1:2) = fliplr(dxdy(1:2));
  end
  dxdy = dxdy(2)/dxdy(1);
  [nx,ny,l] = bestfit(figpos(3),figpos(4),dxdy,length(a),innerPlotSpacing,innerPlotSpacing);
  set(fig,'UserData',[nx*l+2*outerPlotSpacing+(nx-1)*innerPlotSpacing,...
    ny*l*dxdy+2*outerPlotSpacing+(ny-1)*innerPlotSpacing]);
  setappdata(fig,'length',l);

  l = ceil(l);
  ldxdy = ceil(l*dxdy);
  for i = 1:length(a)
    [px,py] = ind2sub([nx ny],i);
    apos = [1+outerPlotSpacing+(px-1)*(l+innerPlotSpacing),...
      1+outerPlotSpacing+figpos(4)-py*ldxdy-(py-1)*(innerPlotSpacing-1),...
      l,ldxdy];
    set(a(i),'Units','pixels','Position',apos);
  end

  % resize colorbaraxis
  set(getappdata(fig,'colorbaraxis'),'units','pixel','position',[outerPlotSpacing,outerPlotSpacing,figpos(3:4)]);
end

% set position of labels
u = findobj(fig,'Tag','minmax','HorizontalAlignment','Right');
for i = 1:length(u)

 a = get(u(i),'parent');
 set(a,'units','points');
 apos = get(a,'Position');
 set(u(i),'Units','points','Position',[apos(3)-1,3]);
end

set(fig,'Units',old_units);

% call resize dynamic maker sizes
if isappdata(fig,'dynamicMarkerSize')
  RS = getappdata(fig,'dynamicMarkerSize');
  RS(fig);
end

end



%% determine best alignment of subfigures
function [bx,by,l] = bestfit(dx,dy,dxdy,n,marginx,marginy)

% length in x direction
lx = @(nx,ny) min((dx-(nx-1)*marginx)/nx,...
  (dy-(ny-1)*marginy)/dxdy/ny);

by = 1; bx = n;
l = lx(bx,by);

if n == 1, return;end

for ny=2:n
  nx = ceil(n/ny);
  if lx(nx,ny) > l % new best fit
    l = lx(nx,ny);
    bx = nx;
    by = ny;
  end
end
end
