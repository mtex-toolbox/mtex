function ebsd = flipud(ebsd)
% flip spatial ebsd-data from upside down
%
%% Input
%  ebsd - @EBSD
%
%% Output
%  flipped ebsd - @EBSD

m = max(vertcat(ebsd.xy));
ebsd = affinetrans(ebsd,[1 0; 0 -1],[0 m(2)]);