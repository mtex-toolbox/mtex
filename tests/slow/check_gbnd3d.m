function check_gbnd3d
% the 3d grain boundary normal distribution
%
% @grain3Boundary/calcGBND is a distinct implementation from the 2d
% @grainBoundary one, not a generalisation of it - see EBSDAnalysis/CLAUDE.md
% - and it had no test. Its 2d counterpart is core/check_gbnd; this one is in
% slow/ because it needs the 169 MB SmallIN100_MeshStats.dream3d.
%
% The two differ in a way worth knowing. In crystal coordinates the 3d
% version returns an S2FunHarmonicSym and is exactly symmetric under the
% crystal group - measured 1.85e-11 over all 24 rotations of 432. The 2d
% version returns a plain S2FunHarmonic with a crystalSymmetry merely
% attached, because it builds the density with 'noSymmetry', and evaluating
% it at symmetrically equivalent directions differs by more than the function
% varies. So symmetry is asserted here and deliberately not there.
%
% See also
% grain3Boundary/calcGBND grainBoundary/calcGBND check_gbnd check_orientFaces

fname = fullfile(mtexDataPath,'EBSD','SmallIN100_MeshStats.dream3d');

% skip rather than hard fail: it is an LFS asset, so a clone without LFS
% pulled would otherwise die inside HDF5. Same guard as check_orientFaces.
if ~isfile(fname)
  fprintf(['check_gbnd3d: %s is not present, skipping.\n' ...
    '  It is an LFS asset - run "git lfs pull" to fetch it.\n'], fname);
  return
end

[grains,gB] = loadInnerBoundary(fname);

specimen = checkSpecimenForm(gB);
crystal  = checkCrystalForm(gB,grains);
checkTheTwoFramesDiffer(specimen,crystal);
checkGBCD(gB,grains,crystal);

disp('check_gbnd3d: passed');

end

% =========================================================================
function [grains,gB] = loadInnerBoundary(fname)

grains = grain3d.load(fname);
gB = grains.boundary;

% only the faces between two grains of the phase - the outer hull faces sit
% against phase 0 and carry no misorientation
inner = all(gB.phaseId == 2,2);
gB = gB(inner);

assert(length(grains) == 794, ...
  'check_gbnd3d: expected 794 grains, got %d', length(grains))
assert(nnz(inner) == 637564, ...
  'check_gbnd3d: expected 637564 inner faces, got %d', nnz(inner))

end

% =========================================================================
function gbnd = checkSpecimenForm(gB)
% calcGBND(gB3) alone gives the distribution in SPECIMEN coordinates, so it
% carries a specimenSymmetry rather than a crystal one

gbnd = calcGBND(gB);

assert(isa(gbnd,'S2FunHarmonic'), ...
  'check_gbnd3d: the specimen form returned a %s', class(gbnd))
assert(isa(gbnd.CS,'specimenSymmetry'), ...
  'check_gbnd3d: the specimen form carries a %s, expected a specimenSymmetry', ...
  class(gbnd.CS))

checkIsADensity(gbnd,'specimen frame');

% this dataset has a clearly anisotropic boundary population in the specimen
% frame, so a uniform result would mean nothing was measured
assert(max(gbnd) > 1.3 && min(gbnd) < 0.8, ...
  ['check_gbnd3d: the specimen frame GBND is nearly uniform (%.4f .. %.4f), ' ...
   'so the estimate is not picking up the boundary population'], ...
  min(gbnd), max(gbnd))

end

% =========================================================================
function gbnd = checkCrystalForm(gB,grains)
% calcGBND(gB3,grains) gives it in CRYSTAL coordinates, and that one really
% is symmetrised

gbnd = calcGBND(gB,grains);

assert(isa(gbnd,'S2FunHarmonicSym'), ...
  ['check_gbnd3d: the crystal form returned a %s - it is expected to be an ' ...
   'S2FunHarmonicSym, i.e. symmetrised rather than merely carrying a symmetry'], ...
  class(gbnd))
assert(isa(gbnd.CS,'crystalSymmetry'), ...
  'check_gbnd3d: the crystal form carries a %s, expected a crystalSymmetry', ...
  class(gbnd.CS))

checkIsADensity(gbnd,'crystal frame');

% the symmetry has to hold on evaluation - the function only varies by 7% here
rots = gbnd.CS.rot;
v = vector3d.rand(100);
ref = gbnd.eval(v);

worst = 0;
for k = 1:length(rots)
  worst = max(worst, max(abs(gbnd.eval(rots(k)*v) - ref)));
end

assert(worst < 1e-9, ...
  ['check_gbnd3d: the crystal frame GBND is not symmetric under its own ' ...
   'crystal group - max deviation %.3g over %d rotations, while the whole ' ...
   'function only spans %.4f'], worst, length(rots), max(gbnd)-min(gbnd))

end

% =========================================================================
function checkTheTwoFramesDiffer(specimen,crystal)
% the same boundaries in two frames must not give the same distribution -
% if they did, one of the two rotations into frame is not being applied

assert(max(specimen)-min(specimen) > 5*(max(crystal)-min(crystal)), ...
  ['check_gbnd3d: the specimen and crystal frame distributions have similar ' ...
   'spread (%.4f vs %.4f) - the rotation into the crystal frame may not be ' ...
   'happening'], max(specimen)-min(specimen), max(crystal)-min(crystal))

end

% =========================================================================
function checkGBCD(gB,grains,gbnd)
% restricted to one misorientation, calcGBND is the GBCD
%
% Sigma 3 in a cubic material - a 60 degree rotation about <111>, the
% coherent twin - is the case with a real preferred boundary plane, so it has
% to come out sharper than the GBND over all boundaries.

cs = grains.CS;
mori = orientation.byAxisAngle(Miller(1,1,1,cs),60*degree,cs,cs);

gbcd = calcGBND(gB,grains,mori);

checkIsADensity(gbcd,'GBCD for sigma 3');

assert(max(gbcd) > max(gbnd), ...
  ['check_gbnd3d: the sigma 3 GBCD (max %.4f) is no sharper than the GBND ' ...
   'over all boundaries (max %.4f) - the misorientation restriction is not ' ...
   'selecting anything'], max(gbcd), max(gbnd))

end

% =========================================================================
function checkIsADensity(gbnd,what)
% a distribution of normals is a density on the sphere, so its mean is 1

m = mean(gbnd);
assert(abs(m - 1) < 1e-3, ...
  'check_gbnd3d: the GBND in the %s has mean %.6f, a density must have mean 1', ...
  what, m)

end
