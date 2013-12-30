function ori = discreteSample(odf,npoints,varargin)
% draw a random sample
%

ori = orientation('random',odf.CS,odf.SS,'points',npoints);
