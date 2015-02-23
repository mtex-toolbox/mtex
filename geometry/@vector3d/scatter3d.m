function h = scatter3d(v,varargin)
% plot spherical data
%
% Syntax
%   scatter3d(v,data)
%
% Input
%
% See also
% savefigure

% where to plot
if check_option(varargin,'parent')
  ax = get_option(varargin,'parent');
else
  ax = gca;
end

% plot a inner sphere that is not transluent
[th, phi] = meshgrid(linspace(0, 2*pi, 100), linspace(-pi, pi, 100));
[x,y,z] = sph2cart(th, phi,0.99);
surface(x,y,z,'FaceColor', 'w','EdgeColor','none','parent',ax)
hold(ax,'on')

% normalize vectors
v = reshape(v,[],1);
v = 1.02 .* v ./ norm(v);

if nargin > 1 && isnumeric(varargin{1})
  data = varargin{1};
  data = reshape(data,length(v),[]);
  varargin{1} = [];
else
  data = {};
end

if v.antipodal  
  v = [v;-v];
  data = [data;data];
end

% plot
data = ensurecell(data);
h = scatter3(v.x(:),v.y(:),v.z(:),30,data{:},'filled','parent',ax);

plotGrid(ax)

axis(ax,'equal','vis3d','off');

set(ax,'XDir','rev','YDir','rev',...
'XLim',[-1.02,1.02],'YLim',[-1.02,1.02],'ZLim',[-1.02,1.02]);

hold(ax,'off')

if nargout == 0, clear h;end

end

function plotGrid(ax)

  dth = 15*degree;
  th = -pi/2+dth:dth:pi/2-dth;
  rh = linspace(0,2*pi,100);

  [th,rh] = meshgrid(th,rh);

  [x,y,z] = sph2cart(rh, th, 1);

  line(x,y,z,'color',[1 1 1] * 0.8,'parent',ax)

  drh = 15*degree;
  rh = 0:drh:2*pi-drh;
  th = linspace(-pi/2,pi/2,50);
  
  [th,rh] = meshgrid(th,rh);
  
  [x,y,z] = sph2cart(rh, th, 1);

  line(x.',y.',z.','color',[1 1 1] * 0.8,'parent',ax)

  
end