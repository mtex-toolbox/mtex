function  grains = loadGrains_Dream3d(fname)
% loadGrains_Dream3d is a method to load 3d grain data from dream3d
%
% Syntax
%   grains = grain3d.load('filepath/filename.dream3d','interface','dream3d)
%   grains = loadGrains_Dream3d('filepath/filename.dream3d')
%
% Input
%  fname     - filename
%
% Output
%  grain3d - @grain3d
%
% See also
% grain3d.load loadNeperTess

% Hard coded data paths 
% (for FileVersion '8.0')
%
% You can adapt the data paths by making them string arrays. The function
% will check them in the order of appearance until it finds something.
% example:
% Vpath = ["/DataStructure/TriangleDataContainer/SharedVertexList"; ...
%           "/DataStructure/AlternativeDataContainer/myVertices"];
%
Vpath = "/DataStructure/TriangleDataContainer/SharedVertexList";
polyPath = "/DataStructure/TriangleDataContainer/SharedTriList";
GrainIdPath = "/DataStructure/TriangleDataContainer/FaceData/FaceLabels";
activePath = "/DataStructure/DataContainer/CellFeatureData/Active";
QuatsPath = "/DataStructure/DataContainer/CellFeatureData/AvgQuats";
phasePath = "/DataStructure/DataContainer/CellFeatureData/Phases";
crysmPath = "/DataStructure/DataContainer/CellEnsembleData/CrystalStructures";

% check for grain data
try
  grainIds = h5read_multi(fname,GrainIdPath).';
catch
  error('The file does not contain any grain information.')
end

abcd = h5read_multi(fname, QuatsPath)';

try
  activeGrains = logical(h5read_multi(fname, activePath))';
catch ME
  activeGrains = true(size(abcd,1));
end

q = quaternion(abcd(activeGrains,:)').';

% import crystal symmetry - can we get some more information here?
dream3dCS = {'622','432','6','23','1','121','222','4','422','3','322','1'};
crysm = h5read_multi(fname,crysmPath);
csList = repcell('notIndexed',1,length(crysm));
for k = 1:length(crysm)
  if crysm(k) > 0 && crysm(k) <= length(dream3dCS)
    csList{k} = crystalSymmetry(dream3dCS{crysm(k)},'mineral','unknown');
  end
end

phaseList = h5read_multi(fname,phasePath)' + 1;
phaseList = phaseList(activeGrains,:);

V = double(h5read_multi(fname,Vpath)');

poly = h5read_multi(fname,polyPath)';
poly = poly + 1;    % because dream3d indexes with 0 (see '_VertexIndices')

% calculate I_CF
% grainIds is sorted so that grainIds(:,2) >= grainIds(:,1)>=0. That means
% for each grain in the first column (Id>0) the normal direction is
% positive
ind = grainIds(:,2)<grainIds(:,1);
if any(ind), grainIds(ind,:) = fliplr(grainIds(ind,:)); end

isPos = grainIds(:,2) > 0;
isNeg = grainIds(:,1) > 0;

cIds = [grainIds(isNeg,1);grainIds(isPos,2)];
fIds = int32([find(isNeg);find(isPos)]);
Ndir = [ones(nnz(isNeg),1);-ones(nnz(isPos),1)];

I_CF = sparse(cIds,fIds,Ndir,max(grainIds(:)),length(grainIds));
  
grains = grain3d(V,poly,I_CF,q,csList,phaseList);

warning(['Grains imported from Dream3d may not have set there normals consistently. ' ...
  'Please run <a href="matlab:grains=grains.orientFaces">grains=grains.orientFaces</a>']);

end

function out = h5read_multi(fname, datapath)
out = [];
for i = 1:numel(datapath)
  try
    out = h5read(fname,datapath(i));
    return
  catch e
    if ~any(regexp(e.identifier,'h5read'))
      rethrow(e)
    end
  end
end

if isempty(out)
  error(sprintf(['component or dataset not found.\n\n' ...
    'try h5info(fname) to get the structure of your file']))
end

end
