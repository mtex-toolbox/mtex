function grains = neighbours(grains, grains2)
% identifiy neighbouring
%
%% Syntax
%
%  neighbours(grains) 
%%
% returns the number of neighboured grains
%
%  neighbours(grains1,grains2)
%%
% returns the neighbours of grain-set grains2 which are availible in
% grain-set grains1
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
%  grains(grains(hasholes(grains)) == grains(hassubfraction(grains)))
%
%% See also
% grain/misorientation grain/plotboundary

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