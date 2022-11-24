function plotFourier(SO3F,varargin)
% visualize the harmonic coefficients
%
% Syntax
%   plotFourier(SO3F)
%   plotFourier(SO3F,'bandwidth',32)
%
% Input
%  SO3F - @SO3Fun
%

warning('The command plotFourier is depreciated! Please use plotSpektra instead.')

plotSpektra(SO3F,varargin)