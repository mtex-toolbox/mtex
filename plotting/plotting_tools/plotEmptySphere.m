function plotEmptySphere(varargin)
% plots white sphere

if check_option(varargin,'parent')
  ax = get_option(varargin,'parent');
else
  ax = gca;
end

[x, y, z] = sphere;
x = 0.99*x;
y = 0.99*y;
z = 0.99*z;
surface(x,y,z,'FaceColor', 'w','EdgeColor','none','parent',ax,'handlevisibility','off')
hold(ax,'on')

dth = 15*degree;
th = -pi/2+dth:dth:pi/2-dth;
rh = linspace(0,2*pi,100);

[th,rh] = meshgrid(th,rh);

[x,y,z] = sph2cart(rh, th, 1);

line(x,y,z,'color',[1 1 1] * 0.8,'parent',ax,'handlevisibility','off');

drh = 15*degree;
rh = 0:drh:2*pi-drh;
th = linspace(-pi/2,pi/2,50);

[th,rh] = meshgrid(th,rh);

[x,y,z] = sph2cart(rh, th, 1);

line(x.',y.',z.','color',[1 1 1] * 0.8,'parent',ax,'handlevisibility','off')

axis(ax,'equal','vis3d','off');
set(ax,'XDir','rev','YDir','rev',...
  'XLim',[-1.02,1.02],'YLim',[-1.02,1.02],'ZLim',[-1.02,1.02]);
view(3);

if nargout == 0, clear h;end

end
