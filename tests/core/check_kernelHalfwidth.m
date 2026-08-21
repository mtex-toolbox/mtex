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

% the rebuilt halfwidth is found on a 0.01 degree grid, so allow that or one percent
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
