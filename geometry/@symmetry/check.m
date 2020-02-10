function check(sym,varargin)
% check symmetry

d = dot_outer(sym.rot,sym.rot);
imagesc(d)
