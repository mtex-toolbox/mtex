function oR = rotate(oR,r,l)
% rotate of a orientation region
%

if nargin == 2, l = quaternion.id; end

oR.N =  quaternion(l) * oR.N * quaternion(r);
oR.V = orientation(quaternion(l) * quaternion(oR.V) * quaternion(r),oR.CS1,oR.CS2);