function check_SO3VectorFieldApprox
% approximating an SO3 vector field - interpolate, and SO3VectorFieldRBF
%
% Split off from core/check_SO3TangentVectors, which owns the algebraic side
% of vector fields - tangent space conversions, curl, div, antiderivative,
% rotate, quadrature. This file owns the question of how well a
% representation fits a field it was not built from.
%
% It is in slow/ for cost, not for using real data: building the RBF field
% takes 11 s, the norm against it another 7 s, and the interpolation round
% trip 13 s, because each one runs an mlsq fit to convergence. That is 32 s
% against the 9 s of everything in the core file, and the core tier is held
% to 60 s in total.
%
% Every tolerance here is a relative 1e-2 or looser, and that is the point -
% these are approximations. Where a quantity is exact it is checked as
% exact; see the two symmetry invariances below, which differ by twelve
% orders of magnitude for a reason.
%
% See also
% SO3VectorFieldRBF SO3VectorFieldHarmonic/interpolate check_SO3TangentVectors

rng(0)

f = SO3Fun.dubna;
f.SS = specimenSymmetry('222');

fix.f  = f;
fix.cs = f.CS;
fix.ss = f.SS;

checkInterpolate(fix);
checkVectorFieldRBF(fix);

disp('check_SO3VectorFieldApprox: passed');

end

% =========================================================================
function checkInterpolate(fix)
% interpolating a field through its values on a quadrature grid returns it
%
% Measured a relative 8.3e-3 - this is a least squares fit at bandwidth 23
% to a field that is not bandlimited there, so it is genuinely an
% approximation and the tolerance says so. It is not rounding.

N = 23;
g = fix.f.grad;
g.bandwidth = N;

q = quadratureSO3Grid(N,fix.cs);
rot = q.fullGrid;
val = right(g.eval(rot));

h = SO3VectorFieldHarmonic.interpolate(rot,val,SO3TangentSpace.leftVector, ...
  'regularization',0,'bandwidth',N,'weights',q.weights,fix.cs,fix.ss);

d = norm(norm(h-g)) / norm(norm(h));
assert(d < 2e-2, ...
  'check_SO3VectorFieldApprox: interpolate does not return the field, relative %.3g',d)

end

% =========================================================================
function checkVectorFieldRBF(fix)
% the radial basis representation of the same field
%
% Measured: 5.1e-3 for the approximation itself, 2.1e-3 for the
% interpolation round trip.
%
% Note the asymmetry in the two invariance checks. Undoing the right
% symmetry is exact (2.0e-14) while undoing the left one is only good to
% 1.4e-2: the RBF fit does not reproduce the left symmetry of the field to
% better than its own approximation error. That is a property of the
% representation, not a bug, which is why the two tolerances differ - a
% single loose one would stop the exact side from ever failing.

g1 = SO3VectorFieldRBF(fix.f.grad);
g2 = g1.right;

d = norm(norm(fix.f.grad - g1)) ./ norm(norm(fix.f.grad));
assert(d < 2e-2, ...
  'check_SO3VectorFieldApprox: the RBF field does not approximate the gradient (%.3g)',d)

rot = g1.SO3F.center;
h = SO3VectorFieldRBF.interpolate(rot,g1.eval(rot),SO3TangentSpace.leftVector, ...
  fix.cs,fix.ss);
d = norm(norm(h-g1)) / norm(norm(g1));
assert(d < 1e-2, ...
  'check_SO3VectorFieldApprox: the RBF interpolation round trip is off by %.3g',d)

r1 = orientation.rand(crystalSymmetry,fix.ss);
r2 = orientation.rand(fix.cs);

e = r1.symmetrise.inv .* g1.eval(r1.symmetrise);
assert(norm(norm(e-e(1))) < 5e-2, ...
  'check_SO3VectorFieldApprox: the RBF field breaks its left symmetry by %.3g', ...
  norm(norm(e-e(1))))

e = r2.symmetrise .* g2.eval(r2.symmetrise);
assert(norm(norm(e-e(1))) < 1e-10, ...
  ['check_SO3VectorFieldApprox: the RBF field breaks its right symmetry by ' ...
   '%.3g - this one is exact, unlike the left'], norm(norm(e-e(1))))

d = norm(norm( g1.eval(r1) - left(g2.eval(r1)) ));
assert(d < 1e-10, ...
  'check_SO3VectorFieldApprox: the RBF field differs between left and right by %.3g',d)

end
