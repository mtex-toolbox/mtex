function fixMTEXplot(varargin)
% remove boundary from the figure and handle zoom
%

if nargin > 0 && any(ishghandle(varargin{1},'axes'))
  ax = varargin{1};
  varargin{1} = [];
else
  ax = gca;
end
fig = get(ax,'parent');

% general settings
set(ax,'TickDir','out',...
  'XMinorTick','on',...
  'YMinorTick','on',...
  'Layer','top',...
  'box','on');
grid(ax,'off');

% make layout
ResizeFcn(fig,[],varargin{:});

% set resize function
if isempty(get(gcf,'ResizeFcn'))
  set(gcf,'ResizeFcn',@(src,evt) ResizeFcn(src,evt,'noresize',varargin{:}));
end

% set zoom function
try
  h = zoom(fig);

  if isempty(get(h,'ActionPostCallback'))
    set(h,'ActionPostCallback',@(e,v) resizeCanvas(e,v,fig,ax));
  end
catch %#ok<CTCH>
end

end


%% compute optimal figure size
function ResizeFcn(fig,evt,varargin)

warning('off','MATLAB:hg:patch:RGBColorDataNotSupported')
ax = get(fig,'CurrentAxes');

% store extend
extend = getappdata(fig,'extend');
if isempty(extend), extend = [get(ax,'xlim'),get(ax,'ylim')];end
setappdata(fig,'extend',extend);

% compute extend ratio dx/dy
dxylim = [diff(extend(1:2)),diff(extend(3:4))];
dxylim = dxylim./max(dxylim);


% store units
old_fig_units = get(fig,'units');
old_ax_units = get(ax,'units');
set(fig,'units','pixels');
set(ax ,'units','pixels');

% get figrure position
fig_pos = get(fig,'position');
d = get_option(varargin,'outerPlotSpacing',getMTEXpref('outerPlotSpacing'));
figxy = fig_pos(3:4) -42 - 2*d;

% correct for cameraposition
if find(get(ax,'CameraUpVector'))==1
  dxylim = fliplr(dxylim);
end

ratio = figxy./dxylim;
newfigxy = dxylim * min(ratio);

lx = 0; ly = 0;
if strcmp(get(ax,'Visible'),'on'), ly = 35; lx = 55; end

if ~check_option(varargin,'noresize')
  fig_pos = [fig_pos(1:2) 50+newfigxy(1)+2*d 42+newfigxy(2)+2*d];
  set(fig,'position',fig_pos);
end

if all(fig_pos(3:4)-d > 0)
  set(ax,'position',[lx+2+d ly+2+d fig_pos(3)-2-lx-2*d fig_pos(4)-ly-2-2*d]);
end

% restore units
set(fig,'units',old_fig_units);
set(ax,'units',old_ax_units);

% extend canvas as position of axis
resizeCanvas([],[],fig,ax);
warning('on','MATLAB:hg:patch:RGBColorDataNotSupported')

end

%% function for zooming
function resizeCanvas(e,v,fig,ax) %#ok<*INUSL>

% restore old camera setting
setCamera(ax);

% do everything for pixels
old_fig_units = get(fig,'units');
old_ax_units = get(ax,'units');
set(fig,'units','pixels');
set(ax ,'units','pixels');

% get the available space
pos = get(ax,'position');

% x/y ratios of available space
ax_r = pos(4)/ pos(3);
ay_r = pos(3)/ pos(4);

% maximum xlim and ylim of the data
ex = getappdata(fig,'extend');

% x/y rations of of maximum xlim  / ylim
ey_r = diff(ex(1:2))/diff(ex(3:4));

% current xlim  / ylim
cx = [xlim(ax) ylim(ax)];
dx = diff(cx(1:2));
dy = diff(cx(3:4));

% correct for xAxisDirection
if find(get(ax,'CameraUpVector'))==1
  [ax_r,ay_r] = deal(ay_r,ax_r);
end

if ay_r < ey_r % resize ylim

  % new ylim = xlim * are_ratio
  dy = dx * ax_r - dy;

  % extend xlim to both sides
  y = cx(3:4) + [-1 1] * dy./2;

  % may be a shift is necessary
  if y(1) < ex(3)
    y(2) = min(ex(4),y(2)+ex(3)-y(1));
    y(1) = ex(3);
  elseif y(2) > ex(4)
    y(1) = max(ex(3),y(1)+ex(4)-y(2));
    y(2) = ex(4);
  end

  % set the new limit
  ylim(ax,y)


else % resize xlim
  
  % new xlim = ylim * are_ratio
  dx = dy * ay_r - dx;

  % extend xlim to both sides
  x = cx(1:2) + [-1 1] * dx./2;

  % may be a shift is necessary
  if x(1) < ex(1)
    x(2) = min(ex(2),x(2)+ex(1)-x(1));
    x(1) = ex(1);
  elseif x(2) > ex(2)
    x(1) = max(ex(1),x(1)+ex(2)-x(2));
    x(2) = ex(2);
  end

  % set the new limit
  xlim(ax,x);
end

% restore units
set(fig,'units',old_fig_units);
set(ax,'units',old_ax_units);
end
