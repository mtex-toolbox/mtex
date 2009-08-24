function [cmp v]= principalcomponents(grains,varargin)
% returns the principalcomponents of grain polygon, without holes
%
%% Input
%  grains - @grain
%
%% Output
%  cmp   - angle of components as complex
%  v     - length of axis
%
%% Options
%  HULL  - components of convex hull
%
%% See also
% grain/hullprincipalcomponents grain/plotellipse
%

nc = length(grains);
cmp = zeros(nc,2);
v = zeros(nc,2);

hull = check_option(varargin,'hull');

if hull
  c = hullcentroid(grains);
else
  c = centroid(grains);
end
%without respect to holes

for k=1:nc
 xy = grains(k).polygon.xy;
 
 if hull
   xy = xy(convhull(xy(:,1),xy(:,2)),:);
 else
   xy(end,:) = [];
 end
 
 xy = xy - repmat(c(k,:),length(xy),1);  %centering
 covar = xy'*xy./(length(xy)-1);                         %cov                
                                  
 [u f] = eigs(covar);
 v(k,:) = diag(f)';
 cmp(k,:) = [complex(u(1,1),u(1,2)) complex(u(2,1),u(2,2))].*v(k,:);
end

