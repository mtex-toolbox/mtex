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

disp('check_symmetryCompare passed')
end
