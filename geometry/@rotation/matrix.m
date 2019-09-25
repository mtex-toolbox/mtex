function mat = matrix(rot)
% quaternion to direction cosine matrix conversion
% converts direction cosine matrix to quaternion
%
% Syntax
%   mat = matrix(q)
%
% Input
%
%  q - @quaternion
%
% Output
%
%  mat - vector of matrixes
%
% See also
% mat2quat Euler axis2quat hr2quat

mat = matrix@quaternion(rot);

mat = repmat(reshape(1-2*rot.i,1,1,[]),3,3) .* mat;
