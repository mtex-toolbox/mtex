function ebsd = rotationsInFileFrame(ebsd,varargin)
% the rotations of a map in the crystal frames a reader will build for it
%
% A file states the point group and the lattice of a phase but not the
% alignment of the Cartesian crystal axes, which its reader fixes: EDAX's
% for .ang, the default for .ctf. The rotations are re-expressed in that
% alignment, so the orientations survive the round trip.
%
% Syntax
%   ebsd = rotationsInFileFrame(ebsd,'EDAX')
%   ebsd = rotationsInFileFrame(ebsd)
%

for id = ebsd.indexedPhasesId

  cs = ebsd.CSList(id);
  % the lattice as the file states it, without the rounding noise of the
  % basis, which the checks for equal axes would not forgive
  abc = round([cs.aAxis.abs,cs.bAxis.abs,cs.cAxis.abs],10,'significant');
  abg = round([cs.alpha,cs.beta,cs.gamma],10,'significant');
  csFile = crystalSymmetry(cs.pointGroup,abc,abg,'mineral',cs.mineral,varargin{:});

  % the basis transformation from the map's frame into the file's
  M = transformationMatrix(cs,csFile);
  if norm(M - eye(3)) < 1e-10, continue; end

  ind = ebsd.phaseId == id;
  ebsd.rotations(ind) = ebsd.rotations(ind) .* rotation.byMatrix(M^-1);

end
