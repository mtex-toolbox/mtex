function check_MLSSubsample
% check the 'subsample' option of the MLS functions
%
% The optimal subset selection asks linprog for the Lagrange multipliers,
% which the simplex algorithms of some releases do not return; MLSFun then
% falls back to interior-point-legacy. On SO(3) the subsets have to be
% chosen among the neighbors projected next to their center, otherwise a
% crystal symmetry scrambles the local coordinates.
%
% See also
% S2FunMLS SO3FunMLS check_MLSFun

if isempty(ver('optim'))
  disp('check_MLSSubsample: skipped, no Optimization Toolbox');
  return
end

rng(0)

% S2, the approximation has to be usable, not merely constructible
v = vector3d.rand(300);
S2F = S2FunMLS(v,cos(v.theta),'subsample');
w = vector3d.rand(50);
err = max(abs(S2F.eval(w) - cos(w.theta)));
assert(err < 0.1,'check_MLSSubsample: the subsampled S2 approximation is off by %g',err)

% SO(3) with crystal symmetry, as accurate as without subsampling
cs = crystalSymmetry('432');
f = SO3FunRBF(orientation.rand(3,cs),SO3DeLaValleePoussinKernel('halfwidth',25*degree));
ori = orientation.rand(1500,cs);
w = orientation.rand(30,cs);
opt = {'degree',2,'regularize',false,'use_vor_weights',false};

err = max(abs(SO3FunMLS(ori,f.eval(ori),opt{:}).eval(w) - f.eval(w)));
errSub = max(abs(SO3FunMLS(ori,f.eval(ori),opt{:},'subsample').eval(w) - f.eval(w)));
assert(errSub < 5 * err, ...
  'check_MLSSubsample: subsampling with crystal symmetry is off by %g, %g without',errSub,err)

disp('check_MLSSubsample: passed');

end
