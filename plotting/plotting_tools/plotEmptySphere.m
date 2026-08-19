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
hG = holdOn(ax); %#ok<NASGU>

surface(x,y,z,'FaceColor', 'w','EdgeColor','none','parent',ax,'handlevisibility','off')

plotSphericalGrid(ax,varargin{:});

axis(ax,'equal','vis3d','off');
set(ax,'XDir','rev','YDir','rev',...
  'XLim',[-1.02,1.02],'YLim',[-1.02,1.02],'ZLim',[-1.02,1.02]);
view(3);

ax.ColorOrderIndex = 1;

if nargout == 0, clear h;end

end
