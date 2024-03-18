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
% Options
%  label - text to be displayed at the end of the arrow
%  labeled - 
%  faceColor - 
%  arrowWidth - width of the tail (default 0.02)
%  antipodal - 
%
% Example
%
%  arrow3d(zvector,'FaceColor','red','label','z')
%  hold on
%  arrow3d(xvector,'FaceColor','blue','label','x')
%  arrow3d(yvector,'FaceColor','green','label','y')
%  arrow3d(0.5*vector3d(1,1,1,'antipodal'))
%  hold off
%
% See also
% vector3d/scatter3 vector3d/plot3 vector3d/text3

% where to plot
if check_option(varargin,'parent')
  ax = get_option(varargin,'parent');
else
  ax = gca;
end

% length of the arrows
if all(norm(vec)==1), vec = 1.2.*vec;end
lengthTail = 0.9;

radiTail = get_option(varargin,'arrowWidth',0.02);

if vec.antipodal || check_option(varargin,'antipodal')
  vec = [vec,-vec];
  radiHead = radiTail;
else
  radiHead = 2.5 * radiTail;
end

% do not change caxis
cax = clim(ax);

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
clim(ax,cax);

% set axis to 3d
axis(ax,'equal');

% increase box limits if required
%bounds = [-1 1] * max(max(norm(vec)));
%set(ax,'XLim',bounds,'YLim',bounds,'ZLim',bounds);
%set(ax,'XDir','rev','YDir','rev','XLim',bounds,'YLim',bounds,'ZLim',bounds);

if check_option(varargin,{'label','labeled'})
  text3(vec,get_option(varargin,'label'),'parent',ax,'scaling',1.1,varargin{:});
end


if nargout == 0, clear h;end
