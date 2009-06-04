function asp = deltaAspect(grains)
% compares the apsect-ratios of hull- to grain-polygon
%
%% Input
%  grains - @grain
%
%% Output
%  asp   - delta aspect ratio
%

[cmp1 v1] = principalcomponents(grains);
[cmp2 v2] = hullprincipalcomponents(grains);

dv = (v1 - v2).^2;
sv = (v1 + v2).^2;

asp = sum(dv,2)./sum(sv,2);
asp = reshape(asp,1,[]);