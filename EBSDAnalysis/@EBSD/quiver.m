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

c = ebsd.pos;

if check_option(varargin,'antipodal') || dir.antipodal

  varargin = [{'MaxHeadSize',0,'linewidth',2,'autoScaleFactor',0.5},varargin];
  c = [c;c];
  dir = [dir(:);-dir(:)];
  
else
  
  varargin = [{'MaxHeadSize',5,'linewidth',2,'autoScaleFactor',0.5},varargin];
    
end
 
h = optiondraw(quiver3(c.x,c.y,c.z,dir.x,dir.y,dir.z),varargin{:});

if nargout == 0, clear h; end

end
