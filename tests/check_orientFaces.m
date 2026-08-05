function check_orientFaces
% check that grain3d/orientFaces orients all boundary faces outwards
%
% The Dream3d data set is a dense tessellation of a cube, hence after
% orienting all faces every grain has a positive volume and the volumes sum
% up to the volume of the cube.

fname = fullfile(mtexDataPath,'EBSD','SmallIN100_MeshStats.dream3d');
grains = grain3d.load(fname);

I_GF0 = grains.I_GF;
grains = grains.orientFaces;
I_GF = grains.I_GF;

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

disp('check_orientFaces: ok')

end
