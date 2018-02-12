function q = vec42quat(u1,v1,u2,v2)
% returns a quaternion q with q u_1 = v1 and q u2 = v2
%
% Description
% The method *vec42quat* defines a [[quaternion_index.html,quaternion]] |q|
% by 4 directions |u1|, |u2|, |v1| and |v2| such that |q * u1 = v1| and |q
% * u2 = v2| 
%
% Input
%  u1, u2 - @vector3d
%  v1, v2 - @vector3d
%
% Output
%  q - @quaternion
%
% See also
% quaternion_index quaternion/quaternion axis2quat Miller2quat 
% euler2quat hr2quat


u1 = vector3d(u1); v1 = vector3d(v1);

% ckeck whether points have the same angle relative to each other
if any(abs(dot(u1,vector3d(u2))-dot(v1,vector3d(v2)))>1E-3)
  
  if isa(u2,'Miller'), u2 = u2.CS * u2; end
  if isa(v2,'Miller'), v2 = v2.CS * v2; end
  
  delta = abs(repmat(angle(u1,u2),1,length(v2)) ...
    - repmat(angle(v1,v2),1,size(u2,1)).');
  [i,j] = find(delta<1*degree,1);
  
  if isempty(i)
    error(['Inconsitent pairs of vectors!',...
      ' Angle difference: ',num2str(min(delta)),mtexdegchar]) %#ok<WNTAG>
  else
    u2 = u2(i);
    v2 = v2(j);    
  end
end

% normalize input
u1 = normalize(vector3d(u1));
v1 = normalize(vector3d(v1));
u2 = normalize(vector3d(u2));
v2 = normalize(vector3d(v2));

% check vectors are not colinear
if any(abs(dot(u1,u2))>1-eps)
  warning('Input vectors should not be colinear!');
end

% a third orthogonal vector
u3 = normalize(cross(u1,u2));
v3 = normalize(cross(v1,v2));

% make also the second vector orthogonal to the first one
u2t = normalize(cross(u3,u1));
v2t = normalize(cross(v3,v1));

% define the transformation matrix
A = permute(double([v1(:),v2t(:),v3(:)]),[2 3 4 1]); %  3(xyz) x 3 x 1 x N
B = permute(double([u1(:),u2t(:),u3(:)]),[2 4 3 1]); %  3(xyz) x 1 x 3 x N

M = squeeze(sum(bsxfun(@times,A,B),1));

% convert to quaternion
q = mat2quat(M);
