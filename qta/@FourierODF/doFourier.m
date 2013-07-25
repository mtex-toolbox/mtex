function f_hat = doFourier(odf,L,varargin)
% called by ODF/calcFourier

f_hat = odf.f_hat(1:min(end,deg2dim(L)));

