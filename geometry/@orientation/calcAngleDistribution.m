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

edges = linspace(0,maxAngle(ori.CS,ori.SS),min(50,max(5,length(ori)/20)));
edges = get_option(varargin,'edges',edges);

density = histcounts(angle(ori),edges);

density = 100*density./sum(density);

omega = 0.5*(edges(1:end-1) + edges(2:end));

end
