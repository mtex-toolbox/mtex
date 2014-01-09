function axes = calcAxisDistribution(obj,varargin)
% calculate axis distribution
%
% Input
% ebsd   - @EBSD
% grains - @grainSet
%
% Flags
%
% Output
%
% See also
% EBSD/calcMisorientation EBSD/plotAngleDistribution

mori = calcMisorientation(obj,varargin{:});

axes = axis(mori);
