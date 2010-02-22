function grains = neighbours(grains, grains2)
% return the neighbours of given grains in an grainset with self references
% or the number of neighbours per grain in a given set

if nargin == 1   
  id = [grains.id];
  nei = vertcat(grains.neighbour);
  nnei = cellfun('length',{grains.neighbour});

  grains = cellfun(@sum,mat2cell(ismember(nei,id),nnei,1));
  
else
  grains = grains(ismember(...
    vertcat(grains(:).id),vertcat(grains2(:).neighbour)));
end