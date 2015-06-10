function oR = rotate(oR,r,l)
% rotate of a orientation region
%

if nargin == 2, l = idquaternion; end

oR.N =  quaternion(l) * oR.N * quaternion(r);
oR.V = quaternion(l) * oR.V * quaternion(r);