function [density,omega] = calcAngleDistribution(grains,varargin)


if check_option(varargin,'misorientation')
  m = calcBoundaryMisorientation(grains,varargin{:});
else
  m = get(grains,'mis2mean');
end

[dns,omega] = angleDistribution(get(m,'CS'));

density = histc(angle(m),omega);

density = density./(sum(density)./sum(dns));
