function [ebsd,distList] = spatialProfile(ebsd,lineXY,varargin)
% select EBSD data along line segments
% 
% Syntax
%
%   ebsdLine = spatialProfile(ebsd,[xStart,xEnd],[yStart yEnd])
% 
%   [ebsdLine,dist] = spatialProfile(ebsd,x,y)
%
%   xy = ginput(2)
%   [ebsdLine,dist] = spatialProfile(ebsd,xy)
%
% Input
%  ebsd  - @EBSD
%  xStart, xEnd, yStart, yEnd - double
%  x, y  - coordinates of the line segments
%  xy - list of spatial coordinates |[x(:) y(:)]| 
%
% Output
%  ebsdLine - @EBSD restrcited to the line of interest
%  dist - double distance along the line to the initial point
%
% Example
%
%   % import data
%   mtexdata twins
%
%   % plot data
%   plot(ebsd('indexed'),ebsd('indexed').orientations)
%
%   % select line coordinates
%   x = [15.5 27]; y = [20.5 11];
%
%   % draw line with some transluency
%   line(x,y,'color',[0.5 0.5 0.5 0.5],'linewidth',10)
%
%   % restrict ebsd data to this line
%   [ebsdLine,dist] = spatialProfile(ebsd,x,y);
%
%   % extract orientations
%   ori = ebsdLine.orientations;
%
%   figure
%   % plot misorienation angle along the profile
%   plot(dist,angle(ori,ori(1))./degree,'linewidth',2)
%   xlabel('line'), ylabel('misorientation angle')

% maybe y is given as a second argument
if nargin >= 3 && isnumeric(varargin{1})
  lineXY = [lineXY(:),varargin{1}(:)];
end

[i,j] = xy2ind(ebsd,lineXY);

[i,j] = bresenham(i(1),j(1),i(2),j(2));

isOutside = i <= 0 | i > size(ebsd,1) | j <= 0 | j > size(ebsd,2);
i(isOutside) = []; j(isOutside) = [];

idList = sub2ind(size(ebsd),i,j);

distList = 1;
distList(1) = [];
ebsd = ebsd.subSet(idList);


