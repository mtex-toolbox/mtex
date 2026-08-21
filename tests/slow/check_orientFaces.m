function check_orientFaces
% check that grain3d/orientFaces orients all boundary faces outwards
%
% The Dream3d data set is a dense tessellation of a cube, hence after
% orienting all faces every grain has a positive volume and the volumes sum
% up to the volume of the cube.

fname = fullfile(mtexDataPath,'EBSD','SmallIN100_MeshStats.dream3d');

% skip rather than fail when the file is absent, it is a 176 MB LFS asset
if ~isfile(fname)
  fprintf(['check_orientFaces: %s is not present, skipping.\n' ...
    '  It is an LFS asset - run "git lfs pull" to fetch it.\n'], fname);
  return
end

% the raw winding stored by Dream3d is arbitrary
grainsRaw = grain3d.load(fname,'noOrientFaces');

% grain3d.load orients the faces itself, so the result must already satisfy
% every check below without an explicit call
grains = grain3d.load(fname);

I_GF0 = grainsRaw.I_GF;
I_GF = grains.I_GF;

% the import really did something - otherwise the checks below would pass
% trivially and stop testing anything
if isequal(I_GF,I_GF0)
  error('grain3d.load did not orient the faces on import')
end

% orientFaces may only change the signs, not the incidence itself
if ~isequal(spones(I_GF),spones(I_GF0))
  error('orientFaces changed the grain - face incidence')
end
if ~all(abs(nonzeros(I_GF)) == 1)
  error('I_GF contains entries different from +-1')
end

% all normals point outwards, hence all volumes are positive
vol = grains.volume;
if any(vol <= 0)
  error('%d grains ended up with a non positive volume',nnz(vol <= 0))
end

% the grains tile the entire box
ext = grains.extent;
boxVol = (ext(2)-ext(1)) * (ext(4)-ext(3)) * (ext(6)-ext(5));
if abs(sum(vol) - boxVol) > 1e-6 * boxVol
  error('the total grain volume is %g instead of %g',sum(vol),boxVol)
end

% the two grains adjacent to an inner face must see opposite normals
isInner = full(sum(I_GF~=0,1)) == 2;
badFaces = nnz(full(sum(I_GF(:,isInner),1)) ~= 0);
if badFaces > 0
  error('%d inner faces are not oriented consistently',badFaces)
end

% the face normal points from the first to the second grain
gId = zeros(size(I_GF,2),2);
[a,b] = find(I_GF == 1);  gId(b,1) = a;
[a,b] = find(I_GF == -1); gId(b,2) = a;
if ~isequal(gId,grains.boundary.grainId)
  error('boundary.grainId is not consistent with I_GF')
end

% orienting again must be a no-op - scripts written before grain3d.load did
% this itself still call orientFaces explicitly after loading
grains2 = grains.orientFaces;
if ~isequal(grains2.I_GF,I_GF) || ...
    ~isequal(grains2.boundary.grainId,grains.boundary.grainId)
  error('orientFaces is not idempotent')
end

disp('check_orientFaces: ok')

end
