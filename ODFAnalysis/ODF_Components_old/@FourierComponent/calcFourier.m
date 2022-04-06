function f_hat = calcFourier(component,L,varargin)
% called by ODF/calcFourier

f_hat = component.f_hat(1:min(end,deg2dim(L+1)));
