function check(s,varargin)
% check symmetry

d = dot_outer(s.quat,s.quat);
mypcolor(d);
