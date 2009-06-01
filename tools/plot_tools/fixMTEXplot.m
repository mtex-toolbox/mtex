function fixMTEXplot(varargin)
% remove boundary from the figure
%
%
%
set(gcf,'WindowStyle','normal')
set(gcf,'DockControls','off')

set(gcf,'units','pixel');
fig_pos = get(gcf,'position');
set(gca,'units','pixel');
d = get_option(varargin,'border',get_mtex_option('border',20));
a = pbaspect; a = a(1:2)./max(a(1:2));
b = (fig_pos(3:4) -30 - 2*d);
c = b./a;
a = a * min(c);
if all(a > 0)
  set(gca,'position',[30+d 30+d a]);
  set(gcf,'position',[fig_pos(1:2) 30+a+2*d]);
end
set(gcf,'units','normalized');
set(gca,'units','normalized');

