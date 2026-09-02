function check_boundary3d
% smoothing, coarsening and refining the boundary surfaces of 3d grains
%
% On the synthetic volume of buildBlockVolume: five planted grains, a
% notIndexed block and a two voxel grain. Every operation has to leave the
% surfaces closed, so the volumes still follow from the divergence theorem,
% and has to keep the junctions of the boundary network.
%
% See also
% grain3d/smoothBoundary grain3d/reduceBoundary grain3d/refineBoundary check_calcGrains3d

cs = crystalSymmetry('432','mineral','test');
sz = [12 10 8];
dxyz = [0.5 0.5 1];
box = prod(sz) * prod(dxyz);

ebsd = buildBlockVolume(cs,sz,dxyz);
grains = calcGrains(ebsd,'angle',5*degree);
t = nodeType(grains.boundary);
vol = grains.volume;

assert(all(ismember(unique(t),[0 2:8 11:18])),'node types')
assert(nnz(mod(t,10) >= 4) > 0 && nnz(t >= 10) > 0,'quadruple points and hull vertices exist')

%% refine: four times the faces, nothing else changes
grainsR = refineBoundary(grains);
assert(length(grainsR.boundary) == 4*length(grains.boundary),'four faces per face')
assert(max(abs(grainsR.volume - vol)) < 1e-10,'refine keeps the volumes')
assert(abs(sum(grainsR.boundary.area) - sum(grains.boundary.area)) < 1e-10,'refine keeps the areas')
tR = nodeType(grainsR.boundary);
assert(isequal(tR(1:numel(t)),t),'refine keeps the node types of the old vertices')
checkClosed(grainsR)

%% reduce: fewer faces, closed surfaces, the junctions survive
for flag = {{},{'quadric'}}
  grainsC = reduceBoundary(grains,2,flag{1}{:});
  assert(length(grainsC.boundary) < 0.7*length(grains.boundary),'reduce drops faces')
  checkClosed(grainsC)
  assert(abs(sum(grainsC.volume) - box) < 1e-8,'reduce keeps the hull')
  assert(isequal(tripleLines(grains),tripleLines(grainsC)),'reduce keeps the triple lines')
  tC = nodeType(grainsC.boundary);
  assert(all(ismember(tC(tC>0),t)),'reduce keeps the node types')
  vC = grainsC.volume;
  assert(all(vC(grains.numPixel > 20) > 0.5*vol(grains.numPixel > 20)),'large grains keep their volume')
end

%% smooth: vertices move, faces stay, junctions and hull stay
V0 = grains.allV.xyz;
filters = {laplaceFilter(10),taubinFilter(10),curvatureFilter,huberFilter};
for k = 1:numel(filters)
  grainsS = smoothBoundary(grains,filters{k});
  V = grainsS.allV.xyz;
  assert(isequal(grainsS.boundary.F,grains.boundary.F),'smoothing keeps the faces')
  isPinned = mod(t,10) >= 4 | t >= 10;
  assert(max(abs(V(isPinned,:) - V0(isPinned,:)),[],'all') == 0,'quadruple points and hull stay')
  assert(max(abs(V(~isPinned & t > 0,:) - V0(~isPinned & t > 0,:)),[],'all') > 0.01,'the surface moved')
  assert(abs(sum(grainsS.volume) - box) < 1e-8,'the total volume is conserved')
  checkClosed(grainsS)
end

% the schemes: a coupled run moves the triple lines with the faces
grainsH = smoothBoundary(grains,10);
grainsCo = smoothBoundary(grains,10,'scheme','coupled');
isTL = mod(t,10) == 3 & t < 10;
VCo = grainsCo.allV.xyz; VH = grainsH.allV.xyz;
assert(max(abs(VCo(isTL,:) - VH(isTL,:)),[],'all') > 1e-3,'the schemes differ on the triple lines')
grainsF = smoothBoundary(grains,10,'fixTripleLines'); VF = grainsF.allV.xyz;
assert(isequal(VF(isTL,:),V0(isTL,:)),'fixTripleLines pins them')

% Taubin keeps the volumes where Laplace shrinks them
big = grains.numPixel > 20;
grainsL = smoothBoundary(grains,laplaceFilter(25)); vL = grainsL.volume;
grainsT = smoothBoundary(grains,taubinFilter(25)); vT = grainsT.volume;
assert(max(abs(vT(big) - vol(big)) ./ vol(big)) < 0.05,'Taubin keeps the volumes')
assert(max(abs(vL(big) - vol(big)) ./ vol(big)) > max(abs(vT(big) - vol(big)) ./ vol(big)),'Laplace moves more volume')

% the displacement bound and the hull
grainsD = smoothBoundary(grains,laplaceFilter(25),'maxDisplacement',0.1); VD = grainsD.allV.xyz;
assert(max(abs(VD - V0),[],'all') <= 0.1 + 1e-12,'maxDisplacement holds')
grainsO = smoothBoundary(grains,10,'moveOuterBoundary'); VO = grainsO.allV.xyz;
assert(max(abs(VO(t >= 10,:) - V0(t >= 10,:)),[],'all') > 0.01,'moveOuterBoundary moves the hull')

disp('check_boundary3d: passed');

end

function checkClosed(grains)
% every inner face is shared with opposite sign, so the volumes are positive
% and add up to the box

I_GF = grains.I_GF;
assert(all(abs(nonzeros(I_GF)) == 1),'I_GF entries are signs')
vol = grains.volume;
assert(all(vol(vol ~= 0) > 0),'volumes are positive')
inner = all(grains.boundary.grainId > 0,2);
assert(all(sum(I_GF(:,inner),1) == 0),'inner faces cancel')

end

function T = tripleLines(grains)
% the sorted grain triples meeting along the triple lines

gB = grains.boundary;
[~,F2E] = edges(gB);
isTL = accumarray(F2E(:),1) >= 3;
g = gB.grainId; g(g == 0) = max(g(:)) + 1;
I_EG = sparse(repmat(F2E(:),2,1),[repmat(g(:,1),3,1); repmat(g(:,2),3,1)],1);
T = unique(full(I_EG(isTL,:) > 0),'rows');

end
