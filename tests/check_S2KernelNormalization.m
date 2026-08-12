function check_S2KernelNormalization
% check that the spherical kernels are densities
%
% A kernel used for density estimation has to have mean value one over the
% sphere, equivalently a first Legendre coefficient A(1) = 1. Everything
% calcDensity does downstream - the m.u.d. scale of a pole figure, the
% comparison of two estimates, the colorbar - assumes it.
%
% S2BumpKernel did not: it returned the bare 0/1 indicator of a spherical
% cap, so A(1) was the relative area of that cap, 0.0076 for a halfwidth of
% 10 degree. calcDensity with it came out with mean 0.0076 and max 0.0397
% instead of a density, and nothing warned on the way.

hw = 10*degree;

% the density kernels, i.e. the ones calcDensity is meant to be called
% with. Deliberately not in this list: S2RestrictedDistanceKernel, which is
% negative by construction and measures a distance for compactify rather
% than estimating a density (its A(1) is -4/3), and likewise the
% special-purpose SchulzDefocusingKernel and calcGBNDKernel.
kernels = { ...
  S2DeLaValleePoussinKernel('halfwidth',hw), ...
  S2BumpKernel(hw), ...
  S2DirichletKernel(16)};

for k = 1:numel(kernels)
  checkKernel(kernels{k});
end

checkBumpIsIndicator(hw);

disp('check_S2KernelNormalization: passed');

end

% =========================================================================
function checkKernel(psi)

name = class(psi);

assert(abs(psi.A(1) - 1) < 1e-4, ...
  'check_S2KernelNormalization: %s has A(1) = %g, a density has A(1) = 1', ...
  name, psi.A(1))

% and the same statement once more through calcDensity, which is what
% users actually see
rng(0)
sF = calcDensity(vector3d.rand(1000),'kernel',psi);

assert(abs(mean(sF) - 1) < 0.05, ...
  'check_S2KernelNormalization: calcDensity with %s has mean %g instead of 1', ...
  name, mean(sF))

end

% -------------------------------------------------------------------------
function checkBumpIsIndicator(hw)
% the bump kernel is still constant inside the cap and zero outside it -
% only its height changed

psi = S2BumpKernel(hw);

inside = psi.eval(cos(hw/2));
outside = psi.eval(cos(2*hw));

assert(outside == 0, ...
  'check_S2KernelNormalization: the bump kernel is not zero outside its cap')

% the height is the reciprocal of the relative area of the cap
assert(abs(inside - 2/(1-cos(hw))) < 1e-10, ...
  'check_S2KernelNormalization: the bump kernel has height %g instead of %g', ...
  inside, 2/(1-cos(hw)))

% constant inside
assert(psi.eval(cos(hw/4)) == inside, ...
  'check_S2KernelNormalization: the bump kernel is not constant inside its cap')

end
