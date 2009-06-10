function grains = neighbours(grains, grains2)
% return the neighbours of given grains in an grainset with self references
%

grains = grains(ismember(...
  vertcat(grains(:).id),vertcat(grains2(:).neighbour)));