function f_hat = doFourier(odf,L,varargin)
% called by ODF/calcFourier

f_hat = odf.c_hat(1:max(end,deg2dim(L)));

