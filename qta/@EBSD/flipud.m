function ebsd = flipud(ebsd)
% flip spatial ebsd-data from upside down
%
%% Input
%  ebsd - @EBSD
%
%% Output
%  flipped ebsd - @EBSD

m = max(vertcat(ebsd.X));
ebsd = affinetrans(ebsd,[],[0 m(2)]);

ebsd = rotate(ebsd,rotation('axis',xvector,'angle',pi));