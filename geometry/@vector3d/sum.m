function s = sum(v,d)
% componentwide sum
%% Input
%  v - @vector3d 
%  dimensions - [double]
%% Output
%  @vector3d

if nargin == 1
    s = vector3d(sum(v.x),sum(v.y),sum(v.z));
else
    s = vector3d(sum(v.x,d),sum(v.y,d),sum(v.z,d));
end
