function out = isBoundary(grains,ebsd)
% check whether a grain is a boundary grain
%
% Syntax
%
%   % decide by missing outside data points
%   out = isBoundary(grains)
%
%   % decide by extent of the ebsd map
%   out = isBoundary(grains,ebsd)
%
% Input
%  grains - @grain2d
%  ebsd   - @EBSD
%  poly   - 
%
% Output
%  out - logical
%

if nargin > 1
  
  dxy = ebsd.dPos;
  ext = ebsd.extent;
 
  %rot = rotation.map(grains.N, zvector);
  xy = grains.allV.xyz; xy = xy(:,1:2);
  
  % find boundary vertices
  isBndV = any(xy < ext([1 3]) + dxy/2,2) |  any(xy > ext([2 4]) - dxy/2,2);
  
  % take all grains with a boundary vertex
  out = cellfun(@(x) any(isBndV(x)), grains.poly);
  
else
  
  gbId = grains.boundary.grainId;

  gbId = gbId(any(gbId == 0,2),:);

  gbId = unique(gbId(:,2));

  out = ismember(grains.id,gbId);
  
end