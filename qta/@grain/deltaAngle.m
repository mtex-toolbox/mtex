function delta = deltaAngle(grains)
% returns the angle between major axis of hull-polygon und grain-polygon
%
%% Input
%  grains - @grain
%
%% Output
%  delta  - angle in radians
%

cmp1 = principalcomponents(grains);
cmp2 = hullprincipalcomponents(grains);

b = angle((cmp1).*conj(cmp2));

delta = b(:,1);
delta = reshape(delta,1,[]);
