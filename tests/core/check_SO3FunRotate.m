function check_SO3FunRotate
% rotate(SO3Fun,...) must agree with rotating the equivalent function handle
%
% An SO3FunHandle wrapping F.eval is by construction the same function as F,
% so rotating the two has to give the same values. That makes the handle a
% reference implementation for every subclass at once - if a subclass rotates
% its own representation wrongly (its centers, its harmonic coefficients, its
% fibre) the two come apart.
%
% Converted from tests/SO3FunTests/check_SO3FunRotate.m, which computed
% exactly this error and printed it with fprintf('Error: %f \n',...) - and
% also left a bare norm(e) with no semicolon, so it echoed twice. No
% threshold, no assertion.
%
% Both sides are checked: 'right' post-multiplies, the default
% left-multiplies, and they use different symmetry pairs, so a subclass that
% confuses the two fails here.
%
% See also
% SO3Fun/rotate SO3FunHandle

% Everything here uses trivial symmetry, deliberately.
%
% Rotating a CS-symmetric function by an arbitrary rotation conjugates its
% symmetry group, and MTEX and the plain handle then disagree by 5 to 9
% percent - measured with CS 2, SS 3 and a rotation out of 4, where the
% result's CS becomes 4. That is the SO3Fun symmetry handling recorded in
% https://github.com/mtex-toolbox/mtex/issues/2585 (its items 1 and 2 are
% the same disagreement reached through conv and radon), not a defect in
% rotate. Forcing a non-trivial CS onto SO3FunBingham.example makes it fail
% the same way, which is item 5 of that issue.
%
% With trivial symmetry all four subclasses agree to machine precision - 4e-14
% or better - so this file pins the rotation arithmetic itself and leaves the
% symmetry question to #2585.
rng(0)

CS = crystalSymmetry('1');
SS = crystalSymmetry('1');
A  = crystalSymmetry('1');

RBF = SO3FunRBF(orientation.rand(200,CS,SS), ...
  SO3DeLaValleePoussinKernel('halfwidth',20*degree));

% one representative of every SO3Fun subclass that implements rotate
F1 = SO3FunHarmonic(RBF); F1.isReal = 1;
F2 = SO3FunBingham.example; F2.CS = CS; F2.SS = SS;
F4 = SO3FunCBF.example;     F4.CS = CS; F4.SS = SS;

cases = { ...
  'SO3FunHarmonic', F1; ...
  'SO3FunBingham',  F2; ...
  'SO3FunRBF',      RBF; ...
  'SO3FunCBF',      F4};

% 1e-6, not machine precision: SO3FunHarmonic evaluates through NFSOFT and
% lands about 1.7e-8 from the handle. Nothing here is a close call - a
% rotation that is genuinely wrong is off by 0.05 to 0.6 relative, as the
% symmetry cases above show, so this leaves two orders of margin either way.
tol = 1e-6;

for k = 1:size(cases,1)
  checkRotate(cases{k,1},cases{k,2},A,CS,SS,tol,'both');
end

% SO3FunSBF only on the left. rotate(SO3FunSBF,rot,'right') raises
% 'Not implemented yet' from SO3Fun/rotate.m:25 - an explicit gap rather
% than a defect, and the reason the original script never ran to completion:
% it looped over all five subclasses with the right sided case first and
% threw there.
%
% Its symmetries are left as the example defines them; forcing CS/SS onto it
% the way the other four are set up makes tensor/rotate warn that the
% symmetries do not match.
SBF = SO3FunSBF.example;
checkRotate('SO3FunSBF',SBF,SBF.SS,SBF.CS,SBF.SS,tol,'left');

disp('check_SO3FunRotate: passed');

end

% =========================================================================
function checkRotate(name,F,A,CS,SS,tol,which)

% the same function, but as a plain handle - the reference
H = SO3FunHandle(@(r) F.eval(r),F.CS,F.SS);

% -- right sided ----------------------------------------------------------
if strcmp(which,'both')
  rot = orientation.rand(A,CS);
  a = rotate(F,rot,'right');
  b = rotate(H,rot,'right');
  compare(name,'right',a,b,tol);
end

% -- left sided (the default) ---------------------------------------------
rot = orientation.rand(SS,A);
a = rotate(F,rot);
b = rotate(H,rot);
compare(name,'left',a,b,tol);

end

% =========================================================================
function compare(name,side,a,b,tol)

% a whole sample, not one orientation and its symmetric copies: SO3FunBingham
% is sharply peaked, so at a single random orientation both sides are ~0 and
% the comparison says nothing - which the vacuity guard below caught
r = orientation.rand(200,a.CS,a.SS);

va = a.eval(r(:));
vb = b.eval(r(:));

% relative to the size of the function, so that a large ODF is not held to a
% tighter standard than a small one
scale = max(1,max(abs(vb)));
err = max(abs(va - vb)) / scale;

assert(err < tol, ...
  'check_SO3FunRotate: %s, %s sided rotation differs from the handle by %.3g (relative, tolerance %.3g)', ...
  name, side, err, tol)

% the comparison has to have something to compare - a function that is
% constant zero would pass any of this
assert(max(abs(vb)) > 1e-6, ...
  'check_SO3FunRotate: %s, %s sided - the reference is zero everywhere', name, side)

end
