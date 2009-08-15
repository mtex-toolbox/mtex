function grains = calcODF(grains,ebsd,varargin)
% helper function to calculate an individual ODF for each grain
%
%% Input
%  grains - @grain
%  ebsd   - @EBSD
%
%% Output
%  grains  - @grain with odf as property
%
%% See also
% ebsd/calcODF

[o grains] = grainfun(@(e) calcODF(e,varargin{:},'silent'), grains, ebsd,'property','ODF');


