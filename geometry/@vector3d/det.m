function d = det(v1,v2,v3)
% pointwise determinant or triple product of three vector3d
%
% Input
%  v1,v2,v3 - @vector3d
%
% Output
%  d - double
%

if nargin == 3

  %d = dot(v1,cross(v2,v3));
  d = v1.x .* (v2.y .* v3.z - v2.z .* v3.y) + ...
    v1.y .* (v2.z .* v3.x - v2.x .* v3.z) + ...
    v1.z .* (v2.x .* v3.y - v2.y .* v3.x);

else

  d = v1.x(:,1) .* (v1.y(:,2) .* v1.z(:,3) - v1.z(:,2) .* v1.y(:,3)) + ...
    v1.y(:,1) .* (v1.z(:,2) .* v1.x(:,3) - v1.x(:,2) .* v1.z(:,3)) + ...
    v1.z(:,1) .* (v1.x(:,2) .* v1.y(:,3) - v1.y(:,2) .* v1.x(:,3));

end
