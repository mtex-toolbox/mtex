function [density,omega] = calcAngleDistribution(ori,varargin)
% calculate angle distribution
%
% Input
%  ori   - @orientation
%
% Flags
%
% Output
%  density - the density normalized such that sum(density)=100
%  omega   - corresponding list of misorientation angles
%
% See also
% EBSD/calcMisorientation misorientationAnalysis/plotAngleDistribution

[dns,omega] = angleDistribution(ori.CS);
omega = linspace(0,max(omega),min(50,max(5,length(ori)/20)));
omega = get_option(varargin,'omega',omega);

density = histc(angle(ori),omega);

density = 100*density./sum(density);

end
