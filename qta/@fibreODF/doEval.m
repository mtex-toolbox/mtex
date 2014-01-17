function f = doEval(odf,g,varargin)
% evaluate an odf at orientation g
%

f = RK(odf.psi, g(:), odf.h, odf.r, odf.c,odf.CS,odf.SS,1);
