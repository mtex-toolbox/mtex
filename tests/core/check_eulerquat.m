function check_eulerquat
% every rotation representation must round trip back to the same rotation
%
% Replaces a file that had rotted twice over: it built its sample with
% SO3Grid(100000,symmetry,symmetry), a constructor form that no longer
% exists, and everything after line 22 was unreachable behind a bare return,
% including the whole matrix branch. What survived tested one conversion,
% Euler in the Bunge convention, against a mean threshold of 0.999 - which a
% systematically wrong conversion of a small fraction of the sample would
% have passed.
%
% The representations are all the ones @rotation can be built from, except
% homochoric, which has its own file (check_homochoric). Each is checked
% elementwise, not on average.
%
% q and -q are the same rotation, so nothing is compared componentwise but
% by 1 - |dot|. The angle of a small rotation is checked on its own, since
% it is the one quantity a round trip cannot measure that way.
%
% See also
% quaternion/Euler rotation/byEuler quaternion/matrix rotation/byMatrix
% quaternion/Rodrigues rotation/byRodrigues check_homochoric

rng(0)

N = 2000;

% the tolerance is on 1 - |dot|, not on an angle - see assertSame
tol = 1e-13;

% a general sample plus the awkward ones: identity, and rotations at and near beta == 0
r = [rotation.rand(N); ...
  rotation.id; ...
  rotation.byEuler(30*degree,0,50*degree,'Bunge'); ...
  rotation.byEuler(200*degree,0,100*degree,'Bunge'); ...
  rotation.byEuler(30*degree,1e-8,50*degree,'Bunge'); ...
  rotation.byEuler(30*degree,pi,50*degree,'Bunge'); ...
  rotation.byAxisAngle(xvector,pi)];

checkEuler(r,tol);
checkMatrix(r,tol);
checkAxisAngle(r,tol);
checkRodrigues(r,tol);
checkImproper(tol);
checkSmallAngle;

disp('check_eulerquat: passed')

end

% =========================================================================
function checkEuler(r,tol)
% every Euler convention MTEX offers

for conv = {'Bunge','ABG','Matthies','Roe','Kocks','Canova'}

% at beta == 0 only alpha + gamma is determined, and Kocks and Canova redefine gamma (#2583)
  [a,b,c] = Euler(r,conv{1});
  back = rotation.byEuler(a,b,c,conv{1});

  assertSame(r,back,tol,sprintf('the %s Euler',conv{1}))

end

end

% =========================================================================
function checkMatrix(r,tol)

M = matrix(r);
back = rotation.byMatrix(M);

assertSame(r,back,tol,'the matrix')

% and the matrices really are rotation matrices
for k = 1:20:size(M,3)
  assert(max(abs(M(:,:,k)*M(:,:,k).' - eye(3)),[],'all') < 1e-12, ...
    'check_eulerquat: matrix() returned a non orthogonal matrix at %d',k)
end

end

% =========================================================================
function checkAxisAngle(r,tol)

back = rotation.byAxisAngle(axis(r),angle(r));

assertSame(r,back,tol,'the axis/angle')

end

% =========================================================================
function checkRodrigues(r,tol)
% the Rodrigues vector runs to infinity at 180 degree, so those are excluded
% rather than pretended to work

keep = angle(r) < pi - 1e-3;
rr = r(keep);

back = rotation.byRodrigues(Rodrigues(rr));

assertSame(rr,back,tol,'the Rodrigues')

assert(nnz(keep) > 0.9*length(r), ...
  'check_eulerquat: too much of the sample was excluded from the Rodrigues check')

end

% =========================================================================
function checkImproper(tol)
% an improper rotation has to survive the matrix round trip as improper -
% the sign of the determinant is not carried by the quaternion itself

r = rotation.inversion * rotation.rand(200);
assert(all(r.isImproper), 'check_eulerquat: the sample is not improper')

back = rotation.byMatrix(matrix(r));

assert(all(back.isImproper), ...
  'check_eulerquat: the matrix round trip lost the improper flag')

assertSame(r,back,tol,'the improper matrix')

end

% =========================================================================
function checkSmallAngle
% angle keeps every digit of a small rotation, from one quaternion and from
% the chord between two, and so near pi, at the identity and for q against -q

omega = [1e-12 1e-9 1e-6 1e-3 1e-1];
ax = normalize(vector3d(1,2,3));
r = rotation.byAxisAngle(ax,omega);

assert(all(abs(angle(r) - omega) <= 1e-12*omega), ...
  'check_eulerquat: angle(r) loses a small angle')
assert(all(abs(angle(r,rotation.id) - omega) <= 1e-12*omega), ...
  'check_eulerquat: angle(r1,r2) loses a small angle')
q = quaternion(r);
assert(all(abs(angle(q,-q)) <= 1e-15), ...
  'check_eulerquat: angle(q,-q) is not zero')
assert(all(abs(angle(r,rotation(-q))) <= 1e-15), ...
  'check_eulerquat: the sign of the quaternion representative changes the angle')
assert(all(abs(angle(r,-r) - pi) <= 1e-15), ...
  'check_eulerquat: a rotation and its inversion are not a half turn apart')

r = rotation.byAxisAngle(ax,pi - omega);
assert(all(abs(angle(r) - (pi - omega)) <= 1e-12), ...
  'check_eulerquat: angle(r) is off near pi')
assert(all(abs(angle(r,rotation.id) - (pi - omega)) <= 1e-12), ...
  'check_eulerquat: angle(r1,r2) is off near pi')

assert(angle(rotation.id) == 0 && angle(rotation.id,rotation.id) == 0, ...
  'check_eulerquat: the identity has a nonzero angle')

end

% =========================================================================
function assertSame(r,back,tol,what)
% compare two rotations by 1 - |dot|, as q and -q are the same rotation

dev = 1 - abs(dot(r(:),back(:)));

assert(max(dev) < tol, ...
  'check_eulerquat: %s round trip deviates by %.3g in 1 - |dot| (tolerance %.3g)', ...
  what, max(dev), tol)

end
