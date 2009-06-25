function asp = aspectratio(grains,varargin)
% calculates the aspectratio of grain-polygon
%
%% Input
%  grains - @grain
%
%% Output
%  asp   - aspect-ratio
%
%% Flag
%  HULL  - aspectratio of the convex hull
%
%% See also
% grain/deltaAspect 


[h v] = principalcomponents(grains,varargin{:});
asp = reshape(v(:,1)./v(:,2),size(grains));