function csList = dream3dCrystalSymmetry(fname,crysm,ds)
% crystal symmetries of the phases a DREAM.3D file declares
%
% Input
%  fname - file name
%  crysm - path of the data set CrystalStructures
%  ds    - paths of all data sets of the file, see dream3dDatasets
%
% Output
%  csList - list of @crystalSymmetry, notIndexed for the first entry and
%  for unknown structures
%
% Description
% The CrystalStructures enumeration gives the point group. The data sets
% MaterialName and LatticeConstants beside it, where the file has them,
% give the mineral and the cell (a, b, c, alpha, beta, gamma in degrees);
% a blank name is 'unknown', a cell of zeros the default one. DREAM.3D puts
% the a axis of a hexagonal or trigonal cell along x: the voxels its IPF
% colours green, which its key labels <2-1-10>, lie 6.6 degrees from
% <2-1-10> with X||a and 28 degrees with X||a*. Phases of one name take a
% letter each, see ensureCSArray.

% the list is indexed by the zero based enumeration
dream3dCS = {'622','432','6','23','1','121','222','4','422','3','322','1'};
xParallelA = [true false true false false false false false false true true false];

structures = double(h5read(fname,crysm));
structures = structures(:);

% the names and the cells beside the crystal structures
ensemble = ds(startsWith(ds,fileparts(crysm) + "/"));
names = ensemble(endsWith(ensemble,"/" + ["MaterialName","Material Name","PhaseName","Phase Name"]));
materials = {};
if ~isempty(names)
  materials = cellstr(string(h5read(fname,names(1))));
end
cells = ensemble(endsWith(ensemble,"/" + ["LatticeConstants","Lattice Constants"]));
lattice = [];
if ~isempty(cells)
  lattice = double(h5read(fname,cells(1)));
  if size(lattice,1) ~= 6, lattice = lattice.'; end
end

csList = repmat(notIndexed,1,numel(structures));
for k = 2:numel(structures)
  s = structures(k);
  if s < 0 || s >= numel(dream3dCS), continue; end
  mineral = 'unknown';
  if k <= numel(materials) && strlength(strtrim(materials{k})) > 0
    mineral = char(strtrim(materials{k}));
  end
  args = {};
  if size(lattice,2) >= k && all(lattice(:,k) > 0)
    args = {lattice(1:3,k).',lattice(4:6,k).'*degree};
  end
  if xParallelA(s+1), args = [args,{'X||a'}]; end %#ok<AGROW>
  csList(k) = crystalSymmetry(dream3dCS{s+1},args{:},'mineral',mineral);
end
csList = ensureCSArray(csList);
