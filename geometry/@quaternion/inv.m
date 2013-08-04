function q = inv(q)
% quaternion of the inverse roation
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
