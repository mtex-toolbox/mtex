function rot = exp(v,rot_ref,varargin)
% rotation vector to rotation
%
% Syntax
%
%   mori = exp(v) % misorientation in specimen coordinates
%
%   rot = exp(v,ori_ref) % orientation update
%
% Input
%  v - @vector3d rotation vector in specimen coordinates
%  ori_ref - @orientation @rotation
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

if isfield(v.opt,'tangentSpace') 
  tS = v.opt.tangentSpace;
else
  tS = [];
end
if ( strcmp(tS,'right') && check_option(varargin,'left') ) || ...
      ( strcmp(tS,'left') && check_option(varargin,'right') )
  error(['The vectors are elements of one tangent space and you try to compute ' ...
         'the exponential mapping w.r.t. the other representation of the tangent space.']);
end

if nargin >= 2
  if ( nargin>2 && check_option(varargin,'left') ) || strcmp(tS,'left')
    rot =  rot * rot_ref;
  else
    rot =  rot_ref .* rot;
  end
end