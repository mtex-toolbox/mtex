function asp = deltaAspect(p)
% compares the apsect-ratios of hull- to grain-polygon
%
%% Input
%  p - @grain / @polygon
%
%% Output
%  asp   - delta aspect ratio
%

[cmp1 v1] = principalcomponents(p);
[cmp2 v2] = hullprincipalcomponents(p);

dv = (v1 - v2).^2;
sv = (v1 + v2).^2;

asp = sum(dv,2)./sum(sv,2);
asp = reshape(asp,1,[]);