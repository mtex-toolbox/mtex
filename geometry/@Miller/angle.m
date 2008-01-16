function a = angle(m1,m2)
% angle between two Miller indece
%% Syntax
%  a = angle(m1,m2)
%
%% Input
%  m1,m2 - @Miller
%
%% Output
%  a - angle

m1 = symvec(m1);
m2 = vector3d(m2);

a = min(acos(dot(m1,m2)./norm(m1)./norm(m2)));
