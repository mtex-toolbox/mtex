function r = rand(varargin)
% uniformly distributed random rotations
%
% Description
% Rotations drawn from the uniform distribution on SO(3), i.e., from the
% Haar measure. With the option |maxAngle| the rotations are restricted to
% a ball around the identical rotation.
%
% Syntax
%   rot = rotation.rand
%   rot = rotation.rand(100)
%   rot = rotation.rand(10,3)
%   rot = rotation.rand(100,'maxAngle',10*degree)
%
% Input
%  n,m - size of the array of rotations
%
% Options
%  maxAngle - restrict the rotational angle
%
% Output
%  rot - @rotation
%
% See also
% rotation/id rotation/nan orientation/rand

r = rotation(quaternion.rand(varargin{:}));
