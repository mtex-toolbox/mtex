function check_plottingConventionOwnership
% who owns how2plot, and that setting it never reaches anything else
%
% symmetry is a handle class, and the classes that carry data take one as a
% property default - specimenSymmetry.default, a single object shared by
% every instance. So any class that stores its plotting convention *on* its
% symmetry silently repoints the frame of every other object holding that
% same symmetry. This has been found and fixed at least five times now, in
% orientation, in grain2d/grain3d meanOrientation, in tensor and in S2Fun,
% which is why it gets a test of its own rather than one per class.
%
% The contract, for every class here (only frames carry conventions, and
% since the how2plot setters were removed a frame is the only way to give
% an object one):
%
%   1. giving an object a frame reaches nothing else - not a shared frame,
%      not a shared symmetry, not the next object of that class
%   2. an object that was never given one follows its symmetry's frame,
%      so editing that frame keeps working
%   3. symmetrising or attaching a symmetry puts the object into the
%      frame of that symmetry
%   4. an own frame survives the operations that rebuild the object

checkTensor;
checkS2Fun;
checkTensorToS2Fun;
checkOrientationMap;
checkPoleFigure;
checkSymmetryOverride;
checkOptionBeatsData;
checkTensorFollowsSession;

disp('check_plottingConventionOwnership: passed');

end

% =========================================================================
function checkSymmetryOverride
% since ADR 0003 a symmetry delegates how2plot to the referenceFrame it
% holds; setting it forks that frame. copy() is shallow, so the copy
% shares the frame handle - a naive forwarding setter would write the
% convention through that shared frame and repoint the original, which
% is exactly the leak family this file guards against.

pC = plottingConvention('z↑→x');
dflt = char(specimenSymmetry.default.how2plot);
assert(~strcmp(dflt,char(pC)), ...
  ['check_plottingConventionOwnership: the test convention equals the ' ...
  'default one, so it cannot detect a leak - pick another one'])

% the fork idiom: the copy shares the frame, the override stays local
ss = specimenSymmetry('222');
before = char(ss.how2plot);
ss2 = copy(ss);
assert(ss2.frame == ss.frame, ...
  'check_plottingConventionOwnership: copy(ss) does not share the frame handle')

ss2.frame = specimenSymmetry.frameFor(pC);
assert(strcmp(char(ss2.how2plot),char(pC)), ...
  'check_plottingConventionOwnership: giving ss2 a frame did not take')
assert(ss2.frame ~= ss.frame, ...
  'check_plottingConventionOwnership: setting the convention must fork the frame')
assert(strcmp(char(ss.how2plot),before) && ...
  strcmp(char(ss.frame.how2plot),before), ...
  'check_plottingConventionOwnership: ss2.how2plot wrote through the shared frame')
assert(strcmp(char(specimenSymmetry.default.how2plot),dflt), ...
  'check_plottingConventionOwnership: ss2.how2plot changed specimenSymmetry.default')

% same on the crystal side, incl. the cached Laue group sharing the frame
% (a non-centrosymmetric group, so that Laue is a copy and not cs itself)
cs = crystalSymmetry('432');
csBefore = char(cs.how2plot);
csL = cs.Laue;
assert(csL ~= cs, ...
  'check_plottingConventionOwnership: pick a group that is not its own Laue group')
assert(csL.frame == cs.frame, ...
  'check_plottingConventionOwnership: the Laue group does not share the frame')

csL.frame = specimenSymmetry.frameFor(pC);
assert(strcmp(char(cs.how2plot),csBefore) && ...
  strcmp(char(cs.frame.how2plot),csBefore), ...
  'check_plottingConventionOwnership: cs.Laue.how2plot wrote through the shared frame')

% the default workflow: a symmetry without an override holds the session
% frame, and plotx2north writes the new convention onto that frame - the
% symmetry follows without any shared convention handle (the convention
% is a value class)
pCd0 = plottingConvention.default;   % a value snapshot
restoreDefault = onCleanup(@() plottingConvention.default(pCd0));

ssd = specimenSymmetry;
assert(ssd.frame == specimenFrame.default, ...
  'check_plottingConventionOwnership: a fresh specimenSymmetry does not hold the session frame')

plotx2north
assert(plottingConvention.default ~= pCd0, ...
  'check_plottingConventionOwnership: plotx2north did not change the default')
assert(ssd.how2plot == plottingConvention.default, ...
  'check_plottingConventionOwnership: plotx2north did not reach the fresh specimenSymmetry')

end

% =========================================================================
function checkTensor

M = diag([3 1 -1]);
pC = plottingConvention('y↑→x');

dflt = char(tensor(M,'rank',2).how2plot);
assert(~strcmp(dflt,char(pC)), ...
  ['check_plottingConventionOwnership: the test convention equals the ' ...
  'default one, so it cannot detect a leak - pick another one'])

% (1) nothing else may see it, neither a later tensor, nor the shared
% default, nor this tensor's own CS
T = tensor(M,'rank',2);
T.frame = specimenSymmetry.frameFor(pC);
assert(strcmp(char(T.how2plot),char(pC)), ...
  'check_plottingConventionOwnership: giving T a frame did not take')

assert(strcmp(char(tensor(M,'rank',2).how2plot),dflt), ...
  'check_plottingConventionOwnership: T.how2plot leaked into the next tensor')

assert(strcmp(char(specimenSymmetry.default.how2plot),dflt), ...
  'check_plottingConventionOwnership: T.how2plot changed specimenSymmetry.default')

assert(strcmp(char(T.CS.how2plot),dflt), ...
  'check_plottingConventionOwnership: T.how2plot was written through to T.CS')

% (2) a tensor that was never given one follows its symmetry
cs = crystalSymmetry('mmm');
assert(strcmp(char(tensor(M,'rank',2,cs).how2plot),char(cs.how2plot)), ...
  'check_plottingConventionOwnership: a tensor without its own convention ignores CS')

% (4) rebuilding operations keep it. EinsteinSum has a branch that builds a
% fresh tensor instead of reusing the input, which used to get the
% convention for free off CS
T = tensor(M,'rank',2,pC);
T2 = EinsteinSum(T,[1 -1],vector3d.X,-1);
assert(strcmp(char(T2.how2plot),char(pC)), ...
  'check_plottingConventionOwnership: EinsteinSum dropped the convention')

end

% -------------------------------------------------------------------------
function checkS2Fun

pC = plottingConvention('z↑→x');
sF = S2FunHarmonic.quadrature(@(v) v.x);

dflt = char(sF.how2plot);
assert(~strcmp(dflt,char(pC)), ...
  ['check_plottingConventionOwnership: the test convention equals the ' ...
  'default one, so it cannot detect a leak - pick another one'])

% (1) setting the convention forks the function's frame and must not
% touch the session frame or the default
sF.frame = specimenSymmetry.frameFor(pC);
assert(strcmp(char(sF.how2plot),char(pC)), ...
  'check_plottingConventionOwnership: giving sF a frame did not take')

assert(sF.frame ~= specimenFrame.default && ...
  strcmp(char(specimenFrame.default.how2plot),dflt), ...
  'check_plottingConventionOwnership: the convention was written through the session frame')

assert(strcmp(char(S2FunHarmonic.quadrature(@(v) v.x).how2plot),dflt), ...
  'check_plottingConventionOwnership: sF.how2plot leaked into the next S2Fun')

assert(strcmp(char(specimenSymmetry.default.how2plot),dflt), ...
  'check_plottingConventionOwnership: sF.how2plot changed specimenSymmetry.default')

% (2) attaching a symmetry puts the function into the frame of that
% symmetry - a crystalSymmetry derives its own convention from its axes
cs = crystalSymmetry('m-3m');
assert(~strcmp(char(cs.how2plot),dflt), ...
  ['check_plottingConventionOwnership: m-3m has the default convention, ' ...
  'so this cannot tell the two apart'])

plain = S2FunHarmonic.quadrature(@(v) v.x);
assert(strcmp(char(S2FunHarmonicSym(plain,cs).how2plot),char(cs.how2plot)), ...
  ['check_plottingConventionOwnership: S2FunHarmonicSym(sF,cs) does not ' ...
  'follow cs - it pinned the frame sF merely inherited from its old symmetry'])

% (3) symmetrising puts the function into the frame of cs - a
% convention the function carried before is superseded
assert(strcmp(char(S2FunHarmonicSym(sF,cs).how2plot),char(cs.how2plot)), ...
  ['check_plottingConventionOwnership: S2FunHarmonicSym(sF,cs) must land ' ...
  'in the frame of cs'])

end

% -------------------------------------------------------------------------
function checkTensorToS2Fun
% the convention has to reach the S2Fun a tensor turns into, since that is
% what plotting reads - @S2FunHarmonicSym/plot used to override it with the
% one of the symmetry

pC = plottingConvention('z↑→x');
T = tensor(diag([3 1 -1]),'rank',2,pC);

assert(strcmp(char(T.directionalMagnitude.how2plot),char(pC)), ...
  'check_plottingConventionOwnership: directionalMagnitude dropped the convention')

% and all the way into the projection the plot is actually built with
close all
plot(T)
sP = getappdata(gca,'sphericalPlot');
close all

assert(~isempty(sP) && strcmp(char(sP.proj.pC),char(pC)), ...
  'check_plottingConventionOwnership: plot(T) did not use the convention of T')

end

% -------------------------------------------------------------------------
function checkOrientationMap
% orientation.map translates the conventions of its vector arguments onto
% the orientation (a20c992ee) - but it used to do so by writing through
% shared symmetry handles: through specimenSymmetry.default when no
% symmetry was passed, and through the caller's own symmetry when one was

pC = plottingConvention('z↑→x');
dflt = char(specimenSymmetry.default.how2plot);
assert(~strcmp(dflt,char(pC)), ...
  ['check_plottingConventionOwnership: the test convention equals the ' ...
  'default one, so it cannot detect a leak - pick another one'])

% two plain vector3d arguments carrying a non-default convention
fr = specimenSymmetry.frameFor(pC);
u = vector3d.X; u.frame = fr;
v = vector3d.Z; v.frame = fr;
ori = orientation.map(u,v);

% the orientation carries the convention on both sides...
assert(strcmp(char(ori.CS.how2plot),char(pC)) && ...
  strcmp(char(ori.SS.how2plot),char(pC)), ...
  'check_plottingConventionOwnership: orientation.map dropped the convention')

% ...and the shared default is untouched
assert(strcmp(char(specimenSymmetry.default.how2plot),dflt), ...
  'check_plottingConventionOwnership: orientation.map repointed specimenSymmetry.default')

% a caller-passed symmetry must not be written on either
ss = specimenSymmetry('222');
ssPC = char(ss.how2plot);
h = Miller(1,0,0,crystalSymmetry('m-3m'));
ori = orientation.map(h,v,ss);

assert(strcmp(char(ori.SS.how2plot),char(pC)), ...
  'check_plottingConventionOwnership: orientation.map(h,v,ss) dropped the convention')

assert(strcmp(char(ss.how2plot),ssPC), ...
  'check_plottingConventionOwnership: orientation.map wrote the convention onto the caller''s ss')

% the fork still compares equal to what was passed - @symmetry/eq is id based
assert(ori.SS == ss, ...
  'check_plottingConventionOwnership: the forked SS no longer compares equal to ss')

end

% -------------------------------------------------------------------------
function checkPoleFigure
% PoleFigure.SS defaults to one shared class-default specimenSymmetry
% instance, and set.how2plot used to write the convention through it -
% reaching every pole figure that never set an SS of its own

pC = plottingConvention('z↑→x');
cs = crystalSymmetry('m-3m');
h = Miller(1,0,0,cs);
r = vector3d.rand(10);
pf = PoleFigure(h,r,ones(10,1));

% a convention assigned to data is a session change now, and it says so.
% This block used to assert the opposite - that the assignment forked a
% private frame for this pole figure alone. That capability is gone: a
% convention belongs to a reference frame, and an anonymous fork carrying
% the session frame's name while following nothing was the leak family
% itself (ADR 0003).
pC0 = plottingConvention.default;
restore = onCleanup(@() plottingConvention.default(pC0));

assert(~(pC0 == pC), ...
  ['check_plottingConventionOwnership: the test convention equals the ' ...
  'default one, so it cannot detect anything - pick another one'])

lastwarn('','');
ws = warning('off','all');
pf.frame = specimenSymmetry.frameFor(pC);
warning(ws);
[~,id] = lastwarn;

assert(strcmp(id,'MTEX:plottingConvention:global'), ...
  'check_plottingConventionOwnership: assigning a convention to data must warn')

assert(plottingConvention.default == pC, ...
  'check_plottingConventionOwnership: the assignment must change the session')

% everything that follows the session follows along - including the pole
% figure itself and its specimen symmetry, which is what used to fork
assert(pf.how2plot == pC && pf.SS.how2plot == pC, ...
  'check_plottingConventionOwnership: the pole figure does not follow the session')

pf2 = PoleFigure(h,r,ones(10,1));
assert(pf2.how2plot == pC, ...
  'check_plottingConventionOwnership: a new pole figure does not follow the session')

clear restore

end

% =========================================================================
function checkOptionBeatsData
% the 'how2plot' plot option outranks the convention of the data
%
% Every plot method appends the convention of its own data AFTER varargin
%
%   newMapPlot(...,varargin{:},ebsd.how2plot,ebsd.pos.frame)
%
% meaning it as the fallback for this plot. plottingConvention.fromOption
% used to take a bare @plottingConvention before it looked at the name
% value form, so that fallback beat the option the caller had typed and
%
%   plot(ebsd,ebsd.orientations,'how2plot','y←↑x')
%
% silently drew the map in the convention of the data instead.

data = plottingConvention('y↑→x');
want = plottingConvention('y←↑x');
other = plottingConvention('z↑→x');

% the option the caller typed wins over the appended fallback
list = {'how2plot','y←↑x','refFrame','on',data};
assert(plottingConvention.fromOption(list,plottingConvention.default) == want, ...
  'check_plottingConventionOwnership: the how2plot option must beat the data convention');

% a @plottingConvention accepted as an object too
list = {'how2plot',want,data};
assert(plottingConvention.fromOption(list,plottingConvention.default) == want, ...
  'check_plottingConventionOwnership: how2plot must accept a plottingConvention');

% without the option the appended fallback applies, which is what makes
% plots follow their data at all
assert(plottingConvention.fromOption({data},plottingConvention.default) == data, ...
  'check_plottingConventionOwnership: without the option the data convention applies');

% a bare convention the CALLER passed still wins over the appended one -
% getClass returns the first match
assert(plottingConvention.fromOption({other,data},plottingConvention.default) == other, ...
  'check_plottingConventionOwnership: a caller passed convention must beat the appended one');

% and an empty list falls through to the default
assert(plottingConvention.fromOption({},other) == other, ...
  'check_plottingConventionOwnership: an empty list must return the default');

end

% =========================================================================
function checkTensorFollowsSession
% a freshly built tensor follows the CURRENT session frame
%
% @tensor declared its reference system as a property default,
% CS = specimenSymmetry.default. MATLAB evaluates a property default
% expression ONCE, when the class is first loaded, so that froze whichever
% symmetry handle was the default at the time. Every later
% specimenFrame.default / referenceFrame.reset installs a new session
% frame, which the frozen handle never sees, and a new tensor reported the
% convention the session had BEFORE the last change - one step behind,
% while @vector3d and @S2Fun, which resolve lazily in their getters, were
% right. The constructor resolves it now.

referenceFrame.reset;

follows = @() tensor.eye.how2plot == plottingConvention.default;

assert(follows(), ...
  'check_plottingConventionOwnership: a tensor must follow a fresh session');

specimenFrame.rolling.makeDefault;
assert(follows(), ...
  'check_plottingConventionOwnership: a tensor must follow makeDefault');

referenceFrame.reset;
assert(follows(), ...
  'check_plottingConventionOwnership: a tensor must follow referenceFrame.reset');

plottingConvention.default('z↑→x');
assert(follows(), ...
  'check_plottingConventionOwnership: a tensor must follow a convention change');

% an explicitly given symmetry still wins over the session, and a crystal
% framed tensor keeps the convention of its crystal frame
cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942]);
T = tensor.eye(cs);
assert(T.CS.id == cs.id, ...
  'check_plottingConventionOwnership: an explicit symmetry must survive');
assert(T.how2plot == cs.how2plot, ...
  'check_plottingConventionOwnership: a crystal framed tensor follows its crystal frame');

% a tensor built FROM crystal data is in crystal coordinates and keeps that
% symmetry - the session default must not overwrite what the data brought.
% This is the route slipSystem/deformationTensor takes into calcTaylor,
% where a specimen framed deformation tensor makes the Taylor spin come
% back in the wrong frame
m = Miller(1,1,0,crystalSymmetry('432'));
assert(isa(tensor(m).CS,'crystalSymmetry'), ...
  'check_plottingConventionOwnership: tensor(Miller) must keep the crystal symmetry');
assert(isa(dyad(m.normalize,Miller(1,-1,1,m.CS).normalize).frame,'crystalFrame'), ...
  'check_plottingConventionOwnership: dyad of Miller directions must be crystal framed');
sS = slipSystem.bcc(crystalSymmetry('432'));
assert(isa(sS.deformationTensor.frame,'crystalFrame'), ...
  'check_plottingConventionOwnership: a slip system deformation tensor is crystal framed');

referenceFrame.reset;

end
