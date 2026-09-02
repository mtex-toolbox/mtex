function check_calcGrains3dData
% grain reconstruction from the voxel data of SmallIN100, scored against the
% grain ids DREAM.3D stored in the same file
%
% slow/ because it needs the 169 MB SmallIN100_MeshStats.dream3d. The
% synthetic counterpart is core/check_calcGrains3d.
%
% See also
% EBSD3square/calcGrains check_calcGrains3d check_gbnd3d

fname = fullfile(mtexDataPath,'EBSD','SmallIN100_MeshStats.dream3d');

% skip rather than hard fail: it is an LFS asset, so a clone without LFS
% pulled would otherwise die inside HDF5. Same guard as check_gbnd3d.
if ~isfile(fname)
  fprintf(['check_calcGrains3dData: %s is not present, skipping.\n' ...
    '  It is an LFS asset - run "git lfs pull" to fetch it.\n'], fname);
  return
end

ebsd = loadEBSD_dream3d(fname);
assert(isa(ebsd,'EBSD3square') && isequal(size(ebsd),[100 100 100]),'voxel grid')
assert(ebsd.hasGrainId,'the stored grain ids come along')
stored = ebsd.grainId;

[grains,ebsd] = calcGrains(ebsd,'angle',5*degree);

% the same partition as the file, up to a few fragments
C = accumarray([ebsd.grainId(:), stored(:)+1],1);
ari = adjustedRand(C);
assert(ari > 0.995,'adjusted Rand index against FeatureIds is %.4f',ari)
assert(abs(length(grains) - 794) <= 40,'%d grains against 794 features',length(grains))

% closed surfaces: the volumes fill the box
box = prod(size(ebsd)) * ebsd.dx * ebsd.dy * ebsd.dz;
assert(abs(sum(grains.volume) - box) < 1e-6 * box,'volumes fill the box')
assert(all(grains.volume > 0),'every volume is positive')

% the voxel surface has as many triangles as the mesh DREAM.3D built from it
assert(abs(numel(grains.boundary.id) - 757564) < 2000,'triangle count')

% the stored ids imported as grains
grainsId = calcGrains(ebsd,'grainId');
assert(abs(length(grainsId) - numel(unique(stored))) <= 20, ...
  '%d grains from %d stored ids',length(grainsId),numel(unique(stored)))
assert(abs(sum(grainsId.volume) - box) < 1e-6 * box,'volumes from grainId fill the box')

% the boundary operations stay in the budget of a few seconds each
tic; grainsC = reduceBoundary(grains,2,'quadric'); tC = toc;
tic; grainsS = smoothBoundary(grainsC,taubinFilter(10)); tS = toc;
assert(tC < 10 && tS < 10,'reduce %.1f s, smooth %.1f s',tC,tS)
assert(abs(sum(grainsS.volume) - box) < 1e-6 * box,'smoothing keeps the total volume')
assert(length(grainsC.boundary) < length(grains.boundary) / 2,'reduce halves the faces')

% the staircase normals sit on the axes, the smoothed ones do not
N = grainsS.boundary.N;
assert(mean(max(abs(N.xyz),[],2) > 0.999) < 0.5,'smoothed normals left the axes')

disp('check_calcGrains3dData: passed');

end
