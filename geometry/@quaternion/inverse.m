function g = inverse(q)
% quaternion of the inverse roation
%
%% Input
%  q - @quaternion
%
%% Output
%  g - @quaternion of the inverse rotation
%
%% See also
% quaternion/ctranspose

g = ctranspose(q);
