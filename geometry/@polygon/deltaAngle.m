function delta = deltaAngle(p)
% returns the angle between major axis of hull-polygon und grain-polygon
%
%% Input
%  p - @grain / @polygon
%
%% Output
%  delta  - angle in radians
%

cmp1 = principalcomponents(p);
cmp2 = hullprincipalcomponents(p);

b = angle((cmp1).*conj(cmp2));

delta = b(:,1);
delta = reshape(delta,1,[]);
