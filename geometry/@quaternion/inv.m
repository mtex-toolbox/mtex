function q = inv(q)
% quaternion of the inverse rotation
%
% Input
%  q - @quaternion
%
% Output
%  q - @quaternion of the inverse rotation
%
% See also
% quaternion/ctranspose

q = ctranspose(q);
