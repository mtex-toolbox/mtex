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

% work with homogenous coordinates
xy1 = [ebsd.prop.x,ebsd.prop.y];
xy1(:,end+1) = 1;

radius = unitCellDiameter(ebsd.unitCell)/2;

distList = 0;
idList = [];

dim = size(lineXY,2);
for k=1:size(lineXY,1)-1
  % setup transformation matrix
  % line from A to B
  
  if lineXY(k+1,1)>=lineXY(k,1) %x2>x1 && y2<y1 || x2>x1 && y2>y1
    dX = [lineXY(k+1,1)-lineXY(k,1), - (lineXY(k+1,2)-lineXY(k,2))];
  else %x2<x1 && y2>y1 || x2<x1 && y2<y1
    dX = lineXY(k+1,:)-lineXY(k,:);
  end
    
  [s,~,D] = svd(dX./norm(dX));
  
  % if s is negative, shift into B, else shift into A
  D(dim+1,dim+1) = 1;
  D(:,end) =  [-lineXY(k+double(s<0),:) 1] * D';
  
  % homogen linear tranformation
  x_DX = xy1*D';

  % detect which ebsd data are close to the current segment
  id =  find(sqrt(sum(x_DX(:,2:end-1).^2,2)) <= radius &  ... distance to line
    0 <= x_DX(:,1) & x_DX(:,1) <= norm(dX)); % length of line segment
  
  % distance to the starting point of the line segment
  dist = x_DX(id,1);
  
  % if we start with B, reverse the distance
  if double(s<0), dist = max(dist)-dist; end
  
  [dist, ndx] = sort(dist);
  idList = [idList; id(ndx)]; %#ok<AGROW>
  distList = [distList; distList(end)+dist]; %#ok<AGROW>
  
end

distList(1) = [];
ebsd = ebsd.subSet(idList);


% ----------------------------------------------------------------
function d = unitCellDiameter(unitCell)


diffVg = bsxfun(@minus,...
  reshape(unitCell,[size(unitCell,1),1,size(unitCell,2)]),...
  reshape(unitCell,[1,size(unitCell)]));
diffVg = sum(diffVg.^2,3);
d  = sqrt(max(diffVg(:)));

