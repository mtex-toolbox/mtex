function Z = doPDF(odf,h,r,varargin)
% calculate pdf 

M = RRK(odf.psi, odf.h, odf.r, h, r, odf.CS,odf.SS,varargin{:});

Z = reshape(M,[],numel(odf.c)) * odf.c(:);
