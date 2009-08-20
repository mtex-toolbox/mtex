function [grains qm] = mean(grains,ebsd)
% returns the mean
%
%% Input
%  grains - @grain
%  ebsd   - @EBSD
%
%% Output
%  grains - grains with stored mean as orientation  
%  qm     - quaternion of mean
%
%% See also
% EBSD/mean 
%

[qm grains] = grainfun(@(e) mean(e), grains, ebsd,'property','orientation','uniformoutput',true);
