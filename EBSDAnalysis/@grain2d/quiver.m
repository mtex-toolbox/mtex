function h = quiver(grains,dir,varargin)
% plot directions at grain centers
%
% Syntax
%   quiver(grains,dir,'linecolor','r')
%
%   mtexdata fo
%   grains = calcGrains(ebsd('indexed'))
%   quiver(grains,grains.meanRotation.axis,'color','r')
%
% Input
%  grains - @grain2d
%  dir    - @vector3d
%
% Options
%  antipodal   - plot directions or axes
%  maxHeadSize - size of the arrow
%

xy = grains.centroid;

if ~check_option(varargin,'noScaling')
  
  dir = 0.2*grains.diameter .* normalize(dir) * ...
    get_option(varargin,'autoScaleFactor',1);
  varargin = ['linewidth',2,'autoScale','off',varargin];
else
  varargin = ['linewidth',2,'autoScaleFactor',0.25,varargin];
end

% get color
c = get_option(varargin,'color');

if check_option(varargin,'antipodal') || dir.antipodal

  varargin = [{'MaxHeadSize',0},varargin];
  
  % double color;
  if isnumeric(c) && length(c) == length(dir), c = [c;c]; end

  xy = [xy;xy];
  dir = [dir(:);-dir(:)];

else
  
  %varargin = [{'MaxHeadSize',5},varargin];
    
end
 
% if different color are given - seperate them
[c,~,id] = unique(c,'rows');

if length(id) ==length(dir)

  varargin = delete_option(varargin,'color',1);

  for i = 2:size(c,1)
    hold on
    h(i) = optiondraw(quiver(xy(id == i,1),xy(id == i,2),...
      dir.x(id == i),dir.y(id == i)),varargin{:},'color',c(i,:));
  end
  
else
  h = optiondraw(quiver(xy(:,1),xy(:,2),dir.x,dir.y),varargin{:});
end

if nargout == 0, clear h; end

end
