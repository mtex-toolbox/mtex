function check_odfGrad
% the analytic ODF gradient must agree with a finite difference
%
% Merged from check_unimodalGrad and check_FibreGrad, and covering the ODF
% types the dead check_FourierGrad was aiming at as well. All three printed
% ' ... gradient test passed' or ' ... failed' and returned normally, so none
% of them could fail a run - and check_unimodalGrad printed the same string
% for both of its cases, so the log could not even say which one it was.
%
% grad(odf,ori,'check') evaluates the ODF six times per orientation to build
% a central difference, so it is the reference here and the analytic gradient
% is what is under test.
%
% The tolerance is relative to 1 + norm(g1) rather than to norm(g1): the
% gradient of an ODF passes through zero, and dividing by a norm that is
% near zero turns a correct answer into an arbitrary relative error. That is
% what the old check_FibreGrad did.
%
% See also
% SO3Fun/grad SO3FunRBF/grad SO3FunCBF/grad

rng(0)

N = 500;

% unimodal, low symmetry crystal against cubic specimen symmetry
cs1 = crystalSymmetry('-3m1');
cs2 = crystalSymmetry('m-3m');
checkGrad(unimodalODF(orientation.rand(20,cs1,cs2)), N, 1e-3, 'unimodal');

% the SO3FunCBF branch - #2586, where grad symmetrised over the crystal symmetry
% only, which a non trivial specimen symmetry exposes
cs = crystalSymmetry('432');
ss = specimenSymmetry('222');
fibre = fibreODF(Miller.rand(cs),vector3d.rand,ss);
checkGrad(fibre, N, 1e-3, 'fibre');
checkGrad(fibre, N, 1e-3, 'fibre, right tangent space', 'right');

% SantaFe, a multi component RBF
checkGrad(SantaFe, N, 1e-3, 'SantaFe');

% and the harmonic representation of the same thing, which is the branch
% check_FourierGrad was meant to cover before it rotted
checkGrad(SO3FunHarmonic(SantaFe,'bandwidth',32), N, 1e-2, 'harmonic');

disp('check_odfGrad: passed');

end

% =========================================================================
function checkGrad(odf,N,tol,what,varargin)
% varargin passes a tangent space through to both sides, so that the
% reference and the analytic gradient are always compared in the same one

ori = orientation.rand(N,odf.CS,odf.SS);

gRef = odf.grad(ori(:),'check','delta',0.05*degree,varargin{:});
gGot = odf.grad(ori(:),varargin{:});

% relative to 1 + norm, so that an orientation where the gradient vanishes
% does not dominate the measure
err = max(norm(gGot - gRef) ./ (1 + norm(gRef)));

assert(err < tol, ...
  'check_odfGrad: the %s gradient differs from the finite difference by %.3g (tolerance %.3g)', ...
  what, err, tol)

% and the check must not be vacuous - a gradient that is zero everywhere
% would satisfy the comparison above against an equally zero difference
assert(max(norm(gRef)) > 1e-3, ...
  'check_odfGrad: the %s reference gradient is zero everywhere, nothing was tested', what)

end
