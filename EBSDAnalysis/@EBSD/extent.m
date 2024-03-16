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

xmin = min(ebsd.prop.x(:));
xmax = max(ebsd.prop.x(:));
ymin = min(ebsd.prop.y(:));
ymax = max(ebsd.prop.y(:));

if nargout <= 1, xmin = [xmin, xmax, ymin, ymax]; end
