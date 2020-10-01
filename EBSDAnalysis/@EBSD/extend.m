function [xmin, xmax, ymin, ymax] = extend(ebsd)
% returns the boundings of spatial EBSD data
%
% Input
%  ebsd - @EBSD 
%
% Output
%  ext - extend as [xmin xmax ymin ymax]
%

xmin = nanmin(ebsd.prop.x(:));
xmax = nanmax(ebsd.prop.x(:));
ymin = nanmin(ebsd.prop.y(:));
ymax = nanmax(ebsd.prop.y(:));

if nargout <= 1, xmin = [xmin, xmax, ymin, ymax]; end
