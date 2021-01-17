function h = quiver(ebsd,dir,varargin)
% plot directions at ebsd centers
%
% Syntax
%   quiver(ebsd,dir,'linecolor','r')
%
%   mtexdata small
%   quiver(ebsd,ebsd.rotations.axis)
%
% Input
%  ebsd - @EBSD
%  dir  - @vector3d
%
% Options
%  antipodal - plot directions or axes
%  maxHeadSize - size of the arrow
%

xy = [ebsd.prop.x(:),ebsd.prop.y(:)];

if check_option(varargin,'antipodal') || dir.antipodal

  varargin = [{'MaxHeadSize',0,'linewidth',2,'autoScaleFactor',0.5},varargin];
  xy = [xy;xy];
  dir = [dir(:);-dir(:)];
  
else
  
  varargin = [{'MaxHeadSize',5,'linewidth',2,'autoScaleFactor',0.5},varargin];
    
end
 
h = optiondraw(quiver(xy(:,1),xy(:,2),dir.x,dir.y),varargin{:});

if nargout == 0, clear h; end

end
