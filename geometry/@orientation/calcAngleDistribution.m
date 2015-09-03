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
% EBSD/calcMisorientation plotAngleDistribution

omega = linspace(0,maxAngle(ori.CS,ori.SS),min(50,max(5,length(ori)/20)));
omega = get_option(varargin,'omega',omega);

density = histc(angle(ori),omega);

density = 100*density./sum(density);

end
