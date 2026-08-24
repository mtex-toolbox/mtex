function [reconstructPos,idealFun,isRigid] = latticeModel(pos,ij,isIndexed,dxy)
% deformation aware map from lattice index (i,j) to physical position
%
% Reconstructs where a grid cell with no real measurement sits - notIndexed
% holes, the dummy/band ring around the map, filled small gaps. A single
% rigid affine ij*A' + origin disagrees with the true position under smooth
% non-rigid distortion (e.g. a trapezoidal stage drift, see EBSD/transform):
% it shifts Voronoi boundaries near every hole and edge and manufactures
% spurious extra grains. So fit the ideal affine lattice to the indexed
% pixels, then interpolate the *local* deviation between the real positions
% and that ideal grid in index space, and evaluate it where there is no data.
%
% Most EBSD grids are already (near-)rigid, in which case the affine part
% alone is accurate enough and the deformation term is skipped - it costs two
% natural-neighbour scatteredInterpolant fits, each a Delaunay triangulation
% over every indexed pixel.
%
% Syntax
%   reconstructPos = latticeModel(pos,ij,isIndexed,dxy)
%   [reconstructPos,idealFun] = latticeModel(pos,ij,isIndexed,dxy)
%
% Input
%  pos       - nEbsd x 2 measured positions (map plane only)
%  ij        - nEbsd x 2 integer lattice index, from ebsd.lattice
%  isIndexed - nEbsd x 1 logical, which rows carry a real measurement
%  dxy       - representative grid spacing, from ebsd.lattice
%
% Output
%  reconstructPos - @(IJ) m x 2 positions for any integer index IJ
%  idealFun       - @(IJ) the affine part alone, without the deformation
%                   correction. spatialDecompositionAlpha wants it for the
%                   dummy ring, where a regular polygon is the point and
%                   following the local distortion would only roughen it.
%  isRigid        - whether the affine fit alone was used
%
% Note calcMesh solves the same problem but is deliberately NOT routed
% through here: it works in 3d (it carries a z interpolant), it materialises
% the whole mesh instead of returning a closure, and it scales its rigidity
% test by mean(norm(unitCell)) where this one uses dxy. Sharing the code
% would mean changing one of the two criteria.
%
% See also
% EBSD/lattice EBSD/private/calcMesh

% scatteredInterpolant requires double; ij/pos can come in as single
% (e.g. real imported EBSD data)
Iidx = double(ij(isIndexed,1)); Jidx = double(ij(isIndexed,2));
posIdx = double(pos(isIndexed,:));
idealFit  = [ones(numel(Iidx),1), Iidx, Jidx] \ posIdx;
idealFun  = @(IJ) [ones(size(IJ,1),1), double(IJ)] * idealFit;
defXY     = posIdx - idealFun([Iidx, Jidx]);

% same check calcMesh uses to decide whether its ideal grid is "sufficiently
% good"; only genuinely distorted grids fall through to the slower route
isRigid = mean(vecnorm(defXY,2,2)) / dxy < 1e-2;

if isRigid
  reconstructPos = @(IJ) idealFun(IJ);
else
  Fx = scatteredInterpolant(Iidx, Jidx, defXY(:,1), 'natural', 'nearest');
  Fy = scatteredInterpolant(Iidx, Jidx, defXY(:,2), 'natural', 'nearest');
  % reshape guards against scatteredInterpolant returning 0x0 (not 0x1) for
  % an empty query, which would otherwise break the '+' below
  reconstructPos = @(IJ) idealFun(IJ) + ...
    [reshape(Fx(double(IJ(:,1)),double(IJ(:,2))),[],1), reshape(Fy(double(IJ(:,1)),double(IJ(:,2))),[],1)];
end

end
