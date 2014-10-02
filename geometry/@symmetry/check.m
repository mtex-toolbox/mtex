function check(s,varargin)
% check symmetry

d = dot_outer(rotation(s),rotation(s));
imagesc(d)
