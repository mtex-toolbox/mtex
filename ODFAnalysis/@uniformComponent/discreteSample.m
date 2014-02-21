function ori = discreteSample(component,npoints,varargin)
% draw a random sample
%

ori = orientation('random',component.CS,component.SS,'points',npoints);
