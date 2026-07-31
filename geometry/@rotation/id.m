function r = id(varargin)
% the identical rotation
%
% Description
% The rotation that leaves every vector unchanged, i.e., the neutral
% element of the rotation group.
%
% Syntax
%   rot = rotation.id
%   rot = rotation.id(5)
%   rot = rotation.id(10,3)
%
% Input
%  n,m - size of the array of rotations
%
% Output
%  rot - @rotation
%
% See also
% rotation/inversion rotation/nan rotation/rand

r = rotation(quaternion.id(varargin{:}));
