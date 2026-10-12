function  grains = loadGrains_Dream3d(fname,varargin)
% loadGrains_Dream3d is a method to load 3d grain data from dream3d
%
% Syntax
%   grains = grain3d.load('filepath/filename.dream3d','interface','dream3d')
%   grains = loadGrains_Dream3d('filepath/filename.dream3d')
%
%   % keep the face winding exactly as stored in the file
%   grains = grain3d.load('filepath/filename.dream3d','noOrientFaces')
%
% Input
%  fname     - filename
%
% Output
%  grain3d - @grain3d
%
% Options
%  noOrientFaces - do not orient the boundary faces after import
%
% Description
%
% Dream3d does not store the boundary faces of a grain with a consistent
% winding, i.e., the normals computed from the vertex order point randomly
% into or out of the grain. The faces are therefore oriented on import with
% <grain3d.orientFaces.html |orientFaces|>, so that face normals, grain
% volumes and |boundary.grainId| are meaningful right away. Pass the option
% |'noOrientFaces'| to get the raw winding as stored in the file.
%
% Files of DREAM3D-NX and of DREAM.3D 6 are read, whatever the data
% containers and their attribute matrices are called. A file without a
% surface mesh gives the grains of its voxel data, those that
% <EBSD3square.calcGrains.html |calcGrains|> forms from the feature ids.
%
% See also
% grain3d.load grain3d/orientFaces loadNeperTess loadEBSD_dream3d

ds = dream3dDatasets(fname);

% without a surface mesh the grains follow from the feature ids of the voxels
labels = ds(endsWith(ds,"/" + ["FaceData","Face Data"] + "/FaceLabels"));
if isempty(labels)
  grains = calcGrains(loadEBSD_dream3d(fname,varargin{:}),'grainId');
  return
end

% the triangle geometry is the data container of the face labels
in = @(list,name) list(endsWith(list,"/" + name));
mesh = ds(startsWith(ds,fileparts(fileparts(labels(1))) + "/"));
grainIds = h5read(fname,labels(1)).';
V = double(h5read(fname,in(mesh,"SharedVertexList")).');
poly = h5read(fname,in(mesh,"SharedTriList")).' + 1;

% the grain data are the attribute matrix of the mean orientations
ori = [in(ds,"AvgQuats"); in(ds,"AvgEulerAngles")];
assert(~isempty(ori),'The file does not contain any grain orientations.')
feature = ds(startsWith(ds,fileparts(ori(1)) + "/"));

if endsWith(ori(1),"AvgQuats")
  % the passive rotation as (x,y,z,w), its inverse is the rotation of the voxels
  xyzw = h5read(fname,ori(1)).';
  q = quaternion(xyzw(:,4),-xyzw(:,1),-xyzw(:,2),-xyzw(:,3));
else
  eul = double(h5read(fname,ori(1)));
  q = rotation.byEuler(eul(1,:).',eul(2,:).',eul(3,:).','ZXZ');
end

% the first feature is the one no voxel belongs to
q = q(2:end);
phaseList = double(h5read(fname,in(feature,"Phases")).') + 1;
phaseList = phaseList(2:end);

crysm = in(ds,"CrystalStructures");
csList = dream3dCrystalSymmetry(h5read(fname,crysm(1)));

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

% the winding of the stored faces is arbitrary, so the signs in I_CF above
% carry no geometric meaning yet - resolve them into genuine in/out normals
if ~check_option(varargin,'noOrientFaces')
  grains = grains.orientFaces;
end

end
