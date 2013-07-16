function Z = doPDF(odf,h,r,varargin)
% called by pdf 

Z = RK(odf.psi,odf.center,h,r,odf.c,odf.CS,odf.SS,varargin{:});
