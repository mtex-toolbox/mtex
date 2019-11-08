function rot = byMatrix(M,varargin)
% define rotations by matrices
%
% Syntax
%   M = eye(3)
%   rot = rotation.byMatrix(M)
%
% Input
%  M - 3x3 rotation matrix
%
% Output
%  rot - @rotation
%
% See also
% rotation/rotentation rotation/byEuler rotation/byAxisAngle

% negative determinant indicates improper rotation
isInv = false(size(M,3),1);
for i = 1:size(M,3)
  isInv(i) = det(M(:,:,i))<0;
end

% ensure M is proper 
M(:,:,isInv) = -M(:,:,isInv);

rot = rotation(mat2quat(M));
rot.i = isInv;