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
checkCrystalFrameConstruction;
checkDelegation;
checkNamedSpecimenFrames;
checkRegisterDefaults;
checkDataFrameMembership;
checkMillerFrame;
checkS2FunFrame;
checkTwoFrames;
checkRotateFrameFit;
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
function checkCrystalFrameConstruction
% a crystal frame can be defined by lattice parameters and alignment
% options directly, without a symmetry - and gives the very axes
% crystalSymmetry computes

cs = crystalSymmetry('triclinic',[1 2 3],[70 80 120]*degree,'Z||a*');
cF = crystalFrame([1 2 3],[70 80 120]*degree,'Z||a*');
assert(all(norm(cF.basis - cs.axes) < 1e-10), ...
  'check_referenceFrame: crystalFrame from lattice parameters disagrees with crystalSymmetry');

% without a point group the geometry is triclinic - identical frame for
% every lattice, here the hexagonal X||a setup
cs = crystalSymmetry('6/mmm',[3 3 5],'X||a');
cF = crystalFrame([3 3 5],[90 90 120]*degree,'X||a');
assert(all(norm(cF.basis - cs.axes) < 1e-10), ...
  'check_referenceFrame: the general construction disagrees with the hexagonal setup');

% the crystal axes are named a, b, c and the display reflects the
% alignment and expresses the convention in crystal directions
assert(isequal(cF.axesNames,{'a','b','c'}), ...
  'check_referenceFrame: crystal axes are not named a, b, c');
assert(any(contains(alignment(cF),'X||a')), ...
  'check_referenceFrame: the alignment does not reflect X||a');
assert(isequal(alignment(cF),alignment(cs)), ...
  'check_referenceFrame: frame and symmetry disagree on the alignment');

fr = cs.frame;
out = evalc('display(fr)');
assert(contains(out,'X||a') && contains(out,'⊙c→a'), ...
  'check_referenceFrame: the crystal frame display misses alignment or convention');

% orthogonal lattices report no alignment, as before
assert(isempty(alignment(crystalFrame([2 3 4]))), ...
  'check_referenceFrame: an orthogonal frame must not report an alignment');

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
assert(strcmp(sF.name,'rolling') && isequal(sF.axesNames,{'RD','TD','ND'}), ...
  'check_referenceFrame: specimenFrame.rolling is wrong');

ss = specimenSymmetry('222');
assert(isa(ss.frame,'specimenFrame') && strcmp(ss.frame.name,'measurement'), ...
  'check_referenceFrame: specimenSymmetry does not carry a measurement frame');
assert(isa(ss.how2plot,'plottingConvention'), ...
  'check_referenceFrame: the specimen frame does not supply a convention');

% the factories return the one session instance from the register ...
assert(specimenFrame.rolling == specimenFrame.rolling, ...
  'check_referenceFrame: specimenFrame.rolling is not interned');
assert(referenceFrame.byName('rolling') == sF, ...
  'check_referenceFrame: referenceFrame.byName does not find the rolling frame');
assert(isempty(referenceFrame.byName('no-such-frame')), ...
  'check_referenceFrame: byName invents frames');

% ... while the constructor always makes a fresh, unregistered one
assert(specimenFrame('rolling') ~= specimenFrame.rolling, ...
  'check_referenceFrame: the constructor must not return the registered instance');

end

% -------------------------------------------------------------------------
function checkRegisterDefaults
% the default convention is carried by the registered default frame;
% specimenSymmetry.default's singleton holds that same frame

fr = specimenFrame.default;
assert(fr == specimenFrame.measurement, ...
  'check_referenceFrame: the default frame is not the measurement frame');
assert(plottingConvention.default == fr.how2plot, ...
  'check_referenceFrame: plottingConvention.default does not read through the frame');
assert(specimenSymmetry.default.frame == fr, ...
  'check_referenceFrame: specimenSymmetry.default does not hold the default frame');

% a fresh symmetry with the default convention attaches the session frame,
% one with its own convention gets a fork
assert(specimenSymmetry('222').frame == fr, ...
  'check_referenceFrame: a default-conventioned symmetry does not reuse the session frame');

pC = plottingConvention('z↑→x');
ssF = specimenSymmetry(pC);
assert(ssF.frame ~= fr && ssF.how2plot == pC, ...
  'check_referenceFrame: a custom convention must fork the frame');
assert(fr.how2plot ~= pC, ...
  'check_referenceFrame: the constructor wrote a custom convention through the session frame');

% setting a new default replaces the frame's convention: the singleton
% symmetry follows, the point group survives, a forked frame keeps its own
pC0 = plottingConvention.default;
restoreDefault = onCleanup(@() plottingConvention.default(pC0));

pC2 = plottingConvention('y↑→x');
id0 = specimenSymmetry.default.id;
plottingConvention.default(pC2);
assert(plottingConvention.default == pC2, ...
  'check_referenceFrame: plottingConvention.default(pC2) did not take');
assert(specimenSymmetry.default.how2plot == pC2 && specimenSymmetry.default.id == id0, ...
  'check_referenceFrame: the default symmetry does not follow the frame');
assert(ssF.how2plot == pC, ...
  'check_referenceFrame: replacing the default touched a forked frame');

end

% -------------------------------------------------------------------------
function checkDataFrameMembership
% vector3d resolves its convention override -> frame -> live session
% default; assigning the default itself means membership in the default
% frame, and rotating with an orientation changes the frame while a plain
% rotation keeps it

% frame-free: follows the live default
v = vector3d.rand(5);
assert(isempty(v.frame) && v.how2plot == plottingConvention.default, ...
  'check_referenceFrame: a fresh vector3d must be frame-free and follow the default');

% an own convention wins and stays local
pC = plottingConvention('z↑→x');
v.how2plot = pC;
assert(v.how2plot == pC && isempty(v.frame), ...
  'check_referenceFrame: v.how2plot = pC did not become an override');
assert(vector3d.X.how2plot == plottingConvention.default, ...
  'check_referenceFrame: the override leaked to other vectors');

% assigning the session default itself means membership in the default frame
w = vector3d.rand(3);
w.how2plot = plottingConvention.default;
assert(w.frame == specimenFrame.default && isempty(w.how2plotPrivate), ...
  'check_referenceFrame: assigning the default must become frame membership');

% under default replacement framed and frame-free data follow, an
% override does not
pC0 = plottingConvention.default;
pC2 = plottingConvention('y↑→x');
plottingConvention.default(pC2);
followsFramed = w.how2plot == pC2;
followsFree = vector3d.rand(2).how2plot == pC2;
keepsOverride = v.how2plot == pC;
plottingConvention.default(pC0);
assert(followsFramed, ...
  'check_referenceFrame: default-framed data does not follow a default replacement');
assert(followsFree, ...
  'check_referenceFrame: frame-free data does not follow a default replacement');
assert(keepsOverride, ...
  'check_referenceFrame: an override must not follow a default replacement');

% rotating with an orientation adopts the specimen frame ...
ori = orientation.rand(crystalSymmetry('m-3m'),specimenSymmetry.default);
r = rotate(Miller(1,0,0,ori.CS),ori);
assert(r.frame == specimenFrame.default, ...
  'check_referenceFrame: rotating by an orientation must adopt the specimen frame');

% ... while a plain rotation keeps the current frame state
v2 = rotate(v,rotation.rand);
assert(isempty(v2.frame) && v2.how2plot == pC, ...
  'check_referenceFrame: a plain rotation must keep the frame state');

% save / load: membership re-interns, an override survives, frame-free
% stays frame-free
fname = [tempname '.mat'];
save(fname,'v','w');
S = load(fname);
delete(fname);
assert(S.w.frame == specimenFrame.default, ...
  'check_referenceFrame: loaded frame membership did not re-intern');
assert(isempty(S.v.frame) && isapprox(S.v.how2plot,pC), ...
  'check_referenceFrame: a loaded override did not survive');

% the data classes expose the frame of their positions - EBSD delegation
ebsd = EBSD(vector3d.rand(4),rotation.rand(4,1),ones(4,1), ...
  {crystalSymmetry('m-3m')},struct());
ebsd.frame = specimenFrame.rolling;
assert(ebsd.frame == specimenFrame.rolling && ...
  ebsd.pos.frame == specimenFrame.rolling, ...
  'check_referenceFrame: ebsd.frame does not delegate to pos');

end

% -------------------------------------------------------------------------
function checkMillerFrame
% a Miller must have a frame, and it is the crystal frame of its
% symmetry - resolved live, never stored, so it cannot go stale

cs = crystalSymmetry('321',[3 3 5],'X||a');
m = Miller(1,0,0,cs);
assert(m.frame == cs.frame, ...
  'check_referenceFrame: the frame of a Miller is not its crystal frame');
assert(m.how2plot == cs.how2plot, ...
  'check_referenceFrame: a Miller does not plot in its crystal convention');

% replacing the symmetry moves the frame with it - both ways it happens
cs2 = crystalSymmetry('321',[3 3 5],'Y||a');
m2 = transformReferenceFrame(m,cs2);
assert(m2.frame == cs2.frame, ...
  'check_referenceFrame: transformReferenceFrame left a stale frame');
m.CS = cs2;
assert(m.frame == cs2.frame, ...
  'check_referenceFrame: setting CS left a stale frame');

% an own convention still wins over the crystal frame's ...
pC = plottingConvention('z↑→x');
m.how2plot = pC;
assert(m.how2plot == pC && cs2.how2plot ~= pC, ...
  'check_referenceFrame: the Miller override leaked into the symmetry');

% ... and assigning the session default becomes an override too - the
% frame of a Miller is fixed, membership in the specimen frame is not
% available for it
m.how2plot = plottingConvention.default;
assert(m.frame == cs2.frame && m.how2plot == plottingConvention.default, ...
  'check_referenceFrame: assigning the default must not detach a Miller from its frame');

% assigning a frame directly is refused
try
  m.frame = specimenFrame.rolling;
  failed = false;
catch e
  failed = strcmp(e.identifier,'MTEX:Miller:fixedFrame');
end
assert(failed, ...
  'check_referenceFrame: assigning a frame to a Miller must error');

% casting to vector3d drops the crystal frame
v = vector3d(Miller(1,0,0,cs));
assert(isempty(v.frame), ...
  'check_referenceFrame: vector3d(m) must drop the crystal frame');

% save / load keeps the coupling
fname = [tempname '.mat'];
m3 = Miller(1,2,3,cs);
save(fname,'m3');
S = load(fname);
delete(fname);
assert(S.m3.frame == S.m3.CS.frame && ...
  norm(squeeze(double(S.m3)) - squeeze(double(m3))) < 1e-10, ...
  'check_referenceFrame: Miller did not survive save/load');

end

% -------------------------------------------------------------------------
function checkS2FunFrame
% a plain S2Fun carries only a reference frame; the symmetry lives on
% S2FunHarmonicSym alone, which exposes its symmetry's frame

cs = crystalSymmetry('m-3m');
sF = S2FunHarmonic.quadrature(@(v) v.x.^2);
sFs = S2FunHarmonicSym(sF,cs);

assert(sFs.frame == cs.frame && sFs.CS == cs, ...
  'check_referenceFrame: a symmetrised S2Fun does not expose its symmetry''s frame');

try
  sFs.frame = specimenFrame.rolling;
  failed = false;
catch e
  failed = strcmp(e.identifier,'MTEX:S2Fun:fixedFrame');
end
assert(failed, ...
  'check_referenceFrame: assigning a frame to a symmetrised S2Fun must error');

% arithmetic keeps the frame
sFa = 2*sFs + 1;
assert(sFa.frame == cs.frame, ...
  'check_referenceFrame: S2Fun arithmetic dropped the crystal frame');

% rotating with an orientation moves the function into the specimen
% frame and strips the symmetry
r = rotate(sFs,orientation.rand(cs,specimenSymmetry.default));
assert(~isa(r,'S2FunHarmonicSym') && r.frame == specimenFrame.default, ...
  'check_referenceFrame: rotating by an orientation must land in the specimen frame');

% casting a symmetrised function to a plain harmonic keeps the crystal
% frame, and with it the convention
p = S2FunHarmonic(sFs);
assert(p.frame == cs.frame && p.how2plot == cs.how2plot, ...
  'check_referenceFrame: the cast to S2FunHarmonic lost the crystal frame');

% extrema come back in the frame of the function: Miller for a
% symmetrised one, a crystal-framed vector3d for a plain one - that the
% latter should ideally be a Miller too is an open problem, see the note
% in S2Fun/min and ADR 0003
[~,pos] = max(sFs);
assert(isa(pos,'Miller') && pos.CS == cs, ...
  'check_referenceFrame: extrema of a symmetrised S2Fun are not Miller');

[~,pos] = max(p);
assert(pos.frame == cs.frame, ...
  'check_referenceFrame: extrema of a crystal-framed S2Fun lost the frame');

end

% -------------------------------------------------------------------------
function checkTwoFrames
% orientation and SO3Fun have exactly two frames - the frames of their
% symmetries, resolved live and never assignable directly

cs = crystalSymmetry('m-3m');
ss = specimenSymmetry('222');
ori = orientation.rand(cs,ss);
assert(ori.frameRight == cs.frame && ori.frameLeft == ss.frame, ...
  'check_referenceFrame: the orientation frames are not its symmetries'' frames');

% a misorientation has two crystal frames
cs2 = crystalSymmetry('6/mmm',[3 3 5]);
mori = orientation.rand(cs,cs2);
assert(isa(mori.frameLeft,'crystalFrame') && mori.frameLeft == cs2.frame, ...
  'check_referenceFrame: the misorientation left frame is not the crystal frame');

% replacing a symmetry moves the frame with it
ori.CS = cs2;
assert(ori.frameRight == cs2.frame, ...
  'check_referenceFrame: replacing CS left a stale frameRight');

% assigning a frame directly is refused
try
  ori.frameLeft = specimenFrame.rolling;
  failed = false;
catch e
  failed = strcmp(e.identifier,'MTEX:orientation:fixedFrame');
end
assert(failed, ...
  'check_referenceFrame: assigning a frame to an orientation must error');

% same for SO3Fun
odf = unimodalODF(orientation.rand(cs,ss));
assert(odf.frameRight == cs.frame && odf.frameLeft == ss.frame, ...
  'check_referenceFrame: the SO3Fun frames are not its symmetries'' frames');

try
  odf.frameLeft = specimenFrame.rolling;
  failed = false;
catch e
  failed = strcmp(e.identifier,'MTEX:SO3Fun:fixedFrame');
end
assert(failed, ...
  'check_referenceFrame: assigning a frame to an SO3Fun must error');

end

% -------------------------------------------------------------------------
function checkRotateFrameFit
% rotating with an orientation requires only fitting frames, not equal
% symmetries, and the result carries the specimen FRAME of the
% orientation, never its specimen symmetry

cs = crystalSymmetry('m-3m',[4.05 4.05 4.05],'mineral','Al');
ss = specimenSymmetry('222');   % a non trivial specimen symmetry
ori = orientation.rand(cs,ss);

% a tensor of a DIFFERENT point group in the same frame rotates fine now
csLow = crystalSymmetry('mmm',[4.05 4.05 4.05]);
T = tensor(diag([1 2 3]),'rank',2,csLow);
Tr = rotate(T,ori);
assert(isa(Tr.CS,'specimenSymmetry') && Tr.CS.id == 1, ...
  'check_referenceFrame: a rotated tensor must carry only a trivial specimen symmetry');
assert(Tr.CS.frame == ss.frame, ...
  'check_referenceFrame: a rotated tensor must carry the specimen frame');

% a trivial specimen symmetry is kept as it is - the common case
Tr0 = rotate(T,orientation.rand(cs));
assert(Tr0.CS.frame == specimenFrame.default, ...
  'check_referenceFrame: the trivial case must keep the session frame');

% genuinely incompatible frames error
Thex = T;
Thex.CS = crystalSymmetry('6/mmm',[3 3 5]);
try
  rotate(Thex,ori);
  failed = false;
catch e
  failed = strcmp(e.identifier,'MTEX:orientation:frameMismatch');
end
assert(failed, ...
  'check_referenceFrame: rotating across incompatible frames must error');

% a compatible but differently aligned frame is absorbed into the
% rotation - the result equals transforming the data first
csA = crystalSymmetry('triclinic',[1 2 3],[70 80 120]*degree,'Z||a*');
csB = crystalSymmetry('triclinic',[1 2 3],[70 80 120]*degree,'Z||b','X||a*');
oriB = orientation.rand(csB);
m = Miller(1,2,3,csA);
evalc('r1 = rotate(m,oriB);'); % evalc swallows the transformation notice
r2 = rotate(transformReferenceFrame(m,csB),oriB);
assert(all(norm(r1 - r2) < 1e-8), ...
  'check_referenceFrame: the absorbed frame transition disagrees with transformReferenceFrame');

% slipSystem rotates componentwise through Miller and inherits the rules
sS = slipSystem.fcc(cs);
sSr = rotate(sS,orientation.rand(cs));
assert(~isa(sSr.b,'Miller') && sSr.b.frame == specimenFrame.default, ...
  'check_referenceFrame: a rotated slip system must land in the specimen frame');

% a crystal frame never fits a specimen frame - a wrong sided rotation
% of specimen framed data errors ...
w = vector3d.rand;
w.how2plot = plottingConvention.default;  % membership in the specimen frame
try
  rotate(w,ori);
  failed = false;
catch e
  failed = strcmp(e.identifier,'MTEX:orientation:frameMismatch');
end
assert(failed, ...
  'check_referenceFrame: rotating specimen framed data by an orientation must error');

% ... while the right side passes and lands in the crystal frame
r3 = rotate(w,inv(ori));
assert(r3.frame == cs.frame, ...
  'check_referenceFrame: inv(ori) must take specimen data into the crystal frame');

% the displays show the frame together with the convention: a rotated
% slip system reports the specimen convention, a rolling framed vector
% its axes names, a crystal framed vector only the frame identity
out = evalc('display(sSr)');
assert(contains(out,['(' char(plottingConvention.default,'compact') ')']), ...
  'check_referenceFrame: a rotated slip system must display the specimen convention');

rf = specimenFrame('rolling','axesNames',{'RD','TD','ND'},plottingConvention('y↑→x'));
vR = vector3d.rand(3);
vR.frame = rf;
out = evalc('display(vR)');
assert(contains(out,'TD↑→RD'), ...
  'check_referenceFrame: a rolling framed vector must display its axes names');

mAl = Miller(1,0,0,cs);
out = evalc('display(mAl)');
assert(contains(out,'Al'), ...
  'check_referenceFrame: a crystal framed direction must display the frame identity');

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

% loadobj re-interns: a default-conventioned symmetry comes back holding
% the session frame, one with its own convention keeps its fork
assert(S.ss.frame == specimenFrame.default, ...
  'check_referenceFrame: loadobj did not re-intern the default frame');

pCF = plottingConvention('z↑→x');
ssF = specimenSymmetry(pCF);
fname = [tempname '.mat'];
save(fname,'ssF');
S = load(fname);
delete(fname);
assert(S.ssF.frame ~= specimenFrame.default && ...
  isapprox(S.ssF.how2plot,pCF), ...
  'check_referenceFrame: loadobj re-interned a forked frame');

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
