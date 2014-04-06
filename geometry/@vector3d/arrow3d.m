function h = arrow3d(v,varargin)
% plot three dimensional arrows
%
% Syntax
%   arrow3d(v)
%
% Input
%
% See also
% savefigure vector3d/scatter3d vector3d/plot3d

% -------------------- GET OPTIONS ----------------------------------------

% where to plot
if check_option(varargin,'parent')
  ax = get_option(varargin,'parent');
else
  ax = gca;
end

% do not change caxis
cax = caxis(ax);

% length of the arrows
v = 1.2.*v.normalize;
lengthTail = 0.9;
radiHead = 0.05;
radiTail = 0.02;

% the center line of the arrow
c = [vector3d(0,0,0),vector3d(0,0,0),v.*lengthTail,v.*lengthTail,v];

% the radii
r = [0,radiTail,radiTail,radiHead,0];

% a normal vector
n = rotate(v.orth,rotation('axis',v,'angle',linspace(0,2*pi,50)));

% the hull of the arrow
hull = repmat(c,length(n),1) + n * r;

% plot as surface plot
h = optiondraw(surf(hull.x,hull.y,hull.z,'facecolor','k','edgecolor','none'),varargin{:});

% set caxis back
caxis(ax,cax);


if check_option(varargin,'label')
  v = v.*1;
  text(v.x,v.y,v.z,get_option(varargin,'label'),'FontSize',15,'verticalAlignment','cap')
end

% set axis to 3d
axis(ax,'equal','vis3d','off');

% st box limits
set(ax,'XDir','rev','YDir','rev',...
'XLim',[-1.2,1.2],'YLim',[-1.2,1.2],'ZLim',[-1.2,1.2]);

if nargout == 0, clear h;end
