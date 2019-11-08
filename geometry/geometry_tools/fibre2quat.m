function q = fibre2quat(h,r,varargin)
% arbitrary quaternion q with q * h = r 
%
% Description 
% The method *fibre2quat* defines a list of
% <quaternion.quaternion.html,quaternions> |q| by a crystal direction |h|
% and a specimen direction |r| such that |q * h = r|
%
% Input
%  h - @Miller or @vector3d
%  r - @vector3d
%
% Options
%  resolution - double
%
% Output
%  q - @quaternion
%
% See also
% quaternion/quaternion quaternion/quaternion axis2quat Miller2quat 
% vec42quat euler2quat

q1 = hr2quat(h,r);

res = get_option(varargin,'resolution',1*degree);
omega = -pi:res:pi;

q2 = axis2quat(h,omega);

q = q1 * q2;

