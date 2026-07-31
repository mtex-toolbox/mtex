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
%   'voronoi' (default) - decomposition + segmentation, no culling, using the
%       Delaunay-adjacency-only mex (jcvoronoiDelaunayOnly_mex, see
%       spatialDecompositionGrid's 'delaunayOnly' flag) instead of the full
%       Voronoi build: doSegmentation only ever needs site adjacency, never
%       the V/F geometry. Grain sizes are never smaller than the final
%       grains', so this never over-culls; on an exactly regular/rigid grid
%       (every interior vertex exactly cocircular) it can very rarely
%       under-cull a grain that touches a same-sized neighbour purely
%       diagonally, since the Delaunay adjacency graph is a superset of the
%       true Voronoi face adjacency there (see check_jcvoronoiDelaunayOnly).
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
  out0  = spatialDecompositionGrid(ebsd,varargin{:},'delaunayOnly');
  I_FD0 = remapIFD(out0,ebsd);

  % Boundary completion can only split these preliminary grains. Keeping the
  % unsplit sizes is conservative (it cannot over-cull) and avoids running
  % the same boundary-completion paths again during the sizing pass.
  segmentationOptions = delete_option(varargin,'completeBoundaries');
  [~,I_DG0] = doSegmentation(I_FD0,out0.F,ebsd,gbc,segmentationOptions{:});
  gid0 = full(I_DG0 * (1:size(I_DG0,2)).');       % grain id per pixel (0 = none)
end

np0 = accumarray(gid0(gid0>0), 1, [max(gid0) 1]); % pixels per grain
sz  = zeros(length(ebsd),1);
sz(gid0>0) = np0(gid0(gid0>0));                   % grain size seen by each pixel
removed = ebsd.isIndexed(:) & sz < minPixel;      % undersized indexed pixels

end
