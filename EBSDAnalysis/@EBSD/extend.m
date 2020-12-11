function [xmin, xmax, ymin, ymax] = extend(ebsd)
% spatial bounds of an EBSD map
%
% Syntax
%
%   [xmin, xmax, ymin, ymax] = extend(ebsd)
%
%   ext = extend(ebsd)
%
% Input
%  ebsd - @EBSD 
%
% Output
%  xmin xmax ymin ymax - bounds of the EBSD map
%  ext - bounds combined in one vector [xmin xmax ymin ymax]
%

xmin = nanmin(ebsd.prop.x(:));
xmax = nanmax(ebsd.prop.x(:));
ymin = nanmin(ebsd.prop.y(:));
ymax = nanmax(ebsd.prop.y(:));

if nargout <= 1, xmin = [xmin, xmax, ymin, ymax]; end
