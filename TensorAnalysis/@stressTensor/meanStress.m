function p = meanStress(sigma,varargin)
% mean stress
%
% Input
%  sigma - @stressTensor
%
% Output
%  s - double
%

p = trace(sigma)./3;
