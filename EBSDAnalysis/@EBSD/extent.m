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

xmin = min(ebsd.pos.x(:));
xmax = max(ebsd.pos.x(:));
ymin = min(ebsd.pos.y(:));
ymax = max(ebsd.pos.y(:));
zmin = min(ebsd.pos.z(:));
zmax = max(ebsd.pos.z(:));


if nargout <= 1, xmin = [xmin, xmax, ymin, ymax, zmin, zmax]; end
