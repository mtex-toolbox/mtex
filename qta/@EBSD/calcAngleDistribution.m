function [density,omega] = calcAngleDistribution(ebsd,varargin)
% calculate angle distribution
%
%% Input
% ebsd - @EBSD
%
%% Flags
%
%% Output
% density - the density, such that 
%
%    $$\int f(\omega) d\omega = \pi$$
%
% omega  - intervals of density
%% See also
% EBSD/calcMisorientation EBSD/plotAngleDistribution

m = calcMisorientation(ebsd,varargin{:});


[dns,omega] = angleDistribution(get(m,'CS'));
omega = linspace(0,max(omega),min(50,max(5,numel(m)/20)));
omega = get_option(varargin,'omega',omega);

density = histc(angle(m),omega);
density = pi*density./mean(density);
