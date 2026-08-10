function ebsd = transform(ebsd,fun)
% apply an arbitrary spatial transformation to an EBSD map
%
% Applies fun to the position of every pixel and to the unit cell, leaving
% orientations, phase and all other properties untouched. Unlike
% <EBSD.rotate.html |rotate|>, fun need not be a rigid transformation - it
% may be any map from position to position, e.g. to simulate an instrument
% distortion such as a trapezoidal stage drift, or to reproject onto a
% different coordinate system.
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
%  ebsd - @EBSD with transformed ebsd.pos and ebsd.unitCell
%
% See also
% EBSD/rotate EBSD/updateUnitCell grain2d/transform

% the transformation changes the pixel footprint as well, and a unit cell
% left behind is not merely cosmetic: ebsd.lattice derives the lattice basis
% from the unit cell alone and then assigns every pixel its integer index
% against that basis, so a cell that disagrees with pos misindexes the map
% for calcGrains, gradient and everything else downstream.
%
% Push the cell through fun about the centre of the map, the same way rotate
% pushes it through the rotation. This is exact for any affine fun (shear,
% scale, rotation) and preserves the corner count, so a square cell stays
% 4 cornered and a hex cell stays 6 cornered - which latticeBasis requires.
% For a nonlinear fun it is the cell at the centre of the map, the best a
% single global unit cell can represent.
%
% NB do not recompute the cell from the transformed positions instead
% (updateUnitCell with no argument, as fixPos does): calcUnitCell only ever
% emits a regular polygon, so it returns a sheared grid either as an
% unsheared square or, via its Voronoi fallback, as a hexagon.
hasCell = ~isempty(ebsd.unitCell);
if hasCell
  % pos(:) because on a grid class pos is a matrix, and mean would then
  % average each column separately instead of giving the map centre
  c = mean(ebsd.pos(:));
  uC = fun(c + ebsd.unitCell) - fun(c);
end

ebsd.pos = fun(ebsd.pos);

if hasCell, ebsd = ebsd.updateUnitCell(uC); end

end
