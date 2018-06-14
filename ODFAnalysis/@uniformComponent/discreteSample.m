function ori = discreteSample(component,npoints,varargin)
% draw a random sample
%

ori = orientation.rand(npoints,component.CS,component.SS);
