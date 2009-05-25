function qm = mean(grains,ebsd)
% returns the mean
%
%% Input
%  grains - @grain
%  ebsd   - @EBSD
%
%% Output
%  qm   - quaternion of mean%
%
%% See also
% EBSD/mean 
%

qm = grainfun(@(e) mean(e), grains, ebsd,'uniformoutput',true);