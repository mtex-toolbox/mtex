function q = cube2quat(XYZ)
%
% transformation of cubochoric representation of rotations into
% representation as unit quaternions the transformation is done by first
% going from cubochoric to homochoric representation (cube2ball) and then
% further to the representation as unit quaternions (InvLambert)
% 
% Input
%  XYZ - cubochoric coordinates (X,Y,Z) of N points of the cube
%
% Output
%  q - @quaternion

xyz = cube2ball(XYZ);
q = quaternion(InvLambert(xyz).');

end