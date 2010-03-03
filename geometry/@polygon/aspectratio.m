function asp = aspectratio(p,varargin)
% calculates the aspectratio of grain-polygon
%
%% Input
%  p - @grain / @polygon
%
%% Output
%  asp   - aspect-ratio
%
%% Flag
%  HULL  - aspectratio of the convex hull
%
%% See also
% polygon/deltaAspect 


[h v] = principalcomponents(p,varargin{:});
asp = reshape(v(:,1)./v(:,2),size(p));