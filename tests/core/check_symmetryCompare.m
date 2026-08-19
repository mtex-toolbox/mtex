function check_symmetryCompare
% check eqTol / sim on symmetries
%
% @specimenSymmetry/specimenSymmetry.m used to compare obj1 against *itself*
% in both eqTol and sim (`obj1.Laue.id == obj1.Laue.id`), so any two specimen
% symmetries counted as equal. That made the SS check in
% SO3Fun/ensureCompatibleSymmetries.m a no-op, and arithmetic between two
% SO3Funs with different specimen symmetries was silently accepted.

% --- specimen symmetry: equal to itself, and to an equal point group
triclinic = specimenSymmetry('1');
ortho     = specimenSymmetry('mmm');
ortho2    = specimenSymmetry('mmm');

assert(eqTol(triclinic,triclinic),'a specimen symmetry must equal itself')
assert(eqTol(ortho,ortho2),'equal point groups must compare equal')
assert(sim(ortho,ortho2),'equal point groups must be similar')

% --- and NOT to a different point group
assert(~eqTol(triclinic,ortho),'''1'' and ''mmm'' must not compare equal')
assert(~sim(triclinic,ortho),'''1'' and ''mmm'' must not be similar')
assert(~eqTol(ortho,triclinic),'the comparison must be symmetric')

% --- crystal symmetry path is unaffected
cs = crystalSymmetry('432');
assert(eqTol(cs,cs),'a crystal symmetry must equal itself')
assert(~eqTol(cs,crystalSymmetry('222')),'different Laue groups must differ')

% --- the consequence: SO3Fun arithmetic must reject mismatched SS
odf = unimodalODF(orientation.rand(cs),'halfwidth',10*degree);
odfOrtho = odf; odfOrtho.SS = specimenSymmetry('mmm');

ok = false;
try %#ok<TRYNC>
  odf + odfOrtho;
  ok = true;
end
assert(~ok,'adding SO3Funs with different specimen symmetries must be rejected')

% while matching ones still work
odf + odf; %#ok<VUNUS>

checkPhaseIdentity;
checkS2FunCompatibility;

disp('check_symmetryCompare passed')
end

% ------------------------------------------------------------------------

function checkPhaseIdentity
% two phases that share a lattice are still two phases
%
% Regression test: phaseItem/eqTolPair opened with
% strcmpi(obj1.mineral,obj2.mineral). The fitSym that replaced it in
% ensureCompatibleSymmetries compares the Laue class and the reference
% frame, neither of which can tell two minerals apart when they share a
% lattice. It stayed invisible while @SO3Fun/ensureCompatibleSymmetries
% shadowed the free function; deleting that method let two ODFs of
% different phases combine silently.

ss = specimenSymmetry('222');
abc = [3.52 3.52 3.52];
csA = crystalSymmetry('m-3m',abc,'mineral','Nickel');
csB = crystalSymmetry('m-3m',abc,'mineral','Iron fcc');

a = unimodalODF(orientation.rand(csA,ss),'halfwidth',10*degree);
b = unimodalODF(orientation.rand(csB,ss),'halfwidth',10*degree);

ok = false;
try %#ok<TRYNC>
  a + b;
  ok = true;
end
assert(~ok,['check_symmetryCompare: two minerals that share a lattice are ' ...
  'still different phases and must not combine'])

% an unnamed symmetry makes no phase claim, so it still combines - the same
% rule the trivial group follows for the symmetry claim itself (ADR 0003)
csU = crystalSymmetry('m-3m',abc);
a + unimodalODF(orientation.rand(csU,ss),'halfwidth',10*degree); %#ok<VUNUS>

% and one phase on two independently built handles still combines
csA2 = crystalSymmetry('m-3m',abc,'mineral','Nickel');
a + unimodalODF(orientation.rand(csA2,ss),'halfwidth',10*degree); %#ok<VUNUS>

end

% ------------------------------------------------------------------------

function checkS2FunCompatibility
% combining spherical functions must not go through the SO3Fun shaped check
%
% Regression test: ensureCompatibleSymmetries fell through to obj1.CS for an
% S2Fun receiver, but ADR 0003 took CS / SS off the plain spherical
% functions - a symmetry, where there is one, is reached through getSym.
% S2FunMLS/cat and /subsasgn therefore failed outright with
% "Unrecognized method, property, or field 'CS' for class 'S2FunMLS'".

v = equispacedS2Grid('resolution',5*degree);
f1 = S2FunMLS(v,v.x);
f2 = S2FunMLS(v,v.y);

w = vector3d.rand(7);
d1 = f1.eval(w); d2 = f2.eval(w);

f = [f1;f2];
d = f.eval(w);
assert(isequal(size(d),[7 2]), ...
  'check_symmetryCompare: S2FunMLS/cat must concatenate, got size %s', ...
  mat2str(size(d)))
assert(max(abs(d(:,1)-d1)) < 1e-10 && max(abs(d(:,2)-d2)) < 1e-10, ...
  'check_symmetryCompare: S2FunMLS/cat changed the values')

% subsasgn takes the same route
g = f; g(1) = f2;
dg = g.eval(w);
assert(max(abs(dg(:,1)-d2)) < 1e-10, ...
  'check_symmetryCompare: S2FunMLS/subsasgn did not assign')

end
