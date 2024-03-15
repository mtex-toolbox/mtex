function [xmin, xmax, ymin, ymax] = extent(ebsd)
% spatial bounds of an EBSD map
%
% Syntax
%
%   [xmin, xmax, ymin, ymax] = extent(ebsd)
%
%   ext = extent(ebsd)
%
% Input
%  ebsd - @EBSD 
%
% Output
%  xmin xmax ymin ymax - bounds of the EBSD map
%  ext - bounds combined in one vector [xmin xmax ymin ymax]
%

xmin = nanmin(ebsd.pos.x(:));
xmax = nanmax(ebsd.pos.x(:));
ymin = nanmin(ebsd.pos.y(:));
ymax = nanmax(ebsd.pos.y(:));
zmin = nanmin(ebsd.pos.z(:));
zmax = nanmax(ebsd.pos.z(:));


if nargout <= 1, xmin = [xmin, xmax, ymin, ymax, zmin, zmax]; end
