function fixMTEXplot(varargin)
% remove boundary from the figure
%
%
%
set(gcf,'WindowStyle','normal')
set(gcf,'DockControls','off')

set(gcf,'units','pixel');
% set(gcf,'position',[10 10 400 400])

fig_pos = get(gcf,'position');
set(gca,'units','pixel');
d = get_option(varargin,'border',get_mtex_option('border',20));
a = pbaspect; a = a(1:2)./max(a(1:2));
b = (fig_pos(3:4) -30 - 2*d);
c = b./a;
a = a * min(c);
if all(a > 0)
  set(gca,'position',[30+d 30+d fig_pos(3:4)-40-d]);
% set(gca,'position',[30+d 30+d a]);
% set(gcf,'position',[fig_pos(1:2) 30+a+2*d]);
end
set(gcf,'units','normalized');
set(gca,'units','normalized');

axis equal

if check_option(varargin,{'x','y'})
  X = get_option(varargin,'x');
  Y = get_option(varargin,'y');
  axis ([min(X) max(X) min(Y) max(Y)]);
else
  axis tight
end
grid on
% 
setappdata(gcf,'extend',[xlim ylim])

% try to extend zoom to hole figure % axis fill
h = zoom;
set(h,'ActionPreCallback',{@(e,v) setappdata(gcf,'previousZoom',[xlim ylim])});
set(h,'ActionPostCallback',@resizeCanvas);


function resizeCanvas(obj,eventdata)

set(gcf,'units','pixel');
set(gca,'units','pixel');

ax = get(gca,'position');               
%ax_r = diff(ax([1 3]))/ diff(ax([2 4])); 
ax_r = ax(4)/ ax(3);
ay_r = ax(3)/ ax(4);                    % axis ratio of gca
%
ex = getappdata(gcf,'extend');          % extend of current data
ex_r = diff(ex(3:4))/diff(ex(1:2));
ey_r = diff(ex(1:2))/diff(ex(3:4));
%
cx = [xlim ylim];                       % current axis
dx = diff(cx(1:2));
dy = diff(cx(3:4));
cy_r = dx/dy;
cx_r = dy/dx;

if ay_r < 0.5, return, end %causes somehow more problems
if ax_r*ey_r < 0.5, return, end %causes somehow moreproblems

if ay_r < ey_r               % resize ylim
  dy = dy.*(cy_r - ay_r)/ey_r;

  y = cx(3:4)+ [-dy dy]; %limit to extend
  if y(1) < ex(3), y(1) = ex(3); end
  if y(2) > ex(4), y(2) = ex(4); end
  
  ylim(y)
else                         % resize xlim  
  dx = dx.*(cx_r - ax_r)/ex_r;
%   
  x = cx(1:2) + [-dx dx]; %limit to extend
  if x(1) < ex(1), x(1) = ex(1); ylim(ex(3:4)); end
  if x(2) > ex(2), x(2) = ex(2); ylim(ex(3:4)); end
  
  xlim(x);   
end
