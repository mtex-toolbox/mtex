function gbnd = calcGBND(gB3,varargin)
% grain boundary normal distribution 
%
% Syntax
%
%   % grain boundary normal distribution in specimen coordinates
%   gbnd = calcGBND(gB3)
%
%   % grain boundary normal distribution in crystal coordinates
%   gbnd = calcGBND(gB3,grains)
%
%   % grain boundary normal distribution in crystal coordinates
%   gbnd = calcGBND(gB3,ebsd)
%
% Input
%  gB3 - @grain3Boundary
%  grains - single phase @grain3d
%  grains - single phase @EBSD3
%
% Output
%  gbnd - @S2Fun
%
% Options
%  halfwidth - halfwidth used for density estimation
%

if nargin > 1 && isa(varargin{1},'grain3d')
  
  grains = varargin{1};
 
  N = [gB3.N,gB3.N];
  weights = gB3.area; weights = repmat(weights,1,2);

  % restrict to correct phase
  isPhase = gB3.phaseId == grains.indexedPhasesId;
  weights = weights(isPhase);

  % index to the grain
  ind = varargin{1}.id2ind(gB3.grainId(isPhase));

  % compute the normal directions in crystal coordinates
  N = inv(grains(ind).meanOrientation) .* N(isPhase);

  gbnd = calcDensity(N,'weights',weights,varargin{:},'antipodal');

else

  gbnd = calcDensity(gB3.N,'weights',gB3.area,varargin{:},'antipodal');

end

end