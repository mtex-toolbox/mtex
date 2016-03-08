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
%  antipodal -
%  maxHeadSize
%

xy = grains.centroid;

if check_option(varargin,'antipodal') || dir.antipodal

  varargin = [{'MaxHeadSize',0,'linewidth',2,'autoScaleFactor',0.25},varargin];
  xy = [xy;xy];
  dir = [dir(:);-dir(:)];
  
else
  
  varargin = [{'MaxHeadSize',5,'linewidth',2,'autoScaleFactor',0.25},varargin];
    
end
 
h = optiondraw(quiver(xy(:,1),xy(:,2),dir.x,dir.y),varargin{:});

if nargout == 0, clear h; end

end
