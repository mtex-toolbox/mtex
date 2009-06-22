function [qm grains] = mean(grains,ebsd)
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

qm = grainfun(@(e) mean(e), grains, ebsd,'uniformoutput',true);

if nargout > 1
  grains = set(grains,'mean',qm); 
end
