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
% orientation/log


% -------------------------------------------------------------------------
% ---------------------- exponential map on S2 ----------------------------
% -------------------------------------------------------------------------
if nargin > 1 && isa(varargin{1},'vector3d')
  rot = normalize(varargin{1} + v);
  return
end

% -------------------------------------------------------------------------
% ---------------------- exponential map on SO(3) -------------------------
% -------------------------------------------------------------------------

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

% a rotation vector given in a crystal frame is a misorientation of that
% frame with itself, and it updates a reference orientation from the right -
% a tangent vector brings its own reference and is handled by SO3TangentVector/exp
if isCrystalDirection(v) && ~isa(v,'SO3TangentVector')

  rot = orientation(rot,v.CS,v.CS);

  if nargin > 1 && isa(varargin{1},'quaternion')
    tSc = SO3TangentSpace.extract(SO3TangentSpace.rightVector,varargin{:});
    if tSc.isLeft
      rot = rot * varargin{1};
    else
      rot = varargin{1} .* rot;
    end
  end
  return
end

% rotate tangent space to reference rotation
if tS.isLeft
  rot =  times(rot, rot_ref,1);
else
  rot =  times(rot_ref,rot,0);
end
