function [isIncl,hostId] = isInclusion(grains)
% checks whether a grain is an inclusion within another grain
%
% Syntax
%
%   [isIncl,hostId] = isInclusion(grains)
%
% Input
%
%  grains - @grain2d
%
% Output
%  isIncl - logical
%  hostId - id of the host grain
%


isIncl = false(max(grains.id),1);
hostId = nan(size(isIncl));

poly = grains.poly;
gB = grains.boundary;


for k = find(grains.hasHole).'
  
  % inner vertices
  V = poly{k}(end-grains.inclusionId(k):end);
  V = V(V ~= V(1)); 
  
  incl = unique(gB.grainId(all(ismember(gB.F, V),2),:));
  incl(incl == grains.id(k)) = [];
  
  isIncl(incl) = true;
  hostId(incl) = grains.id(k);
  
end

% translate from id to index
isIncl = isIncl(grains.id);
hostId = hostId(grains.id);
