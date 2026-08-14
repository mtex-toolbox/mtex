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
% The contract, for every class here:
%
%   1. the convention is stored on the object, never written through to its
%      symmetry
%   2. an object that was never given one follows its symmetry, so setting
%      CS.how2plot keeps working
%   3. an explicitly set one wins over the symmetry's
%   4. it survives the operations that rebuild the object
%
% vector3d is the reference implementation - it has owned how2plot as a
% plain property all along.

checkTensor;
checkS2Fun;
checkTensorToS2Fun;

disp('check_plottingConventionOwnership: passed');

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
T.how2plot = pC;
assert(strcmp(char(T.how2plot),char(pC)), ...
  'check_plottingConventionOwnership: T.how2plot = pC did not take')

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

% (1) not written through to the symmetry, and no other function sees it
sF.how2plot = pC;
assert(strcmp(char(sF.how2plot),char(pC)), ...
  'check_plottingConventionOwnership: sF.how2plot = pC did not take')

assert(strcmp(char(sF.s.how2plot),dflt), ...
  'check_plottingConventionOwnership: sF.how2plot was written through to sF.s')

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

% (3) but one set on the function itself still wins
assert(strcmp(char(S2FunHarmonicSym(sF,cs).how2plot),char(pC)), ...
  ['check_plottingConventionOwnership: S2FunHarmonicSym(sF,cs) dropped the ' ...
  'convention that was set on sF'])

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
