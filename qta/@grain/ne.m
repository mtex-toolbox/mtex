function out = ne(grain1,grain2)
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
%  grains(grains(hasHoles(grains)) ~= grains(hasSubBoundary(grains)))
%

out = ~eq(grain1,grain2);