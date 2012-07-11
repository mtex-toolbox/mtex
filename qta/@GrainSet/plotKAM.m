function plotKAM(grains,varargin)



am = calcKAM(grains,varargin{:});

plot(grains.EBSD,'property',am/degree);
