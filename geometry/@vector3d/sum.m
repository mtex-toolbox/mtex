function s = sum(v,d)
% componentwide sum
%% Input
%  v - @vector3d 
%  dimensions - [double]
%% Output
%  @vector3d

s = v;
if nargin == 1, d = min(find(size(v.x)~=1)); end

s.x = sum(v.x,d);
s.y = sum(v.y,d);
s.z = sum(v.z,d);
