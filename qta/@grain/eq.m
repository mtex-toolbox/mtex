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
%  %intersect two grain sets
%  grains(grains(hasHoles(grains)) == grains(hasSubBoundary(grains)))
%

out = ismember([grain1.id],[grain2.id]);
