function f = doEval(odf,g,varargin)
% evaluate an odf at orientation g

f = reshape(sum_K(odf.psi,g,odf.center,odf.CS,odf.SS,...
  odf.c(:),varargin{:}),size(g));
