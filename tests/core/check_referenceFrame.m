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
checkSessionReset;
checkFrameCarriage;
checkTangentVectorFrames;
checkTrivialSymmetryFromFrame;
checkGridLayout;
checkLayoutIndex;
checkScreenAlignment;
checkFundamentalSectorFrame;
checkHemisphereSectorHue;
checkProductDropsSymmetry;
checkPlotS2GridFrame;
checkSchmidFactorFrames;
checkFrameGroup;

disp('check_referenceFrame: passed');

end

% =========================================================================
function checkFrameGroup
% a frame carries the point group its axes are written in, and hands out
% the siblings that differ from it only in that group (ADR 0008 rules 1, 7)

cs = crystalSymmetry('432',[4.05 4.05 4.05],'mineral','Aluminium');
fr = cs;

assert(fr.sym.id == cs.id, ...
  'check_referenceFrame: the frame does not carry the group of its symmetry');
assert(all(isappr(abs(dot(fr.sym.rot(:),cs.rot(:))),1)), ...
  'check_referenceFrame: the frame carries different group elements');
assert(strcmp(fr.sym.name,'432'), ...
  'check_referenceFrame: a group is not named by its international symbol');

% the group of a trigonal or monoclinic cell depends on where a and c
% point, so a frame built from lattice parameters alone still gets it
bare = crystalFrame([2.95 2.95 4.68],'pointId',40);
assert(bare.sym.id == 40 && numSym(bare.sym) == 24, ...
  'check_referenceFrame: a crystalFrame does not build the group of its pointId');

% the Laue sibling is a different frame with the same basis and name
L = fr.Laue;
assert(L ~= fr,'check_referenceFrame: the Laue sibling is the frame itself');
assert(L.sym.id == cs.Laue.id, ...
  'check_referenceFrame: the Laue sibling carries the wrong group');
assert(isAligned(L,fr) && strcmp(L.name,fr.name) && isa(L,class(fr)), ...
  'check_referenceFrame: the Laue sibling differs in more than its group');

% asking twice gives one handle, or the two would not compare
assert(fr.Laue == L,'check_referenceFrame: the Laue sibling is not stable');
assert(L.Laue == L,'check_referenceFrame: the Laue of a Laue frame is not itself');

% a frame already carrying that group is its own sibling
csL = crystalSymmetry('m-3m',[4.05 4.05 4.05],'mineral','Aluminium');
assert(csL.Laue == csL, ...
  'check_referenceFrame: a Laue frame does not answer itself');
assert(csL.properGroup.sym.id == cs.id, ...
  'check_referenceFrame: the proper sibling of m-3m is not 432');
assert(fr.properGroup == fr, ...
  'check_referenceFrame: a proper group frame does not answer itself');

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
assert(isequal(Mref,transformationMatrix(cs1,cs2)), ...
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

[ok,M] = isCompatible(csA,csB);
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

fr = cs;
out = evalc('display(fr)');
assert(contains(out,'X||a') && contains(out,'⊙c→a'), ...
  'check_referenceFrame: the crystal frame display misses alignment or convention');

% orthogonal lattices report no alignment, as before
assert(isempty(alignment(crystalFrame([2 3 4]))), ...
  'check_referenceFrame: an orthogonal frame must not report an alignment');

end

% -------------------------------------------------------------------------
function checkDelegation
% crystalSymmetry names a crystal frame, and the lattice is that frame's

cs = crystalSymmetry('mmm',[2 3 4],'mineral','TestMineral');

assert(isa(cs,'crystalFrame') && strcmp(cs.name,'TestMineral'), ...
  'check_referenceFrame: crystalSymmetry did not return a named crystal frame');
assert(strcmp(cs.mineral,cs.name), ...
  'check_referenceFrame: the mineral and the frame identity disagree');
assert(all(abs(norm(cs.axes) - [2 3 4]) < 1e-10), ...
  'check_referenceFrame: cs.axes is not the basis of the frame');
assert(all(abs(cs.abc - [2 3 4]) < 1e-10) && all(abs(cs.abg - pi/2) < 1e-10), ...
  'check_referenceFrame: abc/abg do not read off the basis');
assert(abs(cs.alpha-pi/2) + abs(cs.beta-pi/2) + abs(cs.gamma-pi/2) < 1e-10, ...
  'check_referenceFrame: alpha/beta/gamma do not read off the basis');

% the group came with it
assert(cs.id == 16 && numSym(cs) == 8, ...
  'check_referenceFrame: the frame does not carry the group it was asked for');

% a registered frame refuses to have its lattice rewritten - every dataset
% holding it would change with it. A different lattice is a different frame
try
  cs.axes = 2 * cs.axes;
  error('check_referenceFrame: a registered frame accepted new axes');
catch e
  assert(strcmp(e.identifier,'MTEX:referenceFrame:sealed'), ...
    'check_referenceFrame: rewriting the axes of a registered frame must be refused');
end
assert(all(abs(norm(cs.axes) - [2 3 4]) < 1e-10), ...
  'check_referenceFrame: the refused assignment changed the axes anyway');

% the frame with the doubled lattice is asked for, not carved out of this one
cs2 = crystalSymmetry('mmm',2*[2 3 4],'mineral','TestMineral');
assert(cs2 ~= cs && strcmp(cs2.name,'TestMineral'), ...
  'check_referenceFrame: a different lattice must be a different frame');

end

% -------------------------------------------------------------------------
function checkNamedSpecimenFrames

sF = specimenFrame.rolling;
assert(strcmp(sF.name,'rolling') && isequal(sF.axesNames,{'RD','TD','ND'}), ...
  'check_referenceFrame: specimenFrame.rolling is wrong');
assert(strcmp(conventionChar(sF),'TD←RD↑'), ...
  'check_referenceFrame: the rolling frame does not plot RD north, TD west');

ss = specimenSymmetry('222');
assert(isa(ss,'specimenFrame') && strcmp(ss.name,'specimen'), ...
  'check_referenceFrame: specimenSymmetry does not carry the generic specimen frame');
assert(isequal(specimenFrame.specimen.axesNames,{'X','Y','Z'}), ...
  'check_referenceFrame: the generic specimen frame does not use the canonical axes X, Y, Z');
assert(isequal(specimenFrame.measurement.axesNames,{'X1','Y1','Z1'}), ...
  'check_referenceFrame: the measurement frame does not use the Oxford axes X1, Y1, Z1');
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
% specimenFrame.default's singleton holds that same frame

fr = specimenFrame.default;
assert(fr == specimenFrame.specimen, ...
  'check_referenceFrame: the default frame is not the generic specimen frame');
assert(plottingConvention.default == fr.how2plot, ...
  'check_referenceFrame: plottingConvention.default does not read through the frame');
assert(specimenFrame.default == fr, ...
  'check_referenceFrame: specimenFrame.default does not hold the default frame');

% the trivial group with the default convention IS the session frame; a
% group of its own gets the sibling that carries it - same basis, same
% convention, a frame of its own (ADR 0008 rule 7)
assert(specimenSymmetry == fr, ...
  'check_referenceFrame: the trivial specimen symmetry is not the session frame');

ss222 = specimenSymmetry('222');
assert(ss222 ~= fr, ...
  'check_referenceFrame: a specimen group did not get a sibling of its own');
assert(ss222.id == 12 && isAligned(ss222,fr) && ss222.how2plot == fr.how2plot, ...
  'check_referenceFrame: the sibling differs in more than its group');
assert(specimenSymmetry('222') == ss222, ...
  'check_referenceFrame: the sibling is not stable across two constructions');
assert(fr.id == 1, ...
  'check_referenceFrame: asking for a group wrote it onto the session frame');

pC = plottingConvention('z↑→x');
ssF = specimenSymmetry(pC);
assert(ssF ~= fr && ssF.how2plot == pC, ...
  'check_referenceFrame: a custom convention must fork the frame');
assert(fr.how2plot ~= pC, ...
  'check_referenceFrame: the constructor wrote a custom convention through the session frame');

% setting a new default replaces the frame's convention: the singleton
% symmetry follows, the point group survives, a forked frame keeps its own
pC0 = plottingConvention.default;
restoreDefault = onCleanup(@() plottingConvention.default(pC0));

pC2 = plottingConvention('y↑→x');
id0 = specimenFrame.default.id;
plottingConvention.default(pC2);
assert(plottingConvention.default == pC2, ...
  'check_referenceFrame: plottingConvention.default(pC2) did not take');
assert(specimenFrame.default.how2plot == pC2 && specimenFrame.default.id == id0, ...
  'check_referenceFrame: the default symmetry does not follow the frame');
assert(ssF.how2plot == pC, ...
  'check_referenceFrame: replacing the default touched a forked frame');

% any specimen frame can take over the session default
fr0 = specimenFrame.default;
restoreFrame = onCleanup(@() makeDefault(fr0));

specimenFrame.rolling.makeDefault;
assert(specimenFrame.default == specimenFrame.rolling, ...
  'check_referenceFrame: makeDefault did not repoint the default frame');
assert(plottingConvention.default == specimenFrame.rolling.how2plot, ...
  'check_referenceFrame: plottingConvention.default does not follow the new default frame');
assert(specimenFrame.default == specimenFrame.rolling, ...
  'check_referenceFrame: specimenFrame.default does not follow the new default frame');
ssR = specimenSymmetry;
assert(ssR == specimenFrame.rolling, ...
  'check_referenceFrame: a fresh specimenSymmetry does not attach the new default frame');

makeDefault(fr0);
clear restoreFrame

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

% an own convention becomes an own, unregistered frame carrying it -
% only frames carry conventions
pC = plottingConvention('z↑→x');
v.frame = specimenFrame.frameFor(pC);
assert(v.how2plot == pC && ~isempty(v.frame) && v.frame ~= specimenFrame.default, ...
  'check_referenceFrame: giving v a frame did not take');
assert(vector3d.X.how2plot == plottingConvention.default, ...
  'check_referenceFrame: the fork leaked to other vectors');

% assigning the session default itself means membership in the default frame
w = vector3d.rand(3);
w.frame = specimenFrame.frameFor(plottingConvention.default);
assert(w.frame == specimenFrame.default, ...
  'check_referenceFrame: assigning the default must become frame membership');

% under default replacement framed and frame-free data follow, an own
% frame does not
pC0 = plottingConvention.default;
pC2 = plottingConvention('y↑→x');
plottingConvention.default(pC2);
followsFramed = w.how2plot == pC2;
followsFree = vector3d.rand(2).how2plot == pC2;
keepsOwn = v.how2plot == pC;
plottingConvention.default(pC0);
assert(followsFramed, ...
  'check_referenceFrame: default-framed data does not follow a default replacement');
assert(followsFree, ...
  'check_referenceFrame: frame-free data does not follow a default replacement');
assert(keepsOwn, ...
  'check_referenceFrame: an own frame must not follow a default replacement');

% rotating with an orientation adopts the specimen frame ...
ori = orientation.rand(crystalSymmetry('m-3m'),specimenFrame.default);
r = rotate(Miller(1,0,0,ori.CS),ori);
assert(r.frame == specimenFrame.default, ...
  'check_referenceFrame: rotating by an orientation must adopt the specimen frame');

% ... while a plain rotation keeps the current frame state
v2 = rotate(v,rotation.rand);
assert(v2.frame == v.frame && v2.how2plot == pC, ...
  'check_referenceFrame: a plain rotation must keep the frame state');

% save / load: membership re-interns, an own fork stays local - only a
% CONTAINER like EBSD applies its convention to the session on load
fname = [tempname '.mat'];
save(fname,'v','w');
S = load(fname);
delete(fname);
assert(S.w.frame == specimenFrame.default, ...
  'check_referenceFrame: loaded frame membership did not re-intern');
assert(S.v.frame ~= specimenFrame.default && isapprox(S.v.how2plot,pC), ...
  'check_referenceFrame: a loaded own frame did not survive');

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
assert(m.frame == cs, ...
  'check_referenceFrame: the frame of a Miller is not its crystal frame');
assert(m.how2plot == cs.how2plot, ...
  'check_referenceFrame: a Miller does not plot in its crystal convention');

% replacing the symmetry moves the frame with it - both ways it happens
cs2 = crystalSymmetry('321',[3 3 5],'Y||a');
m2 = transformReferenceFrame(m,cs2);
assert(m2.frame == cs2, ...
  'check_referenceFrame: transformReferenceFrame left a stale frame');
m.CS = cs2;
assert(m.frame == cs2, ...
  'check_referenceFrame: setting CS left a stale frame');

% the two assignments say different things, which is why both exist:
% .CS keeps the INDICES and recomputes the components, .frame keeps the
% COMPONENTS and restates which frame they are in
mIdx = Miller(1,2,3,cs);
mIdx.CS = cs2;
assert(all(abs(mIdx.hkl - [1 2 3]) < 1e-10), ...
  'check_referenceFrame: assigning CS must keep the indices');

mCmp = Miller(1,2,3,cs);
xyzBefore = squeeze(double(mCmp));
mCmp.frame = cs2;
assert(norm(squeeze(double(mCmp)) - xyzBefore) < 1e-10, ...
  'check_referenceFrame: assigning frame must keep the components');

% and a crystal direction put into a specimen frame stops being one - it
% still has coordinates, it just has no indices any more
mSpec = Miller(1,2,3,cs);
mSpec.frame = specimenFrame.rolling;
assert(~isCrystalDirection(mSpec) && isempty(mSpec.CS), ...
  'check_referenceFrame: a specimen framed direction must have no indices');

% casting to vector3d keeps the crystal frame: the frame says where the
% coordinates live, and a cast does not move them. Dropping it would
% silently reinterpret the numbers as specimen coordinates
v = vector3d(Miller(1,0,0,cs));
assert(v.frame == cs && isCrystalDirection(v), ...
  'check_referenceFrame: vector3d(m) must keep the crystal frame');

% save / load keeps the coupling
fname = [tempname '.mat'];
m3 = Miller(1,2,3,cs);
save(fname,'m3');
S = load(fname);
delete(fname);
assert(S.m3.frame == S.m3.CS && ...
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

assert(sFs.frame == cs && sFs.CS == cs, ...
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
assert(sFa.frame == cs, ...
  'check_referenceFrame: S2Fun arithmetic dropped the crystal frame');

% rotating with an orientation moves the function into the specimen
% frame and strips the symmetry
r = rotate(sFs,orientation.rand(cs,specimenFrame.default));
assert(~isa(r,'S2FunHarmonicSym') && r.frame == specimenFrame.default, ...
  'check_referenceFrame: rotating by an orientation must land in the specimen frame');

% casting a symmetrised function to a plain harmonic keeps the crystal
% frame, and with it the convention
p = S2FunHarmonic(sFs);
assert(p.frame == cs && p.how2plot == cs.how2plot, ...
  'check_referenceFrame: the cast to S2FunHarmonic lost the crystal frame');

% extrema come back in the frame of the function, with indices for a crystal frame
[~,pos] = max(sFs);
assert(isCrystalDirection(pos) && pos.CS == cs, ...
  'check_referenceFrame: extrema of a symmetrised S2Fun are not crystal directions');

% an unsymmetrised function claims no symmetry, so its extrema come back on
% the group-stripped sibling of the frame - rule 9 of ADR 0008
[~,pos] = max(p);
assert(isCrystalDirection(pos) && pos.CS.id == 1 && pos.CS == stripSym(cs), ...
  ['check_referenceFrame: extrema of a plain crystal-framed S2Fun must be ' ...
  'written on the group-stripped sibling of that frame']);

v = p.discreteSample(5);
assert(isCrystalDirection(v) && v.CS.id == 1 && v.CS == stripSym(cs), ...
  ['check_referenceFrame: a sample of a plain crystal-framed S2Fun must be ' ...
  'written on the group-stripped sibling of that frame']);

end

% -------------------------------------------------------------------------
function checkTwoFrames
% orientation and SO3Fun have exactly two frames - the frames of their
% symmetries, resolved live and never assignable directly

cs = crystalSymmetry('m-3m');
ss = specimenSymmetry('222');
ori = orientation.rand(cs,ss);
% the two frames are named by position: A is what the orientation maps from,
% B what it maps into, and CS/SS resolve onto them
assert(ori.frameA == cs && ori.frameB == ss, ...
  'check_referenceFrame: the orientation does not name both its frames');
assert(ori.CS == ori.frameA && ori.SS == ori.frameB, ...
  'check_referenceFrame: CS and SS do not resolve positionally');

% inv swaps them, which is what makes the resolution positional rather than
% by kind - inv(ori).CS is the specimen side
assert(inv(ori).frameA == ss && inv(ori).CS == ss, ...
  'check_referenceFrame: inv did not swap the two frames');

% a misorientation has two crystal frames
cs2 = crystalSymmetry('6/mmm',[3 3 5]);
mori = orientation.rand(cs,cs2);
assert(isa(mori.frameB,'crystalFrame') && mori.frameB == cs2, ...
  'check_referenceFrame: the misorientation B frame is not the crystal frame');

% replacing a symmetry moves the frame with it
ori.CS = cs2;
assert(ori.frameA == cs2, ...
  'check_referenceFrame: replacing CS left a stale frameA');

% same for SO3Fun
odf = unimodalODF(orientation.rand(cs,ss));
assert(odf.frameRight == cs && odf.frameLeft == ss, ...
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
assert(isa(Tr.CS,'specimenFrame') && Tr.CS.id == 1, ...
  'check_referenceFrame: a rotated tensor must carry only a trivial specimen symmetry');
assert(Tr.CS == stripSym(ss) && isAligned(Tr.CS,ss), ...
  'check_referenceFrame: a rotated tensor must carry the group-stripped specimen frame');

% a trivial specimen symmetry is kept as it is - the common case
Tr0 = rotate(T,orientation.rand(cs));
assert(Tr0.CS == specimenFrame.default, ...
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

% slipSystem rotates its directions componentwise and inherits the rules
sS = slipSystem.fcc(cs);
sSr = rotate(sS,orientation.rand(cs));
assert(~isCrystalDirection(sSr.b) && sSr.b.frame == specimenFrame.default, ...
  'check_referenceFrame: a rotated slip system must land in the specimen frame');

% a crystal frame never fits a specimen frame - a wrong sided rotation
% of specimen framed data errors ...
w = vector3d.rand;
w.frame = specimenFrame.default;  % membership in the specimen frame
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
assert(r3.frame == cs, ...
  'check_referenceFrame: inv(ori) must take specimen data into the crystal frame');

% the displays show the frame together with the convention
out = evalc('display(sSr)');
% the convention sits inside the clickable frame link, so match it bare
assert(contains(out,conventionChar(specimenFrame.default)), ...
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

% give it a frame of its own, carrying a convention that is not the default
frC = crystalFrame(cs.axes,'name','RoundTrip');
frC.how2plot = plottingConvention('z↑→x');
cs = frC;

% a specimen frame has no lattice, so it is not one a crystal group can be
% written in - its canonical basis would stand in for the crystal axes
try
  crystalSymmetry(specimenFrame.frameFor(plottingConvention('z↑→x')));
  error('check_referenceFrame: crystalSymmetry accepted a specimenFrame');
catch e
  assert(strcmp(e.identifier,'MTEX:wrongFrameClass'), ...
    'check_referenceFrame: crystalSymmetry accepted a specimenFrame');
end
assert(all(abs(norm(cs.axes) - [3 3 5]) < 1e-10), ...
  'check_referenceFrame: the refused construction must leave the crystal axes alone');

ss = specimenSymmetry('222');

fname = [tempname '.mat'];
save(fname,'cs','ss');
S = load(fname);
delete(fname);

assert(all(abs(norm(S.cs.axes) - norm(cs.axes)) < 1e-10) && ...
  isa(S.cs,'crystalFrame') && strcmp(S.cs.name,'RoundTrip'), ...
  'check_referenceFrame: crystalSymmetry did not survive save/load');
assert(S.cs.how2plot == cs.how2plot, ...
  'check_referenceFrame: the how2plot override did not survive save/load');
assert(isa(S.ss,'specimenFrame') && ...
  S.ss.how2plot == ss.how2plot, ...
  'check_referenceFrame: specimenSymmetry did not survive save/load');

% loadobj re-interns: a default-conventioned frame comes back as the session
% instance in the group it was saved in, one with its own convention keeps
% its fork
assert(S.ss == ss, ...
  'check_referenceFrame: loadobj did not re-intern the saved sibling');
assert(S.ss ~= specimenFrame.default && isAligned(S.ss,specimenFrame.default), ...
  'check_referenceFrame: a group-carrying sibling came back as the session frame');
assert(specimenSymmetry == specimenFrame.default, ...
  'check_referenceFrame: the trivial group is not the session frame itself');

pCF = plottingConvention('z↑→x');
ssF = specimenSymmetry(pCF);
fname = [tempname '.mat'];
save(fname,'ssF');
S = load(fname);
delete(fname);
assert(S.ssF ~= specimenFrame.default && isapprox(S.ssF.how2plot,pCF), ...
  'check_referenceFrame: a loaded forked frame did not survive');

% a loaded container keeps the frame it was saved in and leaves the session alone
pC0e = plottingConvention.default;
restoreDefault = onCleanup(@() plottingConvention.default(pC0e));
ebsd = EBSD(vector3d.rand(4),rotation.rand(4,1),ones(4,1), ...
  {crystalSymmetry('m-3m')},struct());
ebsd.frame = specimenFrame.frameFor(pCF);
save(fname,'ebsd');
S = load(fname);
delete(fname);
assert(S.ebsd.frame ~= specimenFrame.default && S.ebsd.how2plot == pCF, ...
  'check_referenceFrame: a loaded EBSD did not keep the frame it was saved in');
assert(plottingConvention.default == pC0e, ...
  'check_referenceFrame: loading an EBSD must not change the session convention');
clear restoreDefault

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

function checkSessionReset
% referenceFrame.reset restores the pristine session frame state: the
% register forgets every named frame and the default falls back to a
% fresh generic specimen frame with the ij convention. The doc build resets
% between pages this way - resetting only the convention used to write
% ij into whatever frame was default, corrupting the registered rolling
% frame for every following page.

specimenFrame.rolling.makeDefault;
plottingConvention.default(plottingConvention.ij);   % the old corruption
rCorrupt = specimenFrame.rolling;
assert(isapprox(rCorrupt.how2plot,plottingConvention.ij), ...
  'check_referenceFrame: setup - the register frame should be mutated here');

referenceFrame.reset;

d = specimenFrame.default;
assert(strcmp(d.name,'specimen') && isapprox(d.how2plot,plottingConvention.ij), ...
  'check_referenceFrame: reset must fall back to the generic specimen frame / ij');

rFresh = specimenFrame.rolling;
assert(rFresh ~= rCorrupt && isapprox(rFresh.how2plot,plottingConvention('y←↑x')), ...
  'check_referenceFrame: reset must let rolling remint with its seed convention');

referenceFrame.reset;

end

function checkFrameCarriage
% derived data adopts the frame HANDLE of its source, never an
% equal-valued copy of the convention - otherwise it stops following the
% frame the source lives in and loses the axes names

referenceFrame.reset;

cs = crystalSymmetry('432');
ori1 = orientation.rand(cs); ori2 = orientation.rand(cs);
a = axis(ori1,ori2);
assert(a.frame == ori2.SS, ...
  'check_referenceFrame: the misorientation axis must carry the SS frame handle');

% orientation/map: a framed input hands its frame to the result's SS
fr = specimenFrame('lab','axesNames',{'A','B','C'},plottingConvention('y←↑x'));
v = vector3d.X; v.frame = fr;
ori = orientation.map(Miller(1,0,0,cs),v);
assert(ori.SS == fr, ...
  'check_referenceFrame: orientation.map must adopt the frame of the framed input');

% quadrature built results keep the frame of their input, so give the function one
s = S2Fun.smiley;
s.frame = specimenFrame.frameFor(plottingConvention('z↑→x'));
assert(getFrame(s.^2) == getFrame(s), ...
  'check_referenceFrame: S2Fun arithmetic must keep the frame of its input');
q = S2FunHarmonic.quadrature(@(v) v.x.^2,'bandwidth',16);
assert(isempty(getFrame(q)), ...
  'check_referenceFrame: a quadrature over plain nodes must stay frame-free');

% the gradient of an ODF keeps the specimen frame, stripSym drops only the point group
oriF = orientation.rand(10,cs);
oriF.SS = fr;
odfF = calcDensity(oriF,'halfwidth',20*degree);
assert(odfF.frameLeft == fr, ...
  'check_referenceFrame: calcDensity must keep the specimen frame');
gF = odfF.grad;
assert(gF.frameLeft == fr, ...
  'check_referenceFrame: SO3Fun/grad must keep the specimen frame');

referenceFrame.reset;

end

function checkTangentVectorFrames
% the frames of a vector field survive evaluation and tangent space
% conversion. eval runs through transformTangentSpace, which used to
% downcast the reference to a bare rotation and refabricate the dropped
% triclinic specimen symmetry from the session default - the main way
% frameLeft flipped to the session frame while running a doc page
% (ADR 0003: absence is empty, never fabricated)

referenceFrame.reset;

cs = crystalSymmetry('321');
fr = specimenFrame('lab','axesNames',{'A','B','C'},plottingConvention('y←↑x'));

ori = orientation.rand(20,cs);
ori.SS = fr;
odf = calcDensity(ori,'halfwidth',20*degree);
G = SO3FunHarmonic(odf).grad;
assert(G.frameLeft == fr, ...
  'check_referenceFrame: grad must keep the specimen frame');

% the tangent vector keeps the pair; its own frame is derived from the
% side it is expressed in
v = G.eval(ori(1));
ref = v.oriRef;
assert(ref.SS == fr, ...
  'check_referenceFrame: eval must keep the specimen frame on the tangent vector');
assert(v.frame == fr, ...
  'check_referenceFrame: a left tangent vector is expressed in the specimen frame');
assert(right(v).frame == cs, ...
  'check_referenceFrame: a right tangent vector is expressed in the crystal frame');

% an explicitly requested representation converts and keeps the frames
vR = G.eval(ori(1),SO3TangentSpace.rightVector);
ref = vR.oriRef;
assert(ref.SS == fr, ...
  'check_referenceFrame: a converted evaluation must keep the specimen frame');

% converting the intern representation rebuilds the inner harmonic from
% Wigner-D products - the components lose the groups but keep the frames
GR = right(G,'internTangentSpace');
assert(GR.frameLeft == fr, ...
  'check_referenceFrame: transformInternTangentSpace must keep the specimen frame');

referenceFrame.reset;

end

function checkTrivialSymmetryFromFrame
% frames convert to the trivial group carrying them - the enabling half of
% "orientation without symmetry" (ADR 0003): the constructors adopt the
% frame handle, and extractSym can report absence instead of fabricating a
% session-framed stand-in

referenceFrame.reset;

cs = crystalSymmetry('321',[4.9 4.9 5.4],'mineral','quartz');
t = crystalSymmetry(cs);
assert(t.id == 1, ...
  'check_referenceFrame: crystalSymmetry(frame) must be the trivial group');
assert(t == stripSym(cs) && isAligned(t,cs), ...
  'check_referenceFrame: crystalSymmetry(frame) must be the group-stripped sibling');
assert(strcmp(t.mineral,'quartz'), ...
  'check_referenceFrame: the mineral doubles as the frame identity');

sF = specimenFrame.rolling;
s = specimenSymmetry(sF);
assert(s.id == 1 && s == sF, ...
  'check_referenceFrame: specimenSymmetry(frame) must be that frame, which claims nothing');

% a deliberately passed trivial symmetry is indistinguishable from
% "absent" by its id, so it must survive construction with its frame
fr = sF;
VF = SO3VectorFieldHandle(@(r) vector3d.X .* angle(r), cs, specimenSymmetry(fr));
assert(VF.frameLeft == fr, ...
  'check_referenceFrame: a passed trivial specimen symmetry must survive the Handle ctor');
VFH = SO3VectorFieldHarmonic(VF,'bandwidth',16);
assert(VFH.frameLeft == fr, ...
  'check_referenceFrame: the trivial symmetry frame must survive quadrature into a harmonic field');

% extractSym: absence is representable
[a,b] = extractSym({},'empty');
assert(isempty(a) && isempty(b), ...
  'check_referenceFrame: extractSym ''empty'' must return empty for absent slots');
[a,b] = extractSym({t},'empty');
assert(~isempty(a) && a == t && isAligned(a,cs) && isempty(b), ...
  'check_referenceFrame: a passed symmetry fills only its slot');

% the default path fills both slots from the session frame, so they are one
% handle - which is what registering a frame is for
[a,b] = extractSym({});
assert(a == specimenFrame.default && b == specimenFrame.default, ...
  'check_referenceFrame: extractSym did not fill its slots from the session frame');

referenceFrame.reset;

end

% =========================================================================
function checkGridLayout
% a layout says which directions the two array indices advance along, in the
% order the array is written in: dimension 1 first. That is a relation to a
% basis and has nothing to do with a screen - a layout is what it is whether
% or not anything is ever plotted

referenceFrame.reset;
tol = 1e-6;

% the two-vector constructor stores what it is given, row direction first,
% and completes the right handed set itself - the third is not a free choice
gL = gridLayout(yvector,-xvector);
assert(angle(gL.basis(1),yvector) < tol && angle(gL.basis(2),-xvector) < tol, ...
  'check_referenceFrame: gridLayout(rowDir,colDir) lost the directions given');
assert(angle(gL.basis(3),cross(yvector,-xvector)) < tol, ...
  'check_referenceFrame: gridLayout did not complete a right handed basis');

% the default is what gridify stores a map in - rows along y
assert(isAligned(gridLayout,gridLayout.columnMajor) && ...
    angle(gridLayout.columnMajor.basis(1),yvector) < tol, ...
  'check_referenceFrame: the default layout is not columnMajor');

% a layout carries no plotting convention of its own - the only screen it
% could mean is the one imagesc imposes, which is not a property of the data
try
  gridLayout(yvector,xvector,plottingConvention.ij);
  caught = '';
catch ME
  caught = ME.identifier;
end
assert(strcmp(caught,'MTEX:gridLayout:noConvention'), ...
  'check_referenceFrame: a gridLayout must not carry a plotting convention');

% the two directions are vectors, so they state their own frame and the
% layout reads it off them rather than storing a second copy
fr = specimenFrame('layoutTest',plottingConvention.ij);
v1 = yvector; v1.frame = fr;
v2 = xvector; v2.frame = fr;
framed = gridLayout(v1,v2);
assert(framed.frame == fr, ...
  'check_referenceFrame: a gridLayout did not read its frame off its directions');
assert(isempty(gridLayout.columnMajor.frame), ...
  'check_referenceFrame: a layout built from bare directions must have no frame');

% directions in different frames are stated in different spaces, so the
% components cannot be compared - while a frame free layout compares to both
other = specimenFrame('layoutTest2',plottingConvention.ij);
w1 = yvector; w1.frame = other;
w2 = xvector; w2.frame = other;
assert(~isAligned(framed,gridLayout(w1,w2)), ...
  'check_referenceFrame: layouts in different frames were called aligned');
assert(isAligned(framed,gridLayout.columnMajor) && ...
    isAligned(gridLayout.columnMajor,framed), ...
  'check_referenceFrame: a frame free layout did not compare against a framed one');

% assumedFor reads the order off a frame, so the layout it returns is stated
% in that frame
assert(gridLayout.assumedFor(fr).frame == fr, ...
  'check_referenceFrame: assumedFor did not state the layout in the frame it read');

% rows and columns of an array are perpendicular; anything else is a
% mistake rather than a shear to be accommodated
try
  gridLayout(xvector,vector3d(1,1,0));
  caught = '';
catch ME
  caught = ME.identifier;
end
assert(strcmp(caught,'MTEX:gridLayout:notOrthogonal'), ...
  'check_referenceFrame: non-perpendicular row/col directions were accepted');

% assumedFor recovers the relation from a frame's convention - the
% backwards compatible path, for data that predates the relation having a
% home. It names itself so the assumption is visible wherever it is shown
for pC = axisAlignedConventions
  v = vector3d.X;
  v.frame = specimenFrame('test',pC{1});
  gL = gridLayout.assumedFor(v);
  assert(angle(gL.basis(1),pC{1}.south) < tol && angle(gL.basis(2),pC{1}.east) < tol, ...
    'check_referenceFrame: assumedFor did not return south/east for %s',char(pC{1}));
  assert(strcmp(gL.name,'assumed from plot'), ...
    'check_referenceFrame: assumedFor must say that it assumed');
end

referenceFrame.reset;

end

% =========================================================================
function checkLayoutIndex
% layoutIndex is what a layout is for: which transpose and flips lay a matrix
% out the way it says. The inverse is the same call with the two layouts
% swapped, which is what makes a separate back conversion unnecessary

referenceFrame.reset;

cm = gridLayout.columnMajor;
rm = gridLayout.rowMajor;
A  = reshape(1:12,3,4);

% the layout an array is already in asks for nothing
lin = layoutIndex(cm,[yvector xvector],size(A));
assert(isequal(A(lin),A), ...
  'check_referenceFrame: layoutIndex into the layout already held is not the identity');

% a quarter turn transposes, and says so - a caller with a pixel step has to
% swap it and the index cannot carry that
[lin,doTranspose] = layoutIndex(rm,[yvector xvector],size(A));
assert(isequal(A(lin),A.') && doTranspose, ...
  'check_referenceFrame: layoutIndex did not transpose for a quarter turn');

% every axis aligned layout is reachable, and swapping the two layouts is
% the way back
for pC = axisAlignedConventions
  tgt = gridLayout.assumedFor(specimenFrame('test',pC{1}));
  B = A(layoutIndex(tgt,[yvector xvector],size(A)));
  back = B(layoutIndex(cm,tgt.basis(1:2),size(B)));
  assert(isequal(back,A), ...
    'check_referenceFrame: layoutIndex is not its own inverse for %s',char(pC{1}));
end

% channels ride along, which a plain transpose could not do
A3 = cat(3,A,10*A);
B3 = A3(layoutIndex(rm,[yvector xvector],size(A3)));
assert(isequal(B3(:,:,1),A.') && isequal(B3(:,:,2),(10*A).'), ...
  'check_referenceFrame: layoutIndex lost the channels of an r × c × k array');

% only a signed permutation can be applied by reindexing, so a layout half
% way between two axes is refused rather than approximated
try
  layoutIndex(cm,[vector3d(1,1,0) vector3d(1,-1,0)],size(A));
  caught = '';
catch ME
  caught = ME.identifier;
end
assert(strcmp(caught,'MTEX:gridLayout:notAxisAligned'), ...
  'check_referenceFrame: a layout no permutation can reach was accepted');

% unless the caller says to take the closest one, which is what a grid does
r30 = rotation.byAxisAngle(zvector,30*degree);
lin = layoutIndex(cm,[r30*yvector r30*xvector],size(A),'nearest');
assert(isequal(A(lin),A), ...
  'check_referenceFrame: a 30 degree layout did not snap to the identity');

% a transposed layout has to stay the transpose of the layout it transposes,
% including at 45 degrees where nothing about the array can decide
for th = [0 30 45 60 90 135]*degree
  r = rotation.byAxisAngle(zvector,th);
  [~,trCol] = layoutIndex(cm,[r*yvector r*xvector],size(A),'nearest');
  [~,trRow] = layoutIndex(rm,[r*yvector r*xvector],size(A),'nearest');
  assert(trCol ~= trRow, ...
    'check_referenceFrame: rowMajor is not the transpose of columnMajor at %g degrees',...
    th./degree);
end

referenceFrame.reset;

end

% =========================================================================
function checkScreenAlignment
% orientation.byScreenAlignment turns "I plotted both and they were the same
% way up" into the rotation that assertion implies. It reads how2plot and
% never touches basis, which is what makes it safe for ESTABLISHING a basis
% that transformationMatrix then reproduces from the bases alone

referenceFrame.reset;
tol = 1e-6;

for pC = axisAlignedConventions

  sF = specimenFrame('test',pC{1});
  imgF = specimenFrame('image',plottingConvention.ij);

  % stated independently of the implementation's formula: if an image and a
  % map look the same way up, the image's x runs the way east runs and its y
  % the way south runs
  M = matrix(orientation.byScreenAlignment(imgF,sF));
  b = vector3d(M(1,:),M(2,:),M(3,:));
  assert(angle(b(1),pC{1}.east) < tol, ...
    'check_referenceFrame: byScreenAlignment x does not run east for %s',char(pC{1}));
  assert(angle(b(2),pC{1}.south) < tol, ...
    'check_referenceFrame: byScreenAlignment y does not run south for %s',char(pC{1}));
  assert(angle(b(3),-pC{1}.outOfScreen) < tol, ...
    'check_referenceFrame: byScreenAlignment depth is not into the screen for %s',char(pC{1}));

  % the two ways of asking are INVERSE, not equal, and that is not an
  % accident of either implementation: an @orientation is an ACTIVE
  % rotation, turning one direction into another, while transformationMatrix
  % is the PASSIVE transition, re-expressing one fixed direction in another
  % frame's coordinates. Six of the eight conventions are 180 degree
  % rotations and so are their own inverse, which hides the difference -
  % only the two 90 degree cases show it, so asserting equality would pass
  % six times and mean nothing
  % a frame of its own for the inferred basis: imgF was interned by
  % byScreenAlignment above, and a registered frame does not change
  bF = specimenFrame('inferred'); bF.basis = b;
  assert(norm(M.' - transformationMatrix(bF,sF)) < tol, ...
    'check_referenceFrame: the basis disagrees with the inference it was set from (%s)',...
    char(pC{1}));

end

% under ij an image and a map need no permutation at all, so the relation
% between their frames has to come out as the identity. If this ever fails,
% every array order derived from it is wrong
ori = orientation.byScreenAlignment(specimenFrame('image',plottingConvention.ij), ...
  specimenFrame('ij',plottingConvention.ij));
assert(angle(ori) < tol, ...
  'check_referenceFrame: ij must give the identity, it gave %.3f degrees',angle(ori)./degree);

% the orientation names both frames rather than only carrying a number
assert(isa(ori.frameA,'specimenFrame') && isa(ori.frameB,'specimenFrame'), ...
  'check_referenceFrame: byScreenAlignment must name both frames on the orientation');

% an empty convention means "follows the session default", so inferring
% from it would silently make the answer depend on session state
bare = specimenFrame('bare');
bare.how2plot = [];
try
  orientation.byScreenAlignment(specimenFrame('image',plottingConvention.ij),bare);
  caught = '';
catch ME
  caught = ME.identifier;
end
assert(strcmp(caught,'MTEX:orientation:noConvention'), ...
  'check_referenceFrame: a frame without a convention of its own was accepted');

referenceFrame.reset;

end

% =========================================================================
function pcs = axisAlignedConventions
% the eight axis-aligned conventions, as (outOfScreen, east) pairs

pcs = { plottingConvention(-vector3d.Z, vector3d.X), ...
        plottingConvention( vector3d.Z, vector3d.Y), ...
        plottingConvention( vector3d.Z, vector3d.X), ...
        plottingConvention(-vector3d.Z, vector3d.Y), ...
        plottingConvention(-vector3d.Z,-vector3d.X), ...
        plottingConvention( vector3d.Z,-vector3d.Y), ...
        plottingConvention( vector3d.Z,-vector3d.X), ...
        plottingConvention(-vector3d.Z,-vector3d.Y)};

end

% =========================================================================
function checkHemisphereSectorHue
% an IPF key over a hemisphere sector has to use the whole color wheel
%
% polarCoordinates measures the hue from sR.how2plot.outOfScreen by taking
% outOfScreen - center. For point group -1 the fundamental sector is a
% hemisphere, so its barycenter IS its pole - and the pole is exactly where
% outOfScreen points. The difference is then the zero vector, normalizing it
% gives NaN, and rho falls back to 0 for every direction: one single hue, an
% all red color key. The default -1 cell escaped only because its center is
% exactly zvector, which takes the other branch.

referenceFrame.reset;

cs = crystalSymmetry('-1',[8.1796 12.8747 14.1720],[93.1 115.9 91.2]*degree);

% -1 genuinely has no topologically correct key - a hemisphere with antipodal
% boundary identification is RP2 - so the note is expected here, not a failure
w = warning('off','MTEX:noTopologicalColorKey');
key = ipfHSVKey(cs);
warning(w);

sR = key.dirMap.sR;
assert(isscalar(sR.N) && isempty(sR.vertices), ...
  'check_referenceFrame: the -1 sector is expected to be a bare hemisphere');

% the center coinciding with outOfScreen is the trigger, so pin it down -
% if this stops holding the test below is no longer covering the bug
ctr = vector3d(key.dirMap.whiteCenter).normalize;
assert(angle(ctr,vector3d(sR.how2plot.outOfScreen)) < 1e-6, ...
  'check_referenceFrame: expected the hemisphere center to be the view direction');
assert(~(ctr == zvector), ...
  'check_referenceFrame: a skewed cell must not put the center on zvector');

v = equispacedS2Grid('resolution',7.5*degree);
v = v(sR.checkInside(v));
hue = rgb2hsv(key.dirMap.direction2color(v));
hue = hue(:,1);

assert(~any(isnan(hue)), ...
  'check_referenceFrame: the IPF key must not produce NaN colors');
assert(max(hue) - min(hue) > 0.9, ...
  ['check_referenceFrame: the IPF key of -1 collapsed to a single hue ' ...
  '(span ' xnum2str(max(hue)-min(hue)) ' of the color wheel)']);

referenceFrame.reset;

end

% =========================================================================
function checkFundamentalSectorFrame
% the fundamental sector of a crystal symmetry belongs to the CRYSTAL
% frame, so an inverse pole figure color does not depend on the session
%
% sphericalRegion/isUpper, restrict2Upper and polarCoordinates all read
% sR.how2plot, and the IPF key lays its colors over the sector with
% polarCoordinates. A frame free sector resolves against the session
% default instead, and then the color of a fixed orientation changes with
% plottingConvention.default - which it must never do.

referenceFrame.reset;
d0 = plottingConvention.default;

cs = crystalSymmetry('622',[3 3 4.7],'mineral','Titanium (Alpha)');
ori = orientation.byEuler([10 20 30]*degree,cs);

conv = {'y↑→x','y↓→x','x←↑y','z↑→x'};
rgb = zeros(numel(conv),3);
grd = zeros(numel(conv),3);

for k = 1:numel(conv)
  plottingConvention.default(conv{k});

  assert(cs.fundamentalSector.how2plot == cs.how2plot, ...
    'check_referenceFrame: the sector must carry the convention of the crystal frame');

  key = ipfColorKey(ori);
  key.ipfDirection = zvector;
  rgb(k,:) = key.orientation2color(ori);

  % the precomputed grid has to agree with the exact map, it is cached across a session
  keyG = ipfColorKey(ori);
  keyG.ipfDirection = zvector;
  keyG.precompute;
  grd(k,:) = keyG.orientation2color(ori);
end

plottingConvention.default(d0);

assert(max(max(abs(rgb - rgb(1,:)))) < 1e-10, ...
  'check_referenceFrame: the ipf color must not depend on the session convention');
assert(max(max(abs(grd - rgb))) < 0.05, ...
  'check_referenceFrame: the precomputed color grid must agree with the exact map');

referenceFrame.reset;

end

% =========================================================================
function checkProductDropsSymmetry
% a rotation that is not a symmetry element destroys the symmetry it acts
% on, and the product drops the group while keeping the frame
%
% Same policy as SO3Fun/rotate, and the same helper - see dropSymmetry. A
% rotation multiplied on the LEFT acts in the specimen frame and can only
% destroy the specimen symmetry; on the RIGHT it acts in the crystal frame.
%
% ensureSym used to keep the group and merely warn, and its membership test
% was dot_outer(sym.rot,rot) > 0.99 - a quaternion dot of 0.99 is a rotation
% angle of 16.2 degree, so any rotation up to sixteen degrees counted as a
% symmetry element and not even the warning fired. That is what broke
% doc/ODFAnalysis/DetectionOfSampleSymmetry.m: it rotates by 15.6 degree to
% destroy the sample symmetry deliberately, the claim survived, and
% centerSpecimen then "detected" nothing - it returned the identity, an
% error equal to the full applied rotation.

referenceFrame.reset;

CS = crystalSymmetry('cubic');
SS = specimenSymmetry('222');
fr = SS;
ori = orientation.byEuler(10*degree,20*degree,30*degree,CS,SS);

% left: the specimen symmetry goes, the crystal symmetry and the frame stay
rot = rotation.byEuler(15*degree,12*degree,-5*degree);
assert(angle(rot)/degree < 16.2, ...
  'check_referenceFrame: pick a rotation the old 0.99 threshold accepted');

l = rot * ori;
assert(l.SS.id == 1, ...
  'check_referenceFrame: a general rotation on the left must drop the specimen symmetry');
assert(l.SS == stripSym(fr) && isAligned(l.SS,fr), ...
  'check_referenceFrame: dropping the specimen symmetry must land on its stripped sibling');
assert(l.CS.id == CS.id, ...
  'check_referenceFrame: the left factor must not touch the crystal symmetry');

% right: the crystal symmetry goes instead
r = ori * rot;
assert(r.CS.id == 1 && r.SS.id == SS.id, ...
  'check_referenceFrame: a general rotation on the right must drop the crystal symmetry');
assert(r.CS == stripSym(CS) && isAligned(r.CS,CS), ...
  'check_referenceFrame: dropping the crystal symmetry must land on its stripped sibling');

% a genuine symmetry element changes nothing
k = SS.rot(2) * ori;
assert(k.SS.id == SS.id, ...
  'check_referenceFrame: a symmetry element must not drop the symmetry');

% and the membership test is a numerical tolerance, not sixteen degrees
noise = rotation.byAxisAngle(zvector,180*degree + 1e-9) * ori;
assert(noise.SS.id == SS.id, ...
  'check_referenceFrame: numerical noise must not drop the symmetry');
off = rotation.byAxisAngle(zvector,180.5*degree) * ori;
assert(off.SS.id == 1, ...
  'check_referenceFrame: half a degree off a symmetry element must drop it');

% misorientations are unaffected - both factors carry symmetry, so this
% goes through the frame fitting branch and not through the drop
o2 = orientation.byEuler(40*degree,50*degree,60*degree,CS,SS);
m = inv(ori) * o2;
assert(m.CS.id == CS.id && m.SS.id == CS.id, ...
  'check_referenceFrame: a misorientation must keep both crystal symmetries');

referenceFrame.reset;

end

% =========================================================================
function checkPlotS2GridFrame
% a plotting grid is a list of directions of the frame its region is given
% in, and passing a frame is the way to ask for one
%
% Without it the only way to get a grid of crystal directions was to cast
% the result, Miller(plotS2Grid('upper'),cs) - which does not merely tag the
% directions but reinterprets a grid built for the session convention as
% crystal directions, so the 'upper' hemisphere is the one the session
% happens to draw, not the one of the crystal frame.

referenceFrame.reset;
d0 = plottingConvention.default;

cs = crystalSymmetry('m-3m','mineral','Nickel');

plottingConvention.default('y↓→x');   % z into the screen, the opposite of
                                      % what a crystal frame does
v = plotS2Grid('resolution',10*degree,'upper',cs);

assert(isa(v.frame,'crystalFrame') && isAligned(v.frame,cs), ...
  'check_referenceFrame: plotS2Grid did not carry the frame it was given');

% 'upper' is the hemisphere the crystal frame draws, not the session one
assert(all(v.z(~isnan(v.x)) > -1e-10), ...
  'check_referenceFrame: plotS2Grid followed the session convention, not the frame');

% the region of a crystal symmetry brings its frame along by itself
w = plotS2Grid(cs.fundamentalSector,'resolution',10*degree);
assert(isa(w.frame,'crystalFrame') && isAligned(w.frame,cs), ...
  'check_referenceFrame: the grid of a crystal frame region is frame free');

% and a grid without any frame stays frame free
u = plotS2Grid('resolution',10*degree,'upper');
assert(isempty(u.frame), ...
  'check_referenceFrame: a plain plotting grid must not gain a frame');

plottingConvention.default(d0);
referenceFrame.reset;

end

% =========================================================================
function checkSchmidFactorFrames
% slipSystem/SchmidFactor warns exactly when the slip systems and the
% stress state live in different reference frames
%
% The guard used to ask for a crystal direction on one side only, so it
% caught a specimen stress tensor against crystal slip systems but was
% silent the other way round: rotating the systems (ori * sS) takes them
% into the specimen frame, and a crystal frame tensor then went through
% unnoticed and returned a Schmid factor computed across two frames. The tension direction branch had no
% check at all, so the same computation warned or not depending on whether
% it was written as a direction or as a uniaxial tensor.
%
% A direction that states no frame at all is a different case: it says
% nothing about where it belongs, so it is taken at face value and never
% warned about - vector3d.Z and every plotting grid are written that way.

referenceFrame.reset;

cs = crystalSymmetry('m-3m');
sS = slipSystem.fcc(cs);          % crystal frame
ori = orientation.byEuler(20*degree,30*degree,40*degree,cs);
sSr = ori * sS;                   % specimen frame - no longer indexed
assert(~isCrystalDirection(sSr.n), ...
  'check_referenceFrame: rotating slip systems is expected to leave the crystal frame');

sigmaS = stressTensor.uniaxial(vector3d.Z);   % specimen frame
sigmaC = rotate(sigmaS,inv(ori));             % crystal frame
r0 = vector3d.Z;                              % frame free direction
rS = vector3d.Z; rS.frame = specimenFrame.default;  % specimen direction
rC = Miller(0,0,1,cs);                        % crystal direction

% frame agrees -> silent, frame differs -> warns, on both branches
assertWarn(sS ,sigmaS,true ,'crystal systems / specimen tensor');
assertWarn(sS ,sigmaC,false,'crystal systems / crystal tensor');
assertWarn(sSr,sigmaS,false,'specimen systems / specimen tensor');
assertWarn(sSr,sigmaC,true ,'specimen systems / crystal tensor');
assertWarn(sS ,rS    ,true ,'crystal systems / specimen direction');
assertWarn(sS ,rC    ,false,'crystal systems / crystal direction');
assertWarn(sSr,rS    ,false,'specimen systems / specimen direction');
assertWarn(sSr,rC    ,true ,'specimen systems / crystal direction');

% a direction without a frame is never complained about, whichever frame
% the slip systems are in
assertWarn(sS ,r0    ,false,'crystal systems / frame free direction');
assertWarn(sSr,r0    ,false,'specimen systems / frame free direction');
assertWarn(sS ,plotS2Grid('resolution',20*degree,'upper'),false, ...
  'crystal systems / plain plotting grid');
assertWarn(sS ,plotS2Grid('resolution',20*degree,'upper',cs),false, ...
  'crystal systems / crystal frame plotting grid');

% the quadrature nodes of the no argument syntax are directions of the
% frame the quadrature runs in, so that branch must stay silent
lastwarn('');
SF = sS.SchmidFactor;
assert(isempty(lastwarn), ...
  'check_referenceFrame: SchmidFactor without argument must not warn about frames');

% and still be the Schmid factor - it is a degree 2 polynomial, so the
% bandwidth 4 expansion is exact
v = Miller(vector3d.rand(50),cs);
ref = dot(v,sS.n.normalize,'noSymmetry') .* dot(v,sS.b.normalize,'noSymmetry');
assert(max(abs(SF.eval(v) - ref)) < 1e-10, ...
  'check_referenceFrame: SchmidFactor without argument is not the Schmid factor');

% expressing the same stress state in either frame gives the same numbers
w = warning('off','MTEX:frameMismatch');
wCleanup = onCleanup(@() warning(w));
a = sS.SchmidFactor(sigmaC);
b = sSr.SchmidFactor(sigmaS);
assert(isequal(size(a),size(b)) && max(abs(a(:)-b(:))) < 1e-12, ...
  'check_referenceFrame: the Schmid factor depends on which frame it is computed in');

% a tension direction and the corresponding uniaxial tensor agree
assert(max(abs(sS.SchmidFactor(rC) - sS.SchmidFactor(stressTensor.uniaxial(rC)))) < 1e-12, ...
  'check_referenceFrame: tension direction and uniaxial stress tensor disagree');

referenceFrame.reset;

end

% -------------------------------------------------------------------------
function assertWarn(sS,ref,expected,name) %#ok<INUSD>
% call SchmidFactor and check whether it warned about the reference frame
%
% evalc keeps the expected warnings out of the test log - switching them off
% would also stop lastwarn from recording them, which is what is under test

lastwarn('');
evalc('sS.SchmidFactor(ref);');
[~,id] = lastwarn;
got = strcmp(id,'MTEX:frameMismatch');

if got ~= expected
  if expected, verb = 'did not warn'; else, verb = 'warned'; end
  error('check_referenceFrame: SchmidFactor %s for %s',verb,name);
end

end
