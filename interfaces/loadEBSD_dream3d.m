function ebsd = loadEBSD_dream3d(fname,varargin)
% import 3d EBSD voxel data from a DREAM.3D file
%
% Syntax
%   ebsd = loadEBSD_dream3d(fname)
%   ebsd = EBSD3.load(fname)
%
% Input
%  fname - file name
%
% Output
%  ebsd - @EBSD3square, every further scalar cell array of the file is a property
%
% Options
%  CS - list of @crystalSymmetry replacing the one read from the file
%
% Description
%
% Files of DREAM3D-NX and of DREAM.3D 6 are read, whatever the data
% container and its attribute matrices are called. The voxel data are the
% first attribute matrix with |EulerAngles|, |Quats| or |FeatureIds|, in
% this order. A file without orientations gives rotations that are NaN, a
% file without |Phases| a single phase.
%
% See also
% loadGrains_Dream3d EBSD3square EBSD3square/calcGrains

try
  ds = dream3dDatasets(fname);
  hit = [ds(endsWith(ds,"/EulerAngles")); ds(endsWith(ds,"/Quats")); ds(endsWith(ds,"/FeatureIds"))];
  cellData = fileparts(hit(1));
catch
  interfaceError(fname);
end
root = fileparts(cellData);
read = @(name) h5read(fname,cellData + "/" + name);
has  = @(name) any(ds == cellData + "/" + name);

% DREAM.3D 6 keeps the grid in data sets, DREAM3D-NX in attributes
if any(ds == root + "/_SIMPL_GEOMETRY/DIMENSIONS")
  geom = @(name) double(h5read(fname,root + "/_SIMPL_GEOMETRY/" + name)).';
else
  geom = @(name) double(h5readatt(fname,root,"_" + name)).';
end
sz = geom("DIMENSIONS"); dxyz = geom("SPACING"); origin = geom("ORIGIN");

% h5read returns the arrays with x running fastest, the ndgrid order
if has("EulerAngles")
  eul = double(read("EulerAngles"));
  rot = rotation.byEuler(eul(1,:).',eul(2,:).',eul(3,:).','ZXZ');
elseif has("Quats")
  % the passive rotation as (x,y,z,w)
  q = double(read("Quats"));
  rot = rotation(quaternion(q(4,:).',-q(1,:).',-q(2,:).',-q(3,:).'));
else
  rot = rotation.nan(prod(sz),1);
end
rot = reshape(rot,sz);

% phases count from zero, with the unmeasured voxels not indexed
phaseId = 2*ones(prod(sz),1);
if has("Phases"), phaseId = double(reshape(read("Phases"),[],1)) + 1; end
if has("Mask"), phaseId(~read("Mask")) = 1; end

crysm = ds(startsWith(ds,root + "/") & endsWith(ds,"/CrystalStructures"));
if isempty(crysm)
  csList = [notIndexed, crystalSymmetry];
else
  csList = dream3dCrystalSymmetry(h5read(fname,crysm(1)));
end
csList = get_option(varargin,'CS',csList);

% every other scalar cell array becomes a property, the feature ids the grainId
prop = struct;
for name = extractAfter(ds(startsWith(ds,cellData + "/")),cellData + "/").'
  nComp = h5info(fname,cellData + "/" + name).Dataspace.Size(1);
  if nComp > 1 || any(name == ["Phases","Mask"]), continue; end
  prop.(matlab.lang.makeValidName(replace(name,"FeatureIds","grainId"))) = double(reshape(read(name),[],1));
end

[x,y,z] = ndgrid(origin(1) + (0:sz(1)-1)*dxyz(1), ...
  origin(2) + (0:sz(2)-1)*dxyz(2), origin(3) + (0:sz(3)-1)*dxyz(3));

ebsd = EBSD3square(vector3d(x,y,z),rot,phaseId,0:numel(csList)-1,csList,dxyz,'prop',prop);
ebsd.scanUnit = 'um';

end
