function asp = aspectratio(grains)
% calculates the aspectratio of grain-polygon
%
%% Input
%  grains - @grain
%
%% Output
%  asp   - aspect-ratio
%
%% See also
% grain/deltaAspect 


[h v] = principalcomponents(grains);

asp = v(:,1)./v(:,2);