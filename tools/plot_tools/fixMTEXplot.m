function fixMTEXplot(varargin)
% remove boundary from the figure
%
%
%

ax = gca;
axis(ax,'equal');

if check_option(varargin,{'x','y'})
  X = get_option(varargin,'x');
  Y = get_option(varargin,'y');
  axis (ax,[min(X) max(X) min(Y) max(Y)]);
else
  axis(ax,'tight')
end
grid on
set(ax,'TickDir','out','XMinorTick','on','YMinorTick','on','Layer','top')

set(gcf,'units','pixel');
fig_pos = get(gcf,'position');
set(ax,'units','pixel');
d = get_option(varargin,'border',get_mtex_option('border',5));
a = pbaspect; a = a(1:2)./max(a(1:2));
b = (fig_pos(3:4) -42 - 2*d);
c = b./a;
a = a * min(c);

lx = 0; ly = 0;
if strcmp(get(ax,'Visible'),'on'), ly = 35; lx = 55; end

if ~check_option(varargin,'noresize')
  set(gcf,'position',[fig_pos(1:2) 50+a(1)+2*d 42+a(2)+2*d]);
end

pos = get(gcf,'position');
if all(pos(3:4)-50-d > 0)
  set(ax,'position',[lx+2+d ly+2+d pos(3)-2-lx-2*d pos(4)-ly-2-2*d]);
end
set(gcf,'units','normalized');
set(ax,'units','normalized');



setappdata(gcf,'extend',[xlim ylim])
% try to extend zoom to hole figure 
% axis fill
try
  h = zoom;
  set(h,'ActionPreCallback',{@(e,v) setappdata(gcf,'previousZoom',[xlim ylim])});
  set(h,'ActionPostCallback',@resizeCanvas);
catch %#ok<CTCH>
end

% function for zooming - may be xlim and ylim can be changed for a better
% view
function resizeCanvas(obj,eventdata) %#ok<INUSD>

% do everything for pixels
set(gcf,'units','pixel');
set(gca,'units','pixel');

% get the available space
ax = get(gca,'position');               

% x/y ratios of available space
ax_r = ax(4)/ ax(3);
ay_r = ax(3)/ ax(4);                    

% maximum xlim and ylim of the data
ex = getappdata(gcf,'extend');

% x/y rations of of maximum xlim  / ylim
ey_r = diff(ex(1:2))/diff(ex(3:4));

% current xlim  / ylim
cx = [xlim ylim];
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
  ylim(y)
  
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
  xlim(x);
end
