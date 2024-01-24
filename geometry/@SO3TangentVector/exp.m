function rot = exp(v,rot_ref,varargin)
% rotation vector to rotation
%
% Syntax
%   rot = exp(v,ori_ref)  % orientation update
%
% Input
%  v - @SO3TangentVector rotation vector in specimen coordinates
%  ori_ref - @orientation @rotation
%
% Output
%  rot  - @rotation
%
% See also
% vector3d/exp orientation/log


tS = v.tangentSpace;

rot = exp@vector3d(v,rot_ref,tS);

end