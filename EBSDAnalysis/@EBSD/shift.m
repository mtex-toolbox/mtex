function ebsd = shift(ebsd,v)
% shift spatial ebsd-data about vector3d
%
% Input
%  ebsd - @EBSD
%  v    - @vector3d
%
% Output
%  shifted ebsd - @EBSD

ebsd = ebsd + v;
