function ebsd = shift(ebsd,xy)
% shift spatial ebsd-data about (x,y)
%
% Input
%  ebsd - @EBSD
%  xy   - coordinates
%
% Output
%  shifted ebsd - @EBSD

ebsd = affinetrans(ebsd,[],xy);
