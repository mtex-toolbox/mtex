function rot = exp(v,varargin)
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
%  ori_ref - @orientation, @rotation
%  tS      - @SO3TangentSpace
%
% Output
%  mori - @rotation
%  ori  - @orientation
%
% See also
% Miller/exp orientation/log



% if nargin > 1 && isa(varargin{1},'vector3d')
%   rot = normalize(rot_ref + v);
%   return
% end

% extract data
if nargin>1 && isa(varargin{1},'quaternion')
  rot_ref = varargin{1};
else
  rot_ref = quaternion.id;
end
tS = SO3TangentSpace.extract(varargin);


% norm of the vector is rotational angle
omega = norm(v);

alpha = zeros(size(omega));
ind = omega ~=0;
alpha(ind) = sin(omega(ind)/2) ./ omega(ind);

rot = quaternion(cos(omega/2),alpha .* v.x,alpha .* v.y,alpha .* v.z);

% rotate tangent space to reference rotation
if tS.isLeft
  rot =  times(rot, rot_ref,1);
else
  rot =  times(rot_ref,rot,0);
end
