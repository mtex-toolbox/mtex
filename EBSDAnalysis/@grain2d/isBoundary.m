function out = isBoundary(grains,ext)
% check whether a grain is a boundary grain
%
% Syntax
%
%   % decide by missing outside data points
%   out = isBoundary(grains)
%
%   % deside by extent of the ebsd map
%   out = isBoundary(grains,ebsd.extent)
%
% Input
%
%  grains - @grain2d
%
% Output
%  out - logical
%

if nargin > 1
  
  dx = min(sqrt(sum(diff(grains.allV).^2,2)));
    
  % find boundary vertices
  isBndV = any(grains.allV < ext([1 3]) + dx/2,2) |  any(grains.allV > ext([2 4]) - dx/2,2);
  
  % take all grains with a boundary vertexs
  out = cellfun(@(x) any(isBndV(x)), grains.poly);
  
else
  
  gbId = grains.boundary.grainId;

  gbId = gbId(any(gbId == 0,2),:);

  gbId = unique(gbId(:,2));

  out = ismember(grains.id,gbId);
  
end