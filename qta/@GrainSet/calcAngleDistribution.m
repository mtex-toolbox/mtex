function [density,omega] = calcAngleDistribution(grains,varargin)
% calculate angle distribution
%
%% Input
% grains - @GrainSet
%% Flags
% boundary - calculate the misorientation angle at grain boundaries
%% Output
% density - the density, such that 
%
%    $$\int f(\omega) d\omega = \pi$$
%
% omega  - intervals of density
%% See also
% GrainSet/calcBoundaryMisorientation GrainSet/plotAngleDistribution

if check_option(varargin,{'boundary','misorientation'})
  m = calcBoundaryMisorientation(grains,varargin{:});
else
  m = calcMisorientation(grains,varargin{:});
end

[dns,omega] = angleDistribution(get(m,'CS'));
omega = linspace(0,max(omega),min(50,max(5,numel(m)/20)));
omega = get_option(varargin,'omega');

density = histc(angle(m),omega);
density = pi*density./mean(density);
