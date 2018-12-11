function ebsd = fliplr( ebsd )
% flip spatial ebsd-data from left to right
%
% Input
%  ebsd - @EBSD
%
% Output
%  flipped ebsd - @EBSD

m(1) = max(ebsd.prop.x);
m(2) = max(ebsd.prop.y);

ebsd = affinetrans(ebsd,[],[-m(1),0]);
ebsd = rotate(ebsd,rotation.byAxisAngle(yvector,pi));
