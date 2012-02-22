function axes = calcAxisDistribution(ebsd,varargin)
% calculate axis distribution
%
%% Input
% ebsd - @EBSD
%
%% Flags
%
%% Output
%
%% See also
% EBSD/calcMisorientation EBSD/plotAngleDistribution

mori = calcMisorientation(ebsd,varargin{:});

axes = axis(mori);
