function [ebsd,distList] = spatialProfile(ebsd,lineX,varargin)
% select EBSD data along line segments
% 
% Syntax
%   % returns a sorted list of ebsd data along lineX
%   [ebsd_lineX,dist] = spatialProfile(ebsd,lineX)
%
% Input
%  ebsd  - @EBSD
%  lineX - list of spatial coordinates |[x(:) y(:)]| of if 3d |[x(:) y(:) z(:)]|, 
%    where $x_i,x_{i+1}$ defines a line segment
%
% Output
%  ebsd - @EBSD restrcited to the line of interest
%  dist - double distance along the line to the initial point
%
% Example
%
%   mtexdata twins
%   plot(ebsd('indexed'),ebsd('indexed').orientations)
%   lineX = ginput(2)
%   ebsd_lineX = spatialProfile(ebsd,lineX)
%   clf; plot(ebsd_lineX.x,angle(ebsd_lineX(1).orientations,ebsd_lineX.orientations)./degree)
%   xlabel('x'), ylabel('misorientation angle')

if all(isfield(ebsd.prop,{'x','y','z'}))
  x_D = [ebsd.prop.x,ebsd.prop.y,ebsd.prop.z];
else
  x_D = [ebsd.prop.x,ebsd.prop.y];
end

radius = unitCellDiameter(ebsd.unitCell)/2;

% work with homogenous coordinates
x_D(:,end+1) = 1;

distList = 0;
idList = [];

dim = size(lineX,2);
for k=1:size(lineX,1)-1
  % setup transformation matrix
  % line from A to B
  dX = lineX(k+1,:)-lineX(k,:);
  
  [s,~,D] = svd(dX./norm(dX));
  
  % if s is negative, shift into B, else shift into A
  D(dim+1,dim+1) = 1;
  D(:,end) =  [-lineX(k+double(s<0),:) 1] * D';
  
  % homogen linear tranformation
  x_DX = x_D*D';

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

