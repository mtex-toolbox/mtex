function rot = exp(v,rot_ref,tS)
% rotation vector to rotation
%
% Syntax
%
%   mori = exp(v) % misorientation in specimen coordinates
%
%   rot = exp(v,ori_ref,SO3TangentSpace.rightVector) % orientation update
%
%   ori = exp(v,ori_ref,tS) % orientation update
%
% Input
%  v       - @vector3d, @SO3TangentVector
%  ori_ref - @orientation @rotation
%  tS      - @SO3TangentSpace
%
% Output
%  mori - @rotation
%  ori  - @orientation
%
% See also
% Miller/exp orientation/log

% norm of the vector is rotational angle
omega = norm(v);

alpha = zeros(size(omega));
ind = omega ~=0;
alpha(ind) = sin(omega(ind)/2) ./ omega(ind);

if nargin > 1 && isa(rot_ref,'rotation')
  rot = rotation(cos(omega/2),alpha .* v.x,alpha .* v.y,alpha .* v.z);
else
  rot = quaternion(cos(omega/2),alpha .* v.x,alpha .* v.y,alpha .* v.z);  
end

if (nargin>2 && tS.isLeft) || ...
    (isa(v,'SO3TangentVector') && v.tangentSpace.isLeft)
  rot =  times(rot, rot_ref,1);
elseif nargin>1
  rot =  times(rot_ref,rot,0);
end