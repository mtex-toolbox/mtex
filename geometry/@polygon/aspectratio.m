function asp = aspectratio(p,varargin)
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


[h v] = principalcomponents(p,varargin{:});
asp = reshape(v(:,1)./v(:,2),size(p));