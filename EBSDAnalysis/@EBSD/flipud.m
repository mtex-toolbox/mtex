function ebsd = flipud(ebsd)
% flip spatial ebsd-data from upside down
%
% Input
%  ebsd - @EBSD
%
% Output
%  flipped ebsd - @EBSD

m(1) = max(ebsd.prop.x,[],'all');
m(2) = max(ebsd.prop.y,[],'all');
ebsd = affinetrans(ebsd,[],[0 -m(2)]);

ebsd = rotate(ebsd,rotation.byAxisAngle(xvector,pi));
