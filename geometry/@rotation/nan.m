function r = nan(varargin)
% rotations with all components set to NaN
%
% Description
% Placeholder rotations, e.g. to preallocate an array that is filled later
% on. Any operation involving a NaN rotation returns NaN.
%
% Syntax
%   rot = rotation.nan
%   rot = rotation.nan(5)
%   rot = rotation.nan(10,3)
%
% Input
%  n,m - size of the array of rotations
%
% Output
%  rot - @rotation
%
% See also
% rotation/id rotation/rand

r = rotation(quaternion.nan(varargin{:}));
