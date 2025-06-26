function rot = exp(v,varargin)
% tangent vector to rotation
%
% Syntax
%   rot = exp(v)  % orientation update
%
% Input
%  v - @SO3TangentVector rotation vector in specimen coordinates
%
% Output
%  rot  - @rotation
%
% See also
% vector3d/exp orientation/log


tS = v.tangentSpace;
rot_ref = v.rot;

rot = exp@vector3d(v,rot_ref,tS);

end