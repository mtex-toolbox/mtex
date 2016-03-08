function h = quiver(gB,dir,varargin)
% plot directions at grain boundaries
%
% Syntax
%   quiver(gB,gB.direction,'linecolor','r')
%
% Example
%   mtexdata fo
%   grains = calcGrains(ebsd('indexed'))
%   quiver(grains(1437).boundary,grains(1437).boundary.calcMeanDirection,'color','r')


varargin = [{'MaxHeadSize',0,'linewidth',2,'autoScaleFactor',0.15},varargin];

xy = [gB.midPoint;gB.midPoint];
dir = [dir(:);-dir(:)];

h = optiondraw(quiver(xy(:,1),xy(:,2),dir.x,dir.y),varargin{:});

if nargout == 0, clear h; end

end
