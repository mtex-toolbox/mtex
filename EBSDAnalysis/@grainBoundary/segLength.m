function  l = segLength(gB,varargin)
% length of a boundary segment
%
% Input
%  gb - @grainBoundary
%
% Output
%  l - length of the boundary segments
%

l = sqrt(sum((gB.V(gB.F(:,1),:) - gB.V(gB.F(:,2),:)).^2,2));
