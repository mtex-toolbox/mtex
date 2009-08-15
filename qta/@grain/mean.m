function [grains qm] = mean(grains,ebsd)
% returns the mean
%
%% Input
%  grains - @grain
%  ebsd   - @EBSD
%
%% Output
%  qm     - quaternion of mean%
%  grains - grains with stored mean   
%
%% See also
% EBSD/mean 
%

[qm grains] = grainfun(@(e) mean(e), grains, ebsd,'property','mean');
