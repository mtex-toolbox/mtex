function  l = segLength(gB,varargin)
% length of boundary segments in µm
%
% Input
%  gb - @grainBoundary
%
% Output
%  l - length of the boundary segments in µm
%

l = sqrt(sum((gB.V(gB.F(:,1),:) - gB.V(gB.F(:,2),:)).^2,2));
