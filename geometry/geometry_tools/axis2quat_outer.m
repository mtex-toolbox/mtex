function q = axis2quat_outer(v,omega)
% rotational axis, roational angle to Quaternion
%
% Decription
% defines a rotation by a rotational axis and a roational angle
%
% Syntax
%   q = achs2quat(v,omega)
%
% Input
%  v     - rotational axis (@vector3d)
%  omega - rotational angle
%
% Output
%  q - @quaternion
%
% See also
%  quaternion/quaternion euler2quat Miller2quat vec42quat hr2quat

v = v ./norm(v);
omega = omega(:)';

q = quaternion(repmat(cos(omega/2),length(v),1),v(:) * sin(omega/2));
