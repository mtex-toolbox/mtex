function check_referenceFrame
% the referenceFrame type: delegation from the symmetry classes, frame
% transitions, and the ensureCS compatibility decision (ADR 0003)
%
% crystalSymmetry/specimenSymmetry delegate their frame data (axes,
% how2plot) to a referenceFrame they hold. The transition between two
% frames is computed on the frame (transformationMatrix / isCompatible),
% replacing the two disagreeing matrix constructions that used to live in
% crystalSymmetry/transformationMatrix and symmetry/ensureCS.

checkTransitionEquivalence;
checkAxisRepairHeuristic;
checkDelegation;
checkNamedSpecimenFrames;
checkSaveLoadRoundTrip;
checkEnsureCS;

disp('check_referenceFrame: passed');

end

% =========================================================================
function checkTransitionEquivalence
% the frame transition reproduces the legacy crystalSymmetry matrix
% bit-identically, and maps Miller coordinates between the two setups

cs1 = crystalSymmetry('triclinic',[1 2 3],[70 80 120]*degree,'Z||a*');
cs2 = crystalSymmetry('triclinic',[1 2 3],[70 80 120]*degree,'Z||b','X||a*');

% the legacy formula, inlined
axes1 = double(normalize(cs1.axes)).';
axes2 = double(normalize(cs2.axes)).';
Mref = axes2^-1 * axes1;

assert(isequal(Mref,transformationMatrix(cs1,cs2)), ...
  'check_referenceFrame: crystalSymmetry/transformationMatrix changed its result');
assert(isequal(Mref,transformationMatrix(cs1.frame,cs2.frame)), ...
  'check_referenceFrame: the frame transition differs from the legacy matrix');

% the transition takes the Euclidean coordinates of a direction from the
% frame of cs1 into the frame of cs2
m1 = Miller(1,2,3,cs1);
m2 = Miller(1,2,3,cs2);
assert(norm(Mref * squeeze(double(m1)) - squeeze(double(m2))) < 1e-10, ...
  'check_referenceFrame: the transition does not map Miller coordinates');

end

% -------------------------------------------------------------------------
function checkAxisRepairHeuristic
% two monoclinic settings of the same lattice - '121' (unique axis b) and
% '112' (unique axis c) - differ by a permutation of the crystal axes.
% crystalFrame/transformationMatrix re-pairs the axes by nearest length,
% so the transition comes out orthogonal; the pure transition does not.

csA = crystalSymmetry('121',[2 3 4],[90 105 90]*degree);
csB = crystalSymmetry('112',[4 2 3],[90 90 105]*degree);

[ok,M] = isCompatible(csA.frame,csB.frame);
assert(ok && norm(M*M.' - eye(3)) < 1e-10, ...
  'check_referenceFrame: axis re-pairing did not make the transition orthogonal');

% without the re-pairing the transition mixes axes of different length
axesA = double(normalize(csA.axes)).';
axesB = double(normalize(csB.axes)).';
Mpure = axesB^-1 * axesA;
assert(norm(Mpure*Mpure.' - eye(3)) > 0.1, ...
  ['check_referenceFrame: the test lattice does not distinguish the pure ' ...
  'from the re-paired transition - pick other axis lengths']);

end

% -------------------------------------------------------------------------
function checkDelegation
% axes and the lattice parameters read through the frame unchanged, and
% setting axes forks the frame instead of writing through the shared handle

cs = crystalSymmetry('mmm',[2 3 4],'mineral','TestMineral');

assert(isa(cs.frame,'crystalFrame') && strcmp(cs.frame.name,'TestMineral'), ...
  'check_referenceFrame: the crystal frame is missing or unnamed');
assert(all(abs(norm(cs.axes) - [2 3 4]) < 1e-10), ...
  'check_referenceFrame: cs.axes does not read through the frame');
assert(all(abs(cs.abc - [2 3 4]) < 1e-10) && all(abs(cs.abg - pi/2) < 1e-10), ...
  'check_referenceFrame: abc/abg do not read through the frame');
assert(abs(cs.alpha-pi/2) + abs(cs.beta-pi/2) + abs(cs.gamma-pi/2) < 1e-10, ...
  'check_referenceFrame: alpha/beta/gamma do not read through the frame');

% a shallow copy shares the frame handle ...
cs2 = copy(cs);
assert(cs2.frame == cs.frame, ...
  'check_referenceFrame: copy(cs) does not share the frame handle');

% ... and setting axes forks it, leaving the original untouched
pC = cs.frame.how2plot;
cs2.axes = 2 * cs.axes;
assert(cs2.frame ~= cs.frame, ...
  'check_referenceFrame: setting axes did not fork the frame');
assert(all(abs(norm(cs.axes) - [2 3 4]) < 1e-10), ...
  'check_referenceFrame: setting axes on a copy changed the original');
assert(cs2.frame.how2plot == pC && strcmp(cs2.frame.name,'TestMineral'), ...
  'check_referenceFrame: the fork dropped the convention or the name');

end

% -------------------------------------------------------------------------
function checkNamedSpecimenFrames

sF = specimenFrame.rolling;
assert(strcmp(sF.name,'rolling') && isequal(sF.axisLabels,{'RD','TD','ND'}), ...
  'check_referenceFrame: specimenFrame.rolling is wrong');

ss = specimenSymmetry('222');
assert(isa(ss.frame,'specimenFrame') && strcmp(ss.frame.name,'measurement'), ...
  'check_referenceFrame: specimenSymmetry does not carry a measurement frame');
assert(isa(ss.how2plot,'plottingConvention'), ...
  'check_referenceFrame: the specimen frame does not supply a convention');

% two frames of the same kind are distinct handles - interning is the
% (future) register's job, and identity must not accidentally alias
assert(specimenFrame.rolling ~= specimenFrame.rolling, ...
  'check_referenceFrame: specimenFrame factories return a shared handle');

end

% -------------------------------------------------------------------------
function checkSaveLoadRoundTrip

cs = crystalSymmetry('321',[3 3 5],'mineral','RoundTrip','X||a');
cs.how2plot = plottingConvention('z↑→x');   % an override on top of the frame
ss = specimenSymmetry('222');

fname = [tempname '.mat'];
save(fname,'cs','ss');
S = load(fname);
delete(fname);

assert(all(abs(norm(S.cs.axes) - norm(cs.axes)) < 1e-10) && ...
  isa(S.cs.frame,'crystalFrame') && strcmp(S.cs.frame.name,'RoundTrip'), ...
  'check_referenceFrame: crystalSymmetry did not survive save/load');
assert(strcmp(char(S.cs.how2plot),char(cs.how2plot)), ...
  'check_referenceFrame: the how2plot override did not survive save/load');
assert(isa(S.ss.frame,'specimenFrame') && ...
  strcmp(char(S.ss.how2plot),char(ss.how2plot)), ...
  'check_referenceFrame: specimenSymmetry did not survive save/load');

end

% -------------------------------------------------------------------------
function checkEnsureCS
% the compatibility decision now runs on the normalized, length-repaired
% frame transition - the same matrix transformReferenceFrame applies

% same alignment, 3% lattice constant difference: within eqTol's 5% axes
% tolerance, so the object comes back untouched - as before
csOld = crystalSymmetry('mmm',[2 3 4]);
csNew = crystalSymmetry('mmm',[2.06 3.09 4.12]);
m = ensureCS(csNew,Miller(1,0,0,csOld));
assert(m.CS == csOld, ...
  'check_referenceFrame: ensureCS at 3% abc difference is eqTol''s business');

% 10% difference: used to error, now relabeled - lattice constant scaling
% no longer enters the compatibility decision (deliberate change, 2026-08-14)
csNew = crystalSymmetry('mmm',[2.2 3.3 4.4]);
m = ensureCS(csNew,Miller(1,0,0,csOld));
assert(m.CS == csNew, ...
  'check_referenceFrame: ensureCS rejected a pure lattice-constant difference');

% different alignment: transform, identical to transformReferenceFrame
cs1 = crystalSymmetry('triclinic',[1 2 3],[70 80 120]*degree,'Z||a*');
cs2 = crystalSymmetry('triclinic',[1 2 3],[70 80 120]*degree,'Z||b','X||a*');
m1 = Miller(1,2,3,cs1);
mE = ensureCS(cs2,m1);
mT = transformReferenceFrame(m1,cs2);
assert(mE.CS == cs2 && norm(squeeze(double(mE)) - squeeze(double(mT))) < 1e-10, ...
  'check_referenceFrame: ensureCS transform disagrees with transformReferenceFrame');

% a specimen symmetry has no crystal frame: warn and leave the object alone
w0 = warning('off','MTEX:symmetry:missmatch');
restoreWarning = onCleanup(@() warning(w0));
lastwarn('','');
m = ensureCS(specimenSymmetry('222'),Miller(1,0,0,csOld));
[~,wid] = lastwarn;
assert(strcmp(wid,'MTEX:symmetry:missmatch') && m.CS == csOld, ...
  'check_referenceFrame: ensureCS with a specimenSymmetry must warn and return');

% genuinely different point groups still error
try
  ensureCS(crystalSymmetry('6/mmm'),Miller(1,0,0,crystalSymmetry('m-3m')));
  failed = true;
catch
  failed = false;
end
assert(~failed, ...
  'check_referenceFrame: ensureCS accepted two different point groups');

end
