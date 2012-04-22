function fixMTEXplot(varargin)
% remove boundary from the figure
%
%
%
%  set(gcf,'renderer','zbuffer')


warning('off','MATLAB:hg:patch:RGBColorDataNotSupported')

ax = gca;
fig = get(ax,'parent');

if ~strcmpi(get(fig,'type'),'figure')
  varargin = set_default_option(varargin,'noresize');
end

old_fig_units = get(fig,'units');
old_ax_units = get(ax,'units');
set(fig,'units','pixels');
set(ax ,'units','pixels');

set(ax,'TickDir','out',...
  'XMinorTick','on',...
  'YMinorTick','on',...
  'Layer','top')

% axis(ax,'equal');
%
% if check_option(varargin,{'x','y'})
%
%   X = get_option(varargin,'x');
%   Y = get_option(varargin,'y');
%   lim = [min(X) max(X) min(Y) max(Y)];
%
%   if isappdata(fig,'extend')
%     ex = getappdata(fig,'extend');
%     xmi = min(lim,ex);
%     xma = max(lim,ex);
%     lim = [xmi(1) xma(2) xmi(3) xma(4)];
%   end
%
%   setappdata(fig,'extend',lim);
%   axis (ax,lim);
%
% else
if ~isappdata(fig,'extend')

  lim = [get(ax,'xlim') get(ax,'ylim')];
  setappdata(fig,'extend',lim);

else

  lim = getappdata(fig,'extend');

end
grid on

fig_pos = get(fig,'position');


d = get_option(varargin,'border',getpref('mtex','border'));

a(1) = diff(lim(1:2));
a(2) = diff(lim(3:4));
a = a(1:2)./max(a(1:2));
b = (fig_pos(3:4) -42 - 2*d);
c = b./a;
a = a * min(c);

lx = 0; ly = 0;
if strcmp(get(ax,'Visible'),'on'), ly = 35; lx = 55; end

if ~check_option(varargin,'noresize')
  set(fig,'position',[fig_pos(1:2) 50+a(1)+2*d 42+a(2)+2*d]);
end

if all(fig_pos(3:4)-d > 0)
  set(ax,'position',[lx+2+d ly+2+d fig_pos(3)-2-lx-2*d fig_pos(4)-ly-2-2*d]);
end

% try to extend zoom to hole figure
% axis fill
try
  h = zoom(fig);

  if isempty(get(h,'ActionPostCallback'))
    set(h,'ActionPostCallback',@(e,v) resizeCanvas(e,v,fig,ax));
  end
catch
end

resizeCanvas([],[],fig,ax);

set(fig,'units',old_fig_units);
set(ax,'units',old_ax_units);

warning('on','MATLAB:hg:patch:RGBColorDataNotSupported')
if isempty(get(gcf,'ResizeFcn'))
  set(gcf,'ResizeFcn',{@fixMTEXplot,'noresize',varargin{:}});
  fixMTEXplot(ax,'noresize');
end


% function for zooming - may be xlim and ylim can be changed for a better
% view
function resizeCanvas(e,v,fig,ax) %#ok<INUSD>

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

set(fig,'units',old_fig_units);
set(ax,'units',old_ax_units);