function rot = exp(v,rot_ref,varargin)
% rotation vector to rotation
%
% Description
% 
% Syntax
%
%   mori = exp(m) % misorientation in specimen coordinates
%
%   rot = exp(m,ori_ref) % orientation update
%
% Input
%  v - @vector3d rotation vector in specimen coordinates
%  ori_ref - @orientation @rotation
%
% Output
%  mori - @rotation
%  ori - @orientation
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

if nargin >= 2
  if nargin>2 && check_option(varargin,'left')
    rot =  rot * rot_ref;
  else
    rot =  rot_ref .* rot;
  end
end