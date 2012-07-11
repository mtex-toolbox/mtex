function grains = neighbours(grains, grains2)
% identifiy neighbouring
%
%% Syntax
% neighbours(grains) - returns the number of neighboured grains
% neighbours(grains1,grains2) - returns the neighbours of grain--set
%    grains2 which are availible in
%    grain-set grains1
%
%
%% Input
%  grains  - @grain
%  grains2 - @grain
%
%% Output
%  grains   - logical indexing / @grain
%
%% Example
%  %intersect two grainsets
%  grains(grains(hasHoles(grains)) == grains(hasSubBoundary(grains)))
%
%% See also
% grain/misorientation grain/plotBoundary

% return the neighbours of given grains in an grainset with self references
% or the number of neighbours per grain in a given set

if nargin == 1
  
  id = get(grains,'id');
  nei = get(grains,'neighbour');
  nids = vertcat(nei{:});
  nnei = cellfun('prodofsize',nei);
  grains = cellfun(@sum,mat2cell(ismember(nids,id),nnei,1));
  
else
  
  ids = get(grains(:),'id');
  nei = get(grains2(:),'neighbour');
  nids = vertcat(grains2(:).neighbour);
  
  grains = grains(ismember(ids,nids));
  
end



