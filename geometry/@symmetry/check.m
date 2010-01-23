function check(s,varargin)
% check symmetry

d = dot_outer(s.quaternion,s.quaternion);
mypcolor(d);
