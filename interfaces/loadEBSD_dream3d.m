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
% See also
% loadGrains_Dream3d EBSD3square EBSD3square/calcGrains

root = '/DataStructure/DataContainer';
cellData = [root '/CellData/'];

try
  sz     = double(h5readatt(fname,root,'_DIMENSIONS')).';
  dxyz   = double(h5readatt(fname,root,'_SPACING')).';
  origin = double(h5readatt(fname,root,'_ORIGIN')).';
  info   = h5info(fname,cellData);
catch
  interfaceError(fname);
end

% h5read returns the arrays with x running fastest, the ndgrid order
eul = double(h5read(fname,[cellData 'EulerAngles']));
rot = reshape(rotation.byEuler(eul(1,:).',eul(2,:).',eul(3,:).','ZXZ'),sz);

% phases count from zero, with the unmeasured voxels not indexed
phaseId = double(h5read(fname,[cellData 'Phases']));
phaseId = phaseId(:) + 1;
if any(strcmp({info.Datasets.Name},'Mask'))
  phaseId(~h5read(fname,[cellData 'Mask'])) = 1;
end

csList = get_option(varargin,'CS',...
  dream3dCrystalSymmetry(h5read(fname,[root '/CellEnsembleData/CrystalStructures'])));

% every other scalar cell array becomes a property, the feature ids the grainId
prop = struct;
for ds = info.Datasets.'
  data = h5read(fname,[cellData ds.Name]);
  if size(data,1) > 1 || any(strcmp(ds.Name,{'Phases','Mask'})), continue; end
  prop.(regexprep(ds.Name,{'FeatureIds','\s'},{'grainId',''})) = double(data(:));
end

[x,y,z] = ndgrid(origin(1) + (0:sz(1)-1)*dxyz(1), ...
  origin(2) + (0:sz(2)-1)*dxyz(2), origin(3) + (0:sz(3)-1)*dxyz(3));

ebsd = EBSD3square(vector3d(x,y,z),rot,phaseId,0:numel(csList)-1,csList,dxyz,'prop',prop);
ebsd.scanUnit = 'um';

end
