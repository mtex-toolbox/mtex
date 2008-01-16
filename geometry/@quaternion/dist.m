function d = dist(q1,q2)
% calcualtes distance between rotations q1 and q2
%
%% Syntax  
%  d = dist(q1,q2)
%
%% Input
%  q1, q2 - @quaternion
% 
%% Output
% q1 x q2 - distance (double)

d = 2*acos(min(1,dot_outer(q1,q2)));
