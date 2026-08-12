function removed = minPixelMask(ebsd,gbc,varargin)
% pixels belonging to undersized indexed grains, for the minPixel filter
%
% Returns only a logical mask (no copy of the ebsd object). The caller applies
% it in place, e.g.  ebsd.phaseId(removed) = 1;  so the potentially large ebsd
% object is never round-tripped through this function.
%
% The alpha closing connects grain pixels across bridged gaps and diagonals
% (Voronoi face adjacency), which a local neighbour graph cannot see. To size
% grains consistently with the final result we run the full decomposition once
% without culling (default), or use a cheaper grid neighbourhood.
%
% Sizing methods:
%   'voronoi' (default) - decomposition + segmentation, no culling. On a
%       HEX grid this uses the Delaunay-adjacency-only mex
%       (jcvoronoiDelaunayOnly_mex, see spatialDecompositionGrid's
%       'delaunayOnly' flag) instead of the full Voronoi build:
%       doSegmentation only ever needs site adjacency, never the V/F
%       geometry, and on a triangular lattice the Delaunay is unique and
%       equals the 6-neighbour graph, so the cheap build is exact there.
%       On a SQUARE grid it is not - see the gate below - so the full
%       Voronoi build is used.
%   'grid' - connected components on the grid neighbourhood (stencil +
%       diagonals) only. Cheaper, but may over-cull grains connected solely
%       through bridged gaps.
%
% Input
%  ebsd - @EBSD (gridified)
%  gbc  - grain boundary criterion
%
% Output
%  removed - nEbsd x 1 logical, true for undersized indexed pixels

removed = false(length(ebsd),1);

minPixel = get_option(varargin,'minPixel',1);
if minPixel <= 1, return; end

minPixelMethod = get_option(varargin,'minPixelMethod','voronoi');

if strcmpi(minPixelMethod,'grid')
  gid0 = gridComponents(ebsd,gbc,varargin{:});    % grain id per pixel, 0 = none
else
  % Delaunay-adjacency-only sizing is exact on a HEX grid and wrong on a
  % SQUARE one (#2513). A triangular lattice has no cocircular degeneracy:
  % its Delaunay triangulation is unique and its edges are exactly the
  % 6-neighbour graph, so the cheap build gives the same adjacency the full
  % Voronoi does - and full Voronoi would only cost time there (+22..66% on
  % the sizing pass of a 4M pixel map).
  %
  % On a square lattice every interior Voronoi vertex is four cocircular
  % points, so the Delaunay has to invent a diagonal at every single one.
  % Sizing is then 8-connected while the final segmentation is 4-connected:
  % a chain of pixels joined only diagonally counts as ONE grain here and
  % breaks into several afterwards, so undersized grains survive the cull.
  % Not a rare degeneracy but the generic case on a square map: at
  % 'angle',10*degree,'minPixel',5 it left 361 of 3643 grains undersized on
  % martensite and 33 of 903 on forsterite, against 4 and 2 with the full
  % build, at the same runtime. So use the cheap build only where it is exact.
  %
  % The residual few are a different, deeper effect and not addressed here:
  % culling changes the map the SECOND decomposition runs on, so the alpha
  % closing reorganises and grains can re-fragment below minPixel after the
  % sizing pass has already decided. Iterating the two passes oscillates
  % rather than converges, so it stays a one-shot filter.
  %
  % Gate on the unit cell rather than on ebsd.lattice: same answer, without
  % recomputing the per-pixel lattice index that spatialDecompositionGrid is
  % about to compute anyway. Anything that is not a 6-corner (hex) cell gets
  % the correct-but-slower path.
  if length(ebsd.unitCell) == 6, varargin = [varargin,{'delaunayOnly'}]; end

  out0  = spatialDecompositionGrid(ebsd,varargin{:});
  I_FD0 = remapIFD(out0,ebsd);
  [~,I_DG0] = doSegmentation(I_FD0,ebsd,gbc,varargin{:});
  gid0 = full(I_DG0 * (1:size(I_DG0,2)).');       % grain id per pixel (0 = none)
end

np0 = accumarray(gid0(gid0>0), 1, [max(gid0) 1]); % pixels per grain
sz  = zeros(length(ebsd),1);
sz(gid0>0) = np0(gid0(gid0>0));                   % grain size seen by each pixel
removed = ebsd.isIndexed(:) & sz < minPixel;      % undersized indexed pixels

end
