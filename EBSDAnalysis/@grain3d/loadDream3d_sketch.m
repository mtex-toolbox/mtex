function  grains = loadDream3d_sketch(fname)
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

crysm = h5read(fname,crysmPath);      % not helpful
csList = {'notIndexed',crystalSymmetry("432")};

phaseList = h5read(fname,phasePath)' + 1;
phaseList = phaseList(activeGrains,:);

V = h5read(fname,Vpath)';

poly = h5read(fname,polyPath)';
poly = poly + 1;    % because dream3d indexes with 0 (see '_VertexIndices')
% make poly cell array (necessary so for grain3d functions far)
poly = mat2cell(poly,ones(length(poly),1),3);

GrainIds = h5read(fname,GrainIdPath)';

% calculate I_CF - extremely expensive
isPos = GrainIds(:,2) > 0;
isNeg = GrainIds(:,1) > 0;

cIds = [GrainIds(isNeg,1);GrainIds(isPos,2)];
fIds = int32([find(isNeg);find(isPos)]);
Ndir = [ones(nnz(isNeg),1);-ones(nnz(isPos),1)];

I_CF = sparse(cIds,fIds,Ndir,max(GrainIds(:)),length(GrainIds));
  
grains = grain3d(V,poly,I_CF,q,csList,phaseList);
