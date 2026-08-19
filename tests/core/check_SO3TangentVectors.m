function check_SO3TangentVectors
% tangent spaces and SO3 vector fields - curl, div, antiderivative, rotate
%
% Converted from tests/check_SO3TangentVectors_and_VectorFields.m, which
% printed a bare norm(...) per check for a human to read and asserted
% nothing. It also died part way through on #2587 - fixed since - so the
% quadrature variants, the interpolate check and the whole SO3VectorFieldRBF
% section had never run at all.
%
% The gradient of an ODF itself is deliberately not checked here:
% check_odfGrad owns that, across SO3FunHarmonic, SO3FunRBF and SO3FunCBF,
% against a finite difference. What this file owns is what happens to a
% vector field once it exists - which tangent space it is expressed in, and
% whether curl, div, antiderivative, rotate, quadrature and interpolation
% agree with each other.
%
% What is here is the algebra: identities that hold exactly, up to rounding
% or to the accuracy of a harmonic operator. The approximation quality
% checks - interpolate, and the whole SO3VectorFieldRBF section - are in
% slow/check_SO3VectorFieldApprox, because building an RBF field costs 32 s
% against 9 s for everything below, and this tier is held to 60 s in total.
% That split is also the honest one: those are statements about how well a
% representation fits, tolerated at a relative 1e-2, while everything here
% is a contract that holds to 1e-7 or better.
%
% Tolerances are set from measured values with an order of magnitude of
% slack. Loosening them to a common value would hide real breakage - the
% tangent space conversions are exact to 4e-13 and have no business being
% checked at 1e-7.
%
% See also
% SO3VectorField SO3VectorFieldHarmonic SO3TangentSpace check_odfGrad
% check_SO3FunRotate check_SO3VectorFieldApprox

rng(0)

fix = fixture;

checkTangentSpaces(fix);
checkEvalSymmetry(fix);
checkCurlOfGradient(fix);
checkAntiderivative(fix);
checkDivergence(fix);
checkRotateCommutes(fix);
checkCurlIdentity(fix);
checkQuadrature(fix);
checkEvalOnGrid(fix);
checkPairCarriage(fix);

disp('check_SO3TangentVectors: passed');

end

% =========================================================================
function fix = fixture
% one dubna gradient field, in all four tangent space representations
%
% built once - f.grad and the right/intern conversions are the dominant cost
% of this file, and every section below wants the same four fields

f = SO3Fun.dubna;
f.SS = specimenSymmetry('222');

fix.f  = f;
fix.cs = f.CS;
fix.ss = f.SS;

fix.g1 = f.grad;                              % left vector
fix.g2 = fix.g1.right;                        % right vector
fix.h1 = fix.g1.right('internTangentSpace');  % right, intern
fix.h2 = fix.h1.left;                         % back to left

% the same gradient at a fixed bandwidth, for the quadrature and the grid
% evaluation - both used to rebuild it, which is the single most expensive
% call in this file
fix.g20 = fix.g1;
fix.g20.bandwidth = 20;

end

% =========================================================================
function checkTangentSpaces(fix)
% converting between the tangent spaces must not move the field
%
% g1 -> h1 -> h2 is a round trip through the intern representation, so g1
% and h2 have to agree exactly; likewise g2 against h1. Measured 3.9e-13.

r1 = orientation.rand(fix.cs);
r2 = orientation.rand(crystalSymmetry,fix.ss);

d = max(norm(fix.g1.eval(r1.symmetrise) - fix.h2.eval(r1.symmetrise)));
assert(d < 1e-10, ...
  'check_SO3TangentVectors: left field and its intern round trip differ by %.3g',d)

d = max(norm(fix.g2.eval(r2.symmetrise) - fix.h1.eval(r2.symmetrise)));
assert(d < 1e-10, ...
  'check_SO3TangentVectors: right field and its intern form differ by %.3g',d)

end

% =========================================================================
function checkEvalSymmetry(fix)
% the field is symmetric, so evaluating it at symmetrically equivalent
% orientations gives the same tangent vector once the symmetry is undone
%
% For a left vector field the left symmetry is what has to be divided out,
% for a right field the right one. Both measured exactly 0.

r1 = orientation.rand(fix.cs);
r2 = orientation.rand(crystalSymmetry,fix.ss);

e = r2.symmetrise.inv .* fix.g1.eval(r2.symmetrise);
d = max(norm(e-e(1)));
assert(d < 1e-10, ...
  'check_SO3TangentVectors: the left field is not invariant under its symmetry (%.3g)',d)

e = r1.symmetrise .* fix.g2.eval(r1.symmetrise);
d = max(norm(e-e(1)));
assert(d < 1e-10, ...
  'check_SO3TangentVectors: the right field is not invariant under its symmetry (%.3g)',d)

end

% =========================================================================
function checkCurlOfGradient(fix)
% curl of a gradient is zero, in every tangent space representation
%
% Measured exactly 0 for all four. This is the cheapest real statement about
% curl there is, so it is worth having in all four representations rather
% than only the one.

fields = {fix.g1,fix.g2,fix.h1,fix.h2};
names = {'g1 (left)','g2 (right)','h1 (right intern)','h2 (left intern)'};

for k = 1:4
  c = norm(norm(fields{k}.curl));
  assert(c < 1e-8, ...
    'check_SO3TangentVectors: curl of the gradient field %s is %.3g, not zero', ...
    names{k}, c)
end

end

% =========================================================================
function checkAntiderivative(fix)
% the antiderivative of grad(f) is f again, up to the constant
%
% dubna integrates to 1, so grad has antiderivative f - 1 and the check adds
% it back. Measured 1.08e-9 against norm(f) = 2.26, i.e. a relative 5e-10.

F = SO3FunHarmonic(fix.f);
nF = norm(F);

fields = {fix.g1,fix.g2,fix.h1,fix.h2};
names = {'g1 (left)','g2 (right)','h1 (right intern)','h2 (left intern)'};

for k = 1:4
  d = norm(fields{k}.antiderivative + 1 - F) / nF;
  assert(d < 1e-7, ...
    ['check_SO3TangentVectors: the antiderivative of %s does not return f, ' ...
     'relative deviation %.3g'], names{k}, d)
end

end

% =========================================================================
function checkDivergence(fix)
% div does not depend on the representation, and matches its own finite
% difference
%
% The three harmonic forms agree to rounding (measured 0 and 4.6e-14). The
% 'check' form is a central difference with a default step of 0.05 degree,
% so it only agrees to a relative 5e-6 - that one is a tolerance on the
% finite difference, not on the code.

d1 = fix.g1.div;
n = norm(d1);

assert(norm(d1 - fix.g2.div) / n < 1e-10, ...
  'check_SO3TangentVectors: div differs between the left and the right field')
assert(norm(d1 - fix.h1.div) / n < 1e-10, ...
  'check_SO3TangentVectors: div differs between the vector and the intern form')

d = norm(d1 - fix.g1.div('check')) / n;
assert(d < 1e-4, ...
  ['check_SO3TangentVectors: the analytic divergence disagrees with its ' ...
   'finite difference by a relative %.3g'], d)

end

% =========================================================================
function checkRotateCommutes(fix)
% rotating a vector field commutes with taking the gradient
%
%   grad(rotate(f,q)) == rotate(grad(f),q)
%
% for a rotation from the left (specimen) and from the right (crystal), for
% both intern tangent space representations, and for the handle class as
% well as the harmonic one. Measured up to 6.4e-11 on a field of size 49.

fr = SO3FunHarmonic(SO3Fun.dubna);
fr.bandwidth = 8;
fr.CS = fix.cs;
fr = fr.symmetrise;

q = rotation.byAxisAngle(vector3d(1,2,3),37*degree);
r = orientation.rand(5,1,fix.cs,specimenSymmetry);

GL = fr.grad;
GR = right(GL,'internTangentSpace');

% rotating the function first is the reference
refL = left(rotate(fr,q).grad.eval(r));
refR = left(rotate(fr,q,'right').grad.eval(r));

tol = 1e-8;

cases = { ...
  'left  harmonic, left intern',  refL, left(rotate(GL,q).eval(r)); ...
  'left  harmonic, right intern', refL, left(rotate(GR,q).eval(r)); ...
  'left  handle, left intern',    refL, left(rotate(SO3VectorFieldHandle(GL),q).eval(r)); ...
  'left  handle, right intern',   refL, left(rotate(SO3VectorFieldHandle(GR),q).eval(r)); ...
  'right harmonic, left intern',  refR, left(rotate(GL,q,'right').eval(r)); ...
  'right harmonic, right intern', refR, left(rotate(GR,q,'right').eval(r)); ...
  'right handle, left intern',    refR, left(rotate(SO3VectorFieldHandle(GL),q,'right').eval(r)); ...
  'right handle, right intern',   refR, left(rotate(SO3VectorFieldHandle(GR),q,'right').eval(r))};

for k = 1:size(cases,1)
  d = max(norm(vector3d(cases{k,2}) - vector3d(cases{k,3})));
  assert(d < tol, ...
    ['check_SO3TangentVectors: rotate does not commute with grad for the ' ...
     '%s case, deviation %.3g'], cases{k,1}, d)
end

end

% =========================================================================
function checkCurlIdentity(fix)
% the curl of a right field, pushed to the left, is the curl of the left one
%
% r .* curl(g.right)(r) == curl(g)(r). Measured 3.5e-16 on a curl of size
% 0.39, so this one really is exact.

g = SO3VectorFieldHarmonic(SO3FunHarmonic.example.*[1,2,3]);
h = g.right.curl;

r = symmetrise(orientation.rand(fix.cs));

d = norm(norm( r .* h.eval(r) - vector3d(g.curl(r)) ));
assert(d < 1e-10, ...
  'check_SO3TangentVectors: the left and right curl disagree by %.3g',d)

end

% =========================================================================
function checkQuadrature(fix)
% every way of rebuilding a vector field from its values reproduces it
%
% Five entry points: from a quadrature grid and its values, from a plain
% list with explicit weights, from the spin tensor representation, from the
% field itself, and through the constructor. Measured 3.6e-15 to 1.2e-7
% against a field of norm 16.4; the loosest is the explicit-weights form.

g = fix.g20;
tol = 1e-5;

r = quadratureSO3Grid(20,fix.cs);
v = g.eval(r);
h = SO3VectorFieldHarmonic.quadrature(r,v,'bandwidth',20,fix.cs,fix.ss);
assertField(h,g,tol,'quadrature from a grid and its values')

w = r.weights;
v = g.eval(r.fullGrid);
h = SO3VectorFieldHarmonic.quadrature(v,'bandwidth',20,fix.cs,fix.ss,'weights',w);
assertField(h,g,tol,'quadrature from a list with explicit weights')

g.tangentSpace = 2;
r = quadratureSO3Grid(20,fix.cs);
v = g.eval(r);
h = SO3VectorFieldHarmonic.quadrature(r,v,'bandwidth',20,fix.cs,fix.ss, ...
  SO3TangentSpace.leftSpinTensor);
assertField(h,g,tol,'quadrature in the spin tensor representation')

gr = g.right;
h = right(left(SO3VectorFieldHarmonic.quadrature(gr),'internTangentSpace'));
assertField(h,gr,tol,'quadrature of the field itself')

h1 = SO3VectorFieldHarmonic(g);
h2 = SO3VectorFieldHarmonic(g.right);
assertField(h1,h2.left,tol,'the SO3VectorFieldHarmonic constructor')

end

% =========================================================================
function checkEvalOnGrid(fix)
% evaluating on a quadratureSO3Grid and on the same grid flattened to a
% plain list must give the same values
%
% The grid class has its own evaluation path (an FFT over the full grid),
% the list falls back to the generic one, and the two are easy to let drift
% apart. Measured 3.0e-7.

gr = fix.g20.right;

q = quadratureSO3Grid(23,crystalSymmetry,fix.ss);

d = max(norm(vector3d(gr.eval(q)) - vector3d(gr.eval(q(:)))));
assert(d < 1e-5, ...
  ['check_SO3TangentVectors: evaluating on a quadratureSO3Grid and on its ' ...
   'flat list differ by %.3g'], d)

end

% =========================================================================
function checkPairCarriage(fix)
% the symmetry pair rides along every reconstruction of a tangent vector.
% .rot exposes only one group (stripSym on the equivariant side, frame kept),
% so a path that rebuilds from .rot without passing the pair drops one
% symmetry silently - cat did exactly that: concatenating left vectors
% lost the specimen symmetry, right vectors the crystal symmetry.

r = orientation.rand(2,fix.cs,fix.ss);
v = fix.g1.eval(r);

ref = v.oriRef;
assert(ref.CS.id == fix.cs.id && ref.SS.id == fix.ss.id, ...
  'check_SO3TangentVectors: eval must keep both symmetries on the tangent vector');

w = [v(1); v(2)];
ref = w.oriRef;
assert(ref.CS.id == fix.cs.id && ref.SS.id == fix.ss.id, ...
  'check_SO3TangentVectors: cat must keep both symmetries');

u = transformTangentSpace(v,v.tangentSpace);
ref = u.oriRef;
assert(ref.CS.id == fix.cs.id && ref.SS.id == fix.ss.id, ...
  'check_SO3TangentVectors: a no-op tangent space transform must keep both symmetries');

% the vector's own frame is derived from the reference orientation:
% left vectors live in the specimen frame, right vectors in the crystal one
assert(v.frame == fix.ss.frame, ...
  'check_SO3TangentVectors: a left tangent vector is expressed in the specimen frame');
vr = right(v);
assert(vr.frame == fix.cs.frame, ...
  'check_SO3TangentVectors: a right tangent vector is expressed in the crystal frame');

end

% =========================================================================
function assertField(h,g,tol,what)
% two vector fields agree, relative to the size of the field

d = norm(norm(h-g)) / norm(norm(g));

assert(d < tol, ...
  'check_SO3TangentVectors: %s does not reproduce the field, relative %.3g', ...
  what, d)

end
