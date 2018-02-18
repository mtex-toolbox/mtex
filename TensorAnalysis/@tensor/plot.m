function plot(T,varargin)
% plot a tensor T
%
% Input
%  T - @tensor
%

plot(T.directionalMagnitude,varargin{:})
