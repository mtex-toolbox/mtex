function  grains = loadGrains_Dream3d(fname)
% Hard coded paths 
% (for FileVersion '8.0')
% fname = "SmallIN100_MeshStats.dream3d";
Vpath = '/DataStructure/TriangleDataContainer/SharedVertexList';
polyPath = '/DataStructure/TriangleDataContainer/SharedTriList';
GrainIdPath = '/DataStructure/TriangleDataContainer/FaceData/FaceLabels';
activePath = '/DataStructure/DataContainer/CellFeatureData/Active';
QuatsPath = '/DataStructure/DataContainer/CellFeatureData/AvgQuats';
phasePath = '/DataStructure/DataContainer/CellFeatureData/Phases';
crysmPath = '/DataStructure/DataContainer/CellEnsembleData/CrystalStructures';

%%

activeGrains = logical(h5read(fname, activePath))';

abcd = h5read(fname, QuatsPath)';
q = quaternion(abcd(activeGrains,:)').';

% import crystal symmetry - can we get some more information here?
dream3dCS = {'622','432','6','23','1','121','222','4','422','3','322','1'};
crysm = h5read(fname,crysmPath);
csList = repcell('notIndexed',1,length(crysm));
for k = 1:length(crysm)
  if crysm(k) > 0 && crysm(k) <= length(dream3dCS)
    csList{k} = crystalSymmetry(dream3dCS{crysm(k)},'mineral','unknown');
  end
end

phaseList = h5read(fname,phasePath)' + 1;
phaseList = phaseList(activeGrains,:);

V = double(h5read(fname,Vpath)');

poly = h5read(fname,polyPath)';
poly = poly + 1;    % because dream3d indexes with 0 (see '_VertexIndices')

GrainIds = h5read(fname,GrainIdPath)';

% calculate I_CF
isPos = GrainIds(:,2) > 0;
isNeg = GrainIds(:,1) > 0;

cIds = [GrainIds(isNeg,1);GrainIds(isPos,2)];
fIds = int32([find(isNeg);find(isPos)]);
Ndir = [ones(nnz(isNeg),1);-ones(nnz(isPos),1)];

I_CF = sparse(cIds,fIds,Ndir,max(GrainIds(:)),length(GrainIds));
  
grains = grain3d(V,poly,I_CF,q,csList,phaseList);
