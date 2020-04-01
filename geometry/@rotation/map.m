function rot = map(u1,v1,u2,v2)
% define rotations by pairs of vectors
%
% Description
% Define a rotation that maps |u1| onto |v1| and |u2| onto |v2|
%
% Syntax
%
%   % an arbitrary rotation that maps u1 parallel to v1
%   rot = rotation.map(u1,v1)
%
%   % a rotation that maps u1 parallel to v1 and u2 parallel to v2
%   rot = rotation.map(u1,v1,u2,v2)
%
% Input
%  u1, v1, u2, v2 - @vector3d
%
% Output
%  rot - @rotation
%
% See also
% rotation/rotation rotation/byMatrix rotation/byAxisAngle
% rotation/byEuler

if nargin == 4
  
  % normalize input
  u1 = normalize(u1);
  v1 = normalize(v1);
  u2 = normalize(u2);
  v2 = normalize(v2);

  % ckeck whether points have the same angle relative to each other
  delta = abs(angle(u1,u2,'noSymmetry') - angle(v1,v2,'noSymmetry'));
  assert(all(delta(:) < 1E-3),...
    ['Inconsitent pairs of vectors! sThe angle between u1, u2 and v1, v2 needs ' ....
    'to be the same, but differs by ' num2str(max(delta(:))./degree),mtexdegchar]);

  % check vectors are not colinear
  if any(abs(dot(u1,u2,'noSymmetry'))>1-eps)
    warning('Input vectors should not be colinear!');
  end

  % a third orthogonal vector
  u3 = normalize(cross(u1,u2));
  v3 = normalize(cross(v1,v2));

  % make also the second vector orthogonal to the first one
  u2t = normalize(cross(u3,u1));
  v2t = normalize(cross(v3,v1));

  % define the transformation matrix
  A = permute(double([vector3d(v1(:)),v2t(:),v3(:)]),[2 3 4 1]); %  3(xyz) x 3 x 1 x N
  B = permute(double([vector3d(u1(:)),u2t(:),u3(:)]),[2 4 3 1]); %  3(xyz) x 1 x 3 x N

  M = squeeze(sum(bsxfun(@times,A,B),1));

  % convert to quaternion
  rot = rotation.byMatrix(M);
  
else
  quat = hr2quat(u1,v1);
  rot = rotation(quat);
end

end
