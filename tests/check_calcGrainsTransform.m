function check_calcGrainsTransform
% regression test: calcGrains commutes with a non-rigid EBSD/transform
%
% covers a bug in spatialDecompositionGrid's private cells2posId helper:
% it used to place the synthetic position of every grid cell with no real
% measurement (notIndexed holes, the exterior dummy ring, filled small
% gaps) via a single RIGID affine reconstruction ij*A' + origin, instead of
% the true measured position (when a real ebsd row exists there) or a
% locally interpolated deformation model (otherwise). Under a smooth
% non-rigid distortion (e.g. a trapezoidal stage drift, see EBSD/transform)
% the rigid reconstruction disagreed with where a genuinely measured pixel
% at that index would sit, shifting Voronoi boundaries near every hole and
% the whole map edge and manufacturing spurious extra grains.
%
% calcGrains on a transformed EBSD map should agree with transforming the
% grains reconstructed from the untransformed map (see grain2d/transform).

cs = crystalSymmetry('1','mineral','test');

% 4x4 grid of 6x6-pixel blocks -> 16 grains, well above the misorientation
% threshold; punch a few notIndexed holes and crop a corner to also exercise
% the exterior dummy ring / map edge
blk = 6;
n = 4*blk;
blockId = kron(reshape(1:16,4,4),ones(blk));

oris = orientation.byAxisAngle(zvector,(1:16)*7*degree,cs);

rot = rotation.id(n,n);
for k = 1:16
  rot(blockId==k) = oris(k);
end

phaseId = ones(n,n) + 1; % phase 2 = indexed, phase 1 = notIndexed
phaseId(8,8)   = 1;
phaseId(15,20) = 1;
phaseId(22,10) = 1;
phaseId(1:3,1:3) = 1; % crop a corner -> exercises the map edge / dummy ring

ebsd = EBSDsquare([],rot,phaseId, ...
  [0 1],{'notIndexed',cs},'dxy',[1 1]);

thr = 5*degree;
grains0 = calcGrains(ebsd,'threshold',thr);

% trapezoidal stage-drift-like distortion, as in check_gridDistortionBenchmark.
% 0.02 is already a realistic-to-severe stage drift (2% x-scaling at the
% outermost rows); it clearly separates the fixed local-deformation
% reconstruction (relErr ~ 0.001) from the old rigid-affine one
% (relErr ~ 0.01, an order of magnitude worse) without running into the
% unrelated topology effects (grains merging/splitting differently) that
% dominate at more extreme distortion levels.
x = ebsd.pos.x(:); xCenter = (min(x)+max(x))/2;
y = ebsd.pos.y(:); yCenter = (min(y)+max(y))/2; yHalf = (max(y)-min(y))/2;
trapFrac = 0.02;
distort = @(pos) vector3d( ...
  xCenter + (pos.x-xCenter) .* (1 + trapFrac*(pos.y-yCenter)/yHalf), ...
  pos.y, pos.z);

ebsdT      = transform(ebsd, distort);
grainsT    = calcGrains(ebsdT,'threshold',thr);
grains0T   = transform(grains0, distort);

if length(grainsT) ~= length(grains0T)
  error(['calcGrains on a transformed map does not agree with transforming ' ...
    'the grains from the untransformed map: expected %d grains, got %d ' ...
    '(spurious/missing grains near holes or the map edge)'], ...
    length(grains0T), length(grainsT));
end

areaT  = sort(area(grainsT));
area0T = sort(area(grains0T));
relErr = max(abs(areaT - area0T) ./ area0T);

if relErr > 5e-3
  error(['calcGrains on a transformed map disagrees with transforming the ' ...
    'grains from the untransformed map beyond tolerance: max relative area ' ...
    'error %.4f (expected < 0.005)'], relErr);
end

disp('calcGrains transform commutation: all checks passed');

end
