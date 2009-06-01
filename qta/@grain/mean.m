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
  phase = grainfun(@(e) get(e,'phase'), grains, ebsd,'uniformoutput',true);
  CS = grainfun(@(e) get(e,'CS'), grains, ebsd,'uniformoutput',true);
  SS = grainfun(@(e) get(e,'SS'), grains, ebsd,'uniformoutput',true);
  
  grains = setproperty(grains,'mean',qm);
  grains = setproperty(grains,'phase',phase);
  grains = setproperty(grains,'CS',CS);
  grains = setproperty(grains,'SS',SS);
end
