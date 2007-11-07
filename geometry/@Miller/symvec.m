function v = symvec(m)
% directions symmetrically equivalent to m
% usage:  v = symeq(m)    - vectors symmetrically equivalent to m
%
%% Input
%  m - @Miller
%
%% Output
%  v - @vector3d


v = reshape(vector3d(m),1,[]);
v = cunion(quaternion(m.CS) * v);

