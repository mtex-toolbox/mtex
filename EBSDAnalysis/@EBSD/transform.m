function ebsd = transform(ebsd,fun)
% apply an arbitrary spatial transformation to an EBSD map
%
% Applies fun to the position of every pixel, leaving orientations, phase
% and all other properties untouched. Unlike <EBSD.rotate.html |rotate|>,
% fun need not be a rigid transformation - it may be any map from position
% to position, e.g. to simulate an instrument distortion such as a
% trapezoidal stage drift, or to reproject onto a different coordinate
% system.
%
% Syntax
%   % scale x about the map centre by an amount that grows with y - a
%   % trapezoidal stage drift of trapFrac at the outermost rows
%   x = ebsd.pos.x; xCenter = (min(x)+max(x))/2;
%   y = ebsd.pos.y; yCenter = (min(y)+max(y))/2; yHalf = (max(y)-min(y))/2;
%   trapFrac = 0.02;
%   ebsd = transform(ebsd, @(pos) vector3d( ...
%     xCenter + (pos.x-xCenter) .* (1 + trapFrac*(pos.y-yCenter)/yHalf), ...
%     pos.y, pos.z));
%
% Input
%  ebsd - @EBSD
%  fun  - function handle, @vector3d -> @vector3d
%
% Output
%  ebsd - @EBSD with transformed ebsd.pos
%
% See also
% EBSD/rotate

ebsd.pos = fun(ebsd.pos);

end
