function fixMTEXplot(varargin)
% remove boundary from the figure and handle zoom

%% general settings

warning('off','MATLAB:hg:patch:RGBColorDataNotSupported')
set(gca,'TickDir','out',...
  'XMinorTick','on',...
  'YMinorTick','on',...
  'Layer','top');

grid off

%% compute optimal figure size

% store extend
extend = getappdata(gcf,'extend');
if isempty(extend), extend = [get(gca,'xlim'),get(gca,'ylim')];end
setappdata(gcf,'extend',extend);

% compute extend ratio dx/dy
dxylim = [diff(extend(1:2)),diff(extend(3:4))];
dxylim = dxylim./max(dxylim);


% store units
old_fig_units = get(gcf,'units');
old_ax_units = get(gca,'units');
set(gcf,'units','pixels');
set(gca ,'units','pixels');

% get figrure position
fig_pos = get(gcf,'position');
d = get_option(varargin,'outerPlotSpacing',getMTEXpref('outerPlotSpacing'));
figxy = fig_pos(3:4) -42 - 2*d;

% correct for cameraposition
if find(get(gca,'CameraUpVector'))==1
  dxylim = fliplr(dxylim);
end

ratio = figxy./dxylim;
newfigxy = dxylim * min(ratio);

lx = 0; ly = 0;
if strcmp(get(gca,'Visible'),'on'), ly = 35; lx = 55; end

if ~check_option(varargin,'noresize')
  fig_pos = [fig_pos(1:2) 50+newfigxy(1)+2*d 42+newfigxy(2)+2*d];
  set(gcf,'position',fig_pos);
end

if all(fig_pos(3:4)-d > 0)
  set(gca,'position',[lx+2+d ly+2+d fig_pos(3)-2-lx-2*d fig_pos(4)-ly-2-2*d]);
end

% restore units
set(gcf,'units',old_fig_units);
set(gca,'units',old_ax_units);

%% try to extend zoom to hole figure axis fill
try
  h = zoom(gcf);

  if isempty(get(h,'ActionPostCallback'))
    set(h,'ActionPostCallback',@(e,v) resizeCanvas(e,v,gcf,gca));
  end
catch %#ok<CTCH>
end

resizeCanvas([],[],gcf,gca);

%%
warning('on','MATLAB:hg:patch:RGBColorDataNotSupported')
if isempty(get(gcf,'ResizeFcn'))
  set(gcf,'ResizeFcn',{@fixMTEXplot,'noresize',varargin{:}});
  fixMTEXplot(gca,'noresize');
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
if find(get(gca,'CameraUpVector'))==1
  [ax_r,ay_r] = deal(ay_r,ax_r);
end


%% resize ylim
if ay_r < ey_r

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

  %% resize xlim
else
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
