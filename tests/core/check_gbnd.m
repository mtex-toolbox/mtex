function check_gbnd
% the grain boundary normal distribution, and the seam it sits behind
%
% Covers the last stage of the EBSD route - import, calcGrains,
% smoothBoundary, calcGBND - which had no test at all: the string calcGBND
% did not appear anywhere in tests/, in either its 2d
% (@grainBoundary/calcGBND) or its 3d (@grain3Boundary/calcGBND) form.
%
% The interesting part is the join between smoothing and GBND, which
% calcGBND's own help warns about: it looks the orientations on either side
% of a segment up through gB.ebsdId, and that is only meaningful while every
% segment still runs between one specific pair of pixels. smoothBoundary
% breaks that by default, because it simplifies and refines before smoothing.
%
% The failure mode is silent. On the map used here the default smoothing
% leaves the geometry alone - every segment keeps its direction to 0.000
% degree and its length - but rewrites ebsdId, and the GBND then moves by
% about 10 percent purely because segments are paired with the wrong
% orientations. Nothing errors and nothing warns.
%
% NB the result carries a crystalSymmetry but is NOT symmetric under it:
% calcGBND builds the density with 'noSymmetry' and then attaches cs to the
% harmonic. Measured deviation between f(v) and f(sym v) is 22.9 on a scale
% of 16.4, so symmetry is deliberately not asserted below.
%
% See also
% grainBoundary/calcGBND grain2d/smoothBoundary calcGBNDKernel

[ebsd,grains,gB] = routeFromFile('testdata_sqr.ctf');

% calcGBND costs about 2 s a call - a harmonic density estimate plus a
% convolution - and the import and calcGrains before it cost 0.13 s
% together. So the base distribution is computed ONCE here and passed to
% every check that needs it, rather than each recomputing its own.
ref = calcGBND(gB,ebsd);

checkIsADensity(ref,gB,grains);
checkNonneg(ref,gB,ebsd);
checkSmoothingSeam(ref,ebsd,grains,gB);

disp('check_gbnd: passed');

end

% =========================================================================
function [ebsd,grains,gB] = routeFromFile(name)
% the whole route in one place: file -> EBSD -> grains -> inner boundary
%
% Deliberately from a committed file rather than from mtexdata, so that this
% exercises the import stage too - the other tests in this route all start
% from a cached .mat.

f = fullfile(mtexDataPath,'EBSD',name);
assert(isfile(f),'check_gbnd: the sample file %s is missing',f)

evalc('ebsd = EBSD.load(f,''silent'');');
ebsd = ebsd('indexed');
grains = calcGrains(ebsd,'threshold',10*degree);

% calcGBND needs boundaries between one phase and itself - the outer
% boundary against notIndexed would trip its single-phase assertion
gB = grains.boundary('Glaucophane','Glaucophane');

assert(length(grains) == 4, ...
  'check_gbnd: expected 4 grains from %s, got %d', name, length(grains))
assert(size(gB.F,1) == 60, ...
  'check_gbnd: expected 60 inner boundary segments, got %d', size(gB.F,1))

end

% =========================================================================
function checkIsADensity(nE,gB,grains)
% a GBND is a density on the sphere, so its mean is 1 - in both the EBSD
% form and the grain2d form the help offers as the alternative

nG = calcGBND(gB,grains);

assert(isa(nE,'S2FunHarmonic'), ...
  'check_gbnd: calcGBND returned a %s, expected an S2FunHarmonic', class(nE))

% since ADR 0003 a plain S2Fun carries a reference frame instead of a
% symmetry - the GBND is deliberately not symmetrised, but it lives in
% the crystal frame
assert(isa(nE.frame,'crystalFrame'), ...
  'check_gbnd: the result carries no crystal frame')

checkMeanIsOne(nE,'from EBSD');
checkMeanIsOne(nG,'from grain2d');

% and it must actually be a distribution rather than the uniform one, or
% every check here would hold for a constant 1
assert(max(nE) > 2, ...
  'check_gbnd: the GBND is nearly uniform (max %.3f), so nothing is being measured', ...
  max(nE))

% the two forms describe the same boundaries, so they must agree in shape
% even though one uses pixel orientations and the other grain means
rel = norm(nE-nG)/norm(nE);
assert(rel < 0.2, ...
  ['check_gbnd: the EBSD and grain2d forms differ by %.3f relative - they ' ...
   'should describe the same boundary set'], rel)

end

% =========================================================================
function checkMeanIsOne(gbnd,what)

m = mean(gbnd);
assert(abs(m - 1) < 1e-3, ...
  'check_gbnd: the GBND %s has mean %.6f, a density must have mean 1', what, m)

end

% =========================================================================
function checkNonneg(plain,gB,ebsd)
% without 'nonneg' the harmonic estimate rings negative, with it it must not

assert(min(plain) < 0, ...
  ['check_gbnd: the plain harmonic estimate has min %.4f - it is expected to ' ...
   'ring negative, so the nonneg check below would prove nothing'], min(plain))

nn = calcGBND(gB,ebsd,'nonneg');
assert(min(nn) >= 0, ...
  'check_gbnd: calcGBND(...,''nonneg'') still goes negative, min %.4f', min(nn))

checkMeanIsOne(nn,'with nonneg');

end

% =========================================================================
function checkSmoothingSeam(ref,ebsd,grains,gB)
% smoothBoundary must not silently invalidate what calcGBND reads
%
% This is the join calcGBND's help warns about. ebsdId is the precondition,
% so that is what is asserted - not the GBND values, which on this map would
% be a vacuous comparison because constrained smoothing has nothing to move
% here (vertices shift by 5.6e-16 and the count stays at 177).

% -- the documented safe form ---------------------------------------------
gSafe = smoothBoundary(grains,3,'noSimplify','noRefine');
bSafe = gSafe.boundary('Glaucophane','Glaucophane');

assert(isequal(bSafe.ebsdId,gB.ebsdId), ...
  ['check_gbnd: smoothBoundary(...,''noSimplify'',''noRefine'') changed ' ...
   'ebsdId, so the form calcGBND documents as safe is not'])

safe = calcGBND(bSafe,ebsd);
assert(norm(safe-ref)/norm(ref) < 1e-6, ...
  'check_gbnd: the safe smoothing changed the GBND by %.4f relative', ...
  norm(safe-ref)/norm(ref))

% -- the default form, which does break it --------------------------------
gDflt = smoothBoundary(grains,3);
bDflt = gDflt.boundary('Glaucophane','Glaucophane');

assert(~isequal(bDflt.ebsdId,gB.ebsdId), ...
  ['check_gbnd: default smoothBoundary no longer rewrites ebsdId. If that ' ...
   'is intentional, calcGBND''s warning about it is now stale and this ' ...
   'check should become an equality'])

% the geometry is untouched, so any change in the GBND comes purely from
% segments being paired with the wrong orientations - which is what makes
% this failure silent
assert(max(angle(bDflt.direction,gB.direction)) < 1e-9, ...
  'check_gbnd: default smoothBoundary moved the segment directions too')

dflt = calcGBND(bDflt,ebsd);
assert(norm(dflt-ref)/norm(ref) > 0.01, ...
  ['check_gbnd: default smoothBoundary rewrote ebsdId but the GBND barely ' ...
   'moved (%.4f relative) - if the mis-pairing no longer matters, the ' ...
   'warning in calcGBND can go'], norm(dflt-ref)/norm(ref))

% and the documented way out: pass the grains instead of the EBSD, which
% reads grain mean orientations and does not depend on ebsdId at all
viaGrains = calcGBND(bDflt,gDflt);
checkMeanIsOne(viaGrains,'from a default-smoothed boundary via grains');

end
