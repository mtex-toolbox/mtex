function ebsd = fliplr( ebsd )
% flip spatial ebsd-data from left to right
%
%% Input
%  ebsd - @EBSD
%
%% Output
%  flipped ebsd - @EBSD

m = max(vertcat(ebsd.X));
%ebsd = affinetrans(ebsd,[-1 0; 0 1],m);

ebsd = affinetrans(ebsd,[],[-m(1),0]);
ebsd = rotate(ebsd,rotation('axis',yvector,'angle',pi));

