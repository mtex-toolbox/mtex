function h = arrow3d(vec,varargin)
% plot three dimensional arrows
%
% Syntax
%   arrow3d(v)
%   arrow3d(v,'arrowWidth',0.05)
%
% Input
%  v - @vector3d
%
% See also
% savefigure vector3d/scatter3 vector3d/plot3 vector3d/text3

% where to plot
if check_option(varargin,'parent')
  ax = get_option(varargin,'parent');
else
  ax = gca;
end

if vec.antipodal || check_option(varargin,'antipodal')
  vec = [vec,-vec];
end

% do not change caxis
cax = caxis(ax);

% length of the arrows
vec = 1.2.*vec;
lengthTail = 0.9;

radiTail = get_option(varargin,'arrowWidth',0.02);
radiHead = 2.5 * radiTail;

for i = 1:length(vec)
  
  v = vec.subSet(i);
  
  % the center line of the arrow
  c = [vector3d(0,0,0),vector3d(0,0,0),v.*lengthTail,v.*lengthTail,v];

  % the radii
  r = [0,radiTail,radiTail,radiHead,0] .* norm(v);

  % a normal vector
  n = rotate(v.orth,rotation.byAxisAngle(v,linspace(0,2*pi,50)));

  % the hull of the arrow
  hull = repmat(c,length(n),1) + reshape(n,[],1) * r;

  % plot as surface plot
  h(i) = optiondraw(surf(hull.x,hull.y,hull.z,'parent',ax,...
    'facecolor','k','edgecolor','none'),varargin{:});
  
end

% set caxis back
caxis(ax,cax);

% set axis to 3d
%axis(ax,'equal','vis3d','off');

% st box limits
bounds = [-1 1] * max(max(norm(vec)));
set(ax,'XLim',bounds,'YLim',bounds,'ZLim',bounds);
%set(ax,'XDir','rev','YDir','rev','XLim',bounds,'YLim',bounds,'ZLim',bounds);

if check_option(varargin,{'label','labeled'})
  text3(vec,get_option(varargin,'label'),'parent',ax,'scaling',1.1,varargin{:});
end


if nargout == 0, clear h;end
