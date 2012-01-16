function [density,omega] = calcAngleDistribution(grains,varargin)


if check_option(varargin,{'boundary','misorientation'})
  m = calcBoundaryMisorientation(grains,varargin{:});
else
  m = calcMisorientation(grains,varargin{:});
end

[dns,omega] = angleDistribution(get(m,'CS'));

density = histc(angle(m),omega);
density = pi*density./mean(density);
