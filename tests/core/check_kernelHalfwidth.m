function check_kernelHalfwidth
% a kernel's halfwidth must survive a round trip through its Chebyshev
% coefficients
%
% Every SO3Kernel subclass computes its halfwidth analytically. Rebuilding a
% generic SO3Kernel from the same kernel's coefficients, SO3Kernel(psi.A),
% and asking that one for its halfwidth has to give the same answer -
% otherwise the two ways of describing the same kernel disagree.
%
% Converted from tests/SO3FunTests/test_KernelHalfwidth.m, which printed
% [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree for about 28
% parameter choices with no semicolon and no comparison: a table for a human
% to read. Its header says [DONE], but problems.m recorded the same question
% as open, and it is now issue #2585 item 8.
%
% The three most expensive parameters of the original are dropped -
% SO3DeLaValleePoussinKernel(2000), SO3DirichletKernel(400) and
% SO3vonMisesFisherKernel(500) - since building and root finding a
% bandwidth 2000 kernel dominated the runtime and adds no case the smaller
% parameters do not already cover.
%
% See also
% SO3Kernel SO3Kernel/halfwidth

cases = { ...
  'SO3AbelPoissonKernel',       {0.4, 0.7}; ...
  'SO3DeLaValleePoussinKernel', {1, 100}; ...
  'SO3DirichletKernel',         {1, 50}; ...
  'SO3GaussWeierstrassKernel',  {0.1, 0.5, 1}; ...
  'SO3SquareSingularityKernel', {0.091, 0.5, 0.99}; ...
  'SO3vonMisesFisherKernel',    {0.347, 10}};

for k = 1:size(cases,1)
  for j = 1:numel(cases{k,2})
    checkKernel(feval(cases{k,1},cases{k,2}{j}), ...
      sprintf('%s(%g)',cases{k,1},cases{k,2}{j}));
  end
end

checkKernel(SO3LaplaceKernel,'SO3LaplaceKernel');

for s = [0.1 1.1 5]
  checkKernel(SO3SobolevKernel(s,'bandwidth',20), ...
    sprintf('SO3SobolevKernel(%g)',s));
end

% ---------------------------------------------------------------------
% KNOWN FAILURES, see https://github.com/mtex-toolbox/mtex/issues/2585 item 8
%
% SO3BumpKernel: the rebuilt halfwidth is 0.2 degree whatever the parameter.
% Measured at 0.01, 1 and pi-0.1, whose own halfwidths are 0.573, 57.3 and
% 174.27 degree, the rebuilt kernel reports 0.2 degree for all three. A bump
% is an indicator function, so its Chebyshev series converges slowly and the
% stored coefficients do not reconstruct it - which is the substance of that
% issue rather than a separate defect.
%
% SO3AbelPoissonKernel breaks at both ends of its range. At kappa 0.1 and
% 0.2 the halfwidth is exactly 0 degree, from the class and from the rebuilt
% kernel alike - a flatter kernel should have a LARGER halfwidth, and the
% trend 0.99 -> 0.7 -> 0.4 is 0.8 -> 26.5 -> 74.1 degree, so those two
% should be approaching 180 rather than collapsing. Whatever locates the
% half maximum is failing to bracket. At kappa 0.99 the two disagree by
% 12.5 percent, 0.80 against 0.90 degree, where 0.4 and 0.7 agree to 8e-4.
% The degeneracy guard in checkKernel below is what caught the zeros.
%
%   checkKernel(SO3BumpKernel(1),'SO3BumpKernel(1)');
%   checkKernel(SO3AbelPoissonKernel(0.1),'SO3AbelPoissonKernel(0.1)');
%   checkKernel(SO3AbelPoissonKernel(0.99),'SO3AbelPoissonKernel(0.99)');
% ---------------------------------------------------------------------

disp('check_kernelHalfwidth: passed');

end

% =========================================================================
function checkKernel(psi,name)

h1 = psi.halfwidth;
h2 = halfwidth(SO3Kernel(psi.A));

% the rebuilt halfwidth is found on a 0.01 degree grid - every value it
% returns is a multiple of it - so the comparison allows the larger of that
% quantisation and one percent
tol = max(0.02*degree, 0.01*h1);

assert(abs(h1 - h2) <= tol, ...
  ['check_kernelHalfwidth: %s reports %.4f degree but the kernel rebuilt ' ...
   'from its own coefficients reports %.4f degree (tolerance %.4f)'], ...
  name, h1/degree, h2/degree, tol/degree)

% a kernel whose halfwidth came back as 0 or pi would satisfy almost any
% comparison; neither is a real answer here
assert(h1 > 0 && h1 < pi, ...
  'check_kernelHalfwidth: %s has a degenerate halfwidth of %.4f degree', ...
  name, h1/degree)

end
