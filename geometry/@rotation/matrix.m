function mat = matrix(rot)
% rotation matrix of a rotation
%
% Syntax
%   mat = matrix(rot)
%
% Input
%  rot - @rotation
%
% Output
%  mat - list of matrices
%
% See also
% mat2quat Euler axis2quat hr2quat

mat = matrix@quaternion(rot);

mat = repmat(reshape(1-2*rot.i,1,1,[]),3,3) .* mat;
