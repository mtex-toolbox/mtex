function plotKAM(grains,varargin)



am = calcKAM(grains,varargin{:});

plot(EBSD(grains),'property',am/degree);
