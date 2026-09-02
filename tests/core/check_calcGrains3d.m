function check_calcGrains3d
% grain reconstruction from 3d voxel data, on a synthetic 12 x 10 x 8 volume
%
% Five indexed grains of planted orientation, a notIndexed block and a two
% voxel grain, so that counts, volumes, the closed triangle surface, the
% boundary voxel pairs, the misorientations and minPixel all have known
% answers. Takes well under a second.
%
% See also
% EBSD3square/calcGrains check_calcGrainsCases check_orientFaces

cs = crystalSymmetry('432','mineral','test');
sz = [12 10 8];
dxyz = [0.5 0.5 1];

[ebsd,numTrue] = buildBlockVolume(cs,sz,dxyz);
[grains,ebsd] = calcGrains(ebsd,'angle',5*degree);

assert(length(grains) == 6, 'expected 6 grains, got %d',length(grains))
assert(isequal(sort(grains.numPixel),sort(numTrue)),'voxel counts per grain')
assert(nnz(~grains.isIndexed) == 1 && grains('notIndexed').numPixel == 27,'notIndexed grain')
assert(isequal(size(ebsd.grainId),sz),'grainId keeps the array shape')
assert(isequal(accumarray(ebsd.grainId(:),1),grains.numPixel),'grainId agrees with numPixel')

checkSurface(grains,sz,dxyz)
checkBoundary(grains,ebsd,sz)

% orientations are recovered exactly, so the spread vanishes
assert(all(grains.prop.GOS < 1e-10),'GOS of a uniform grain')

% minPixel folds the two voxel grain into a notIndexed one of its own
[grains3,ebsd3] = calcGrains(ebsd,'angle',5*degree,'minPixel',3);
assert(nnz(grains3.isIndexed) == 4,'minPixel leaves 4 indexed grains')
assert(sum(grains3('notIndexed').numPixel) == 29,'culled voxels are notIndexed')
assert(nnz(~ebsd3.isIndexed) == 29,'culled voxels are notIndexed in the map')
checkSurface(grains3,sz,dxyz)

% the stored grainId gives the same grains back, up to their numbering
grainsId = calcGrains(ebsd,'grainId');
assert(isequal(sort(grainsId.numPixel),sort(grains.numPixel)),'grains from grainId')
assert(isequal(sort(grainsId.volume),sort(grains.volume)),'volumes from grainId')

% the other criteria take the same route
grainsSoft = calcGrains(ebsd,'soft',[5 1]*degree);
assert(length(grainsSoft) == 6,'soft criterion')
grainsMCL = calcGrains(ebsd,'angle',5*degree,'mcl');
assert(sum(grainsMCL.numPixel) == prod(sz),'mcl covers every voxel')

% a rotated grid gives the same volumes at rotated positions
rot = rotation.byAxisAngle(vector3d(1,2,3),40*degree);
grainsRot = calcGrains(rotate(ebsd,rot),'angle',5*degree);
assert(max(abs(grainsRot.volume - grains.volume)) < 1e-8,'volumes under rotation')
assert(max(norm(grainsRot.centroid - rot.*grains.centroid)) < 1e-8,'centroids under rotation')

% a left handed grid still closes every grain with outward normals
ebsdL = buildBlockVolume(cs,sz,dxyz .* [1 1 -1]);
grainsL = calcGrains(ebsdL,'angle',5*degree);
assert(max(abs(sort(grainsL.volume) - sort(grains.volume))) < 1e-8,'volumes on a left handed grid')
checkSurface(grainsL,sz,dxyz)

disp('check_calcGrains3d: passed');

end

function [ebsd,numTrue] = buildBlockVolume(cs,sz,dxyz)
% five blocks of planted orientation and a notIndexed corner

ang = zeros(sz);
ang(7:end,1:5,:) = 10;
ang(7:end,6:end,1:5) = 20;
ang(7:end,6:end,6:end) = 30;
ang(10:11,2,2) = 35;
rot = reshape(rotation.byAxisAngle(zvector,ang(:)*degree),sz);

phaseId = 2*ones(sz);
phaseId(1:3,1:3,1:3) = 1;

numTrue = [prod(sz(1:3))/2-27; 27; 6*5*8-2; 2; 6*5*5; 6*5*3];
ebsd = EBSD3square([],rot,phaseId,[0;1],{'notIndexed',cs},dxyz);

end

function checkSurface(grains,sz,dxyz)
% closed, consistently oriented triangle surface

I_GF = grains.I_GF;
assert(all(abs(nonzeros(I_GF)) == 1),'I_GF entries are signs')
assert(all(sum(I_GF ~= 0,1) <= 2),'a face has at most two grains')

isHull = full(sum(I_GF,1)).' ~= 0;
assert(nnz(isHull) == 4*(sz(1)*sz(2)+sz(2)*sz(3)+sz(1)*sz(3)),'hull triangle count')

vol = grains.volume;
assert(max(abs(vol - grains.numPixel*prod(abs(dxyz)))) < 1e-8,'volume equals voxel count')
assert(abs(sum(vol) - prod(sz)*prod(abs(dxyz))) < 1e-8,'volumes fill the box')

end

function checkBoundary(grains,ebsd,sz)
% every inner face separates two 6-neighbours of different grains and
% carries their misorientation

gB = grains.boundary;
isInner = all(gB.ebsdId > 0,2);
assert(all(gB.grainId(isInner,1) ~= gB.grainId(isInner,2)),'inner faces separate grains')
assert(all(~isInner == (gB.grainId(:,2) == 0)),'hull faces have one grain')

step = abs(diff(gB.ebsdId(isInner,:),1,2));
assert(all(ismember(step,[1 sz(1) sz(1)*sz(2)])),'faces sit between 6-neighbours')

gid = ebsd.grainId(gB.ebsdId(isInner,:));
assert(isequal(gid,gB.grainId(isInner,:)),'ebsdId and grainId agree')

isIdx = isInner & all(gB.isIndexed,2);
planted = angle(grains.meanOrientation(gB.grainId(isIdx,1)),grains.meanOrientation(gB.grainId(isIdx,2)));
assert(max(abs(gB.misorientation(isIdx).angle - planted)) < 1e-8,'misorientation across the face')

end
