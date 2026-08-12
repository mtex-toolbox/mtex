function ebsd = minus(ebsd,v)
% shift ebsd in x/y direction
%
% Syntax
%
%   % shift in x direction
%   ebsd = ebsd - 100*vector3d.X
%
% Input
%  ebsd - @EBSD
%  v - @vector3d shift
%
% Output
%  ebsd - @EBSD

ebsd = ebsd + (-v);
