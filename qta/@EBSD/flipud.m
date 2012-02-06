function ebsd = flipud(ebsd)
% flip spatial ebsd-data from upside down
%
%% Input
%  ebsd - @EBSD
%
%% Output
%  flipped ebsd - @EBSD

m(1) = max(ebsd.options.x);
m(2) = max(ebsd.options.y);
ebsd = affinetrans(ebsd,[],[0 -m(2)]);

ebsd = rotate(ebsd,rotation('axis',xvector,'angle',pi));
