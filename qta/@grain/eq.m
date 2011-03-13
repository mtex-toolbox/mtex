function out = eq(grain1,grain2)
% comparation of grains using grain-id
%
%% Input
%  grains - @grain
%
%% Output
%  out   - logical indexing
%
%% Example
%  %intersect two grainsets
%  grains(grains(hasholes(grains)) == grains(hassubfraction(grains)))
%

if isa(grain1,'grain') && isa(grain2,'grain') 
  set1 = unique(get(grain1,'checksum'));
  set2 = unique(get(grain2,'checksum'));
  if length(set1) == 1 && length(set2) == 1 && set1 == set2
    out = ismember(get(grain1,'id'),get(grain2,'id'));   
  else
    error('different grains')
  end
end