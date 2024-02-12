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

Quaternions = h5read(fname, QuatsPath)';
Quaternions = quaternion(Quaternions(activeGrains,:)').';

crysm = h5read(fname,crysmPath);      % not helpful
cs = {'notIndexed',crystalSymmetry("1")};

phaseList = h5read(fname,phasePath)' + 1;
phaseList = phaseList(activeGrains,:);

V = h5read(fname,Vpath)';

poly = h5read(fname,polyPath)';
poly = poly + 1;    % because dream3d indexes with 0 (see '_VertexIndices')
% make poly cell array (necessary so for grain3d functions far)
poly = mat2cell(poly,ones(length(poly),1),3);

GrainIds = h5read(fname,GrainIdPath)';

% calculate I_CF - extremly expensive
I_CF = sparse(max(GrainIds,[],'all'),length(GrainIds));
ind=sub2ind(size(I_CF),GrainIds(GrainIds(:,1)>0,1),find(GrainIds(:,1)>0));
I_CF(ind) = -1;
ind = sub2ind(size(I_CF),GrainIds(GrainIds(:,2)>0,2),find(GrainIds(:,2)>0));
I_CF(ind) = 1;
  
grains = grain3d(V,poly,I_CF,Quaternions,{'notIndexed',cs},phaseList)
