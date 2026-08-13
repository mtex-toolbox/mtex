function [xmin, xmax, ymin, ymax] = extent(ebsd,ind)
% spatial bounds of an EBSD map
%
% Syntax
%
%   [xmin, xmax, ymin, ymax] = extent(ebsd)
%
%   ext = extent(ebsd)
%
% Description
% The bounds of the measured positions. Gridded data is padded to a full
% rectangular raster, and those padding cells are not measurements - they
% are excluded here. This matters: a grid rotated against the map axes, as
% in |mtexdata sharp|, needs padding well outside the measured region to
% close its raster - 56% of the cells there, and an extent three times too
% large in y.
%
% Input
%  ebsd - @EBSD
%
% Output
%  xmin xmax ymin ymax - bounds of the EBSD map
%  ext - bounds combined in one vector [xmin xmax ymin ymax]
%
% See also
% EBSD/gridify EBSD/plot

pos = ebsd.pos;

% the padding of a gridded map carries no phase
isPad = isnan(ebsd.phaseId);
if any(isPad(:)), pos = pos(~isPad); end

xmin = min(pos.x(:));
xmax = max(pos.x(:));
ymin = min(pos.y(:));
ymax = max(pos.y(:));
zmin = min(pos.z(:));
zmax = max(pos.z(:));

if nargout <= 1, xmin = [xmin, xmax, ymin, ymax, zmin, zmax]; end
if nargin == 2, xmin = xmin(ind); end
