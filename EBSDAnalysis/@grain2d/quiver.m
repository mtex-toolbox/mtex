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
  
if check_option(varargin,'antipodal') || dir.antipodal

  varargin = [{'MaxHeadSize',0},varargin];
  xy = [xy;xy];
  dir = [dir(:);-dir(:)];
  
else
  
  %varargin = [{'MaxHeadSize',5},varargin];
    
end
 
h = optiondraw(quiver(xy(:,1),xy(:,2),dir.x,dir.y),varargin{:});

if nargout == 0, clear h; end

end
