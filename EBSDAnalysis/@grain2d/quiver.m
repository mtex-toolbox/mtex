function h = quiver(grains,dir,varargin)
% plot directions at grain boundaries
%
% Syntax
%   quiver(gB,gB.direction,'linecolor','r')
%
% Example
%   mtexdata fo
%   grains = calcGrains(ebsd('indexed'))
%   quiver(grains(1437).boundary,grains(1437).boundary.calcMeanDirection,'color','r')

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
