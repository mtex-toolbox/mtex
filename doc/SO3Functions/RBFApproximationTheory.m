%% RBF-Kernel Approximation from Discrete Data
%
% <SO3FunApproximationTheory.html Approximating Orientation-Dependent
% Functions from Discrete Data> defines the shared approximation problem
% and compares harmonic, RBF, and Bingham models. This page assumes that an
% RBF model is appropriate and shows how to choose density constraints,
% kernel halfwidth, centre orientations, and a least-squares solver.
%
% RBF approximation is often useful for an ODF or another density when the
% number of observations and their noise level are not too large. It can
% also fit a general scalar response, but only |'density'| imposes the
% nonnegativity and mean-1 constraints required of a density.

plottingConvention.default('y↑→x');

%% A noisy density data set
%
% Start with the data used on the preceding two pages. This time the noise
% standard deviation is 20 percent of the standard deviation of the
% supplied values.

fname = fullfile(mtexDataPath, 'orientation', 'dubna.csv');
[ori, S] = orientation.load(fname, ...
  'columnNames',{'phi1','Phi','phi2','values'});
val = S.values + randn(size(S.values)) * 0.2 * std(S.values);

plotSection(ori,val,'all','sigma')

%%
% The broad high-value regions remain visible, but individual markers vary
% much more than on the harmonic page. The noise-free values |S.values| are
% retained only so that this controlled example can later measure recovery
% error. They would not be available for an unknown experimental response.

%% Fit a density
%
% <rotation.interp.html |interp|> uses an RBF model by default and calls
% <SO3FunRBF.interpolate.html |SO3FunRBF.interpolate|>. The |'density'|
% flag selects modified least squares, |'mlsq'|. This solver constrains the
% kernel weights to be nonnegative, and MTEX normalizes the fitted function
% to mean 1.

SO3FDensity = interp(ori,val,'density')
minimumDensityValue = min(SO3FDensity)
meanDensityValue = mean(SO3FDensity)
relativeDataResidual = ...
  norm(SO3FDensity.eval(ori) - val) / norm(val)

plot(SO3FDensity,'sigma')
mtexColorbar

%%
% The fit retains the broad peaks while smoothing the marker-to-marker
% fluctuations. Its printed minimum and mean verify the density constraints.
% A nonzero residual is expected because a smooth constrained model cannot
% reproduce every noisy value. This run reaches the 100-iteration |'mlsq'|
% limit, so its coefficients may not yet be optimal.

%% Fit without density constraints
%
% Omitting |'density'| selects unconstrained LSQR. The kernel grid still
% smooths the data, so the result is not literally "undenoised." It simply
% has more freedom to reduce the sample residual, including by using
% negative weights or changing the mean.

SO3FFree = interp(ori,val)
minimumFreeValue = min(SO3FFree)
meanFreeValue = mean(SO3FFree)
relativeFreeResidual = norm(SO3FFree.eval(ori) - val) / norm(val)

plot(SO3FFree,'sigma')
mtexColorbar

%%
% The unconstrained residual is smaller, but the printed minimum and mean
% show that this fit is not automatically a density. Fine-scale features
% that only reduce the training residual are possible overfitting, not
% evidence that the unconstrained model is physically better.

%% Separate halfwidth from centre spacing
%
% The kernel halfwidth controls how far each centre influences neighbouring
% orientations. A large halfwidth produces a smooth fit. A halfwidth that is
% small relative to the data spacing can reproduce noise.
%
% By default, the |'halfwidth'| option also sets the resolution of the
% equispaced centre grid. That coupling changes both the kernel shape and
% the number of unknown weights. Specify |'resolution'| separately when the
% aim is to isolate the effect of halfwidth.

SO3FNarrow = interp(ori,val,'halfwidth',2*degree, ...
  'resolution',5*degree,'density')
plot(SO3FNarrow,'sigma')

%%
% The 2 degree kernels are narrower than the fixed 5 degree centre spacing.
% The resulting small-scale peaks track local samples rather than the broad
% structure. As a rule of thumb, start with a halfwidth at least as large as
% the resolution of the data, then validate that choice.

SO3FSmooth = interp(ori,val,'halfwidth',10*degree, ...
  'resolution',5*degree,'density')
plot(SO3FSmooth,'sigma')

%%
% The 10 degree kernels overlap much more. The broad peaks remain while
% narrow fluctuations merge into a smoother surface.
%
% The two fits chose their own centres, and the printed counts differ, so
% this compares two complete fits rather than halfwidth alone. The next
% section supplies the centres explicitly.

%% Supply the centre orientations
%
% Use |'SO3Grid'| when the centre grid must be controlled directly. Its
% symmetry should match the sample orientations.

S3G = equispacedSO3Grid(ori.CS,'resolution',5*degree)
SO3FGrid = interp(ori,val,'SO3Grid',S3G,'density')
plot(SO3FGrid,'sigma')

%%
% The fitted function reports the supplied 5 degree centre grid. The plot
% resembles the default density fit because that fit makes the same grid
% choice; the explicit form is useful when several fits must share centres.

%% Measure a halfwidth sweep
%
% Keep the centre resolution at 5 degrees while changing only halfwidth.
% The error is measured against the noise-free values in this simulation,
% not against the noisy training values.

hw = [20,15,12.5,10,7.5,5,2.5];
err = zeros(size(hw));
for k = 1:numel(hw)
  SO3Fhw = interp(ori,val,'halfwidth',hw(k)*degree, ...
    'resolution',5*degree,'density');
  err(k) = norm(SO3Fhw.eval(ori) - S.values) / norm(S.values);
end

close all
plot(hw,err,'o--')
set(gca,'xdir','reverse')
xlabel('halfwidth [deg]')
ylabel('relative recovery error')

%%
% Read the curve from broad kernels on the left towards narrow kernels on
% the right. The minimum balances smoothing bias against sensitivity to
% noise. An earlier version of this example reported 7.5 degrees as the
% best fit, but that sweep also changed the centre-grid resolution. The
% fixed-grid sweep also selects 7.5 degrees, with a recovery error of 0.0556.
% Every fit reached the 100-iteration cap, so this is the best of the capped
% fits rather than a claim that every solver reached its optimum.

[bestError,bestIndex] = min(err);
bestHalfwidth = hw(bestIndex)
bestRecoveryError = bestError

SO3FBest = interp(ori,val,'halfwidth',bestHalfwidth*degree, ...
  'resolution',5*degree,'density')
plot(SO3FBest,'sigma')

%%
% The selected fit retains the broad regions while suppressing much of the
% added noise. A small training residual alone could not select it; the
% known noise-free target makes this a validation experiment. With real
% data, use held-out samples or independent physical knowledge instead.
%
% If too few observations constrain too many centre weights, the system is
% underdetermined. A small halfwidth does not supply the missing information;
% use fewer centres, a stronger constraint, or additional smoothness
% assumptions.

%% Choose another kernel
%
% |'halfwidth'| constructs a
% <SO3DeLaValleePoussinKernel.html |SO3DeLaValleePoussinKernel|>. Pass
% |'kernel'| to use another <SO3Kernels.html rotational kernel function>.

psi = SO3AbelPoissonKernel('halfwidth',5*degree)
SO3FAbel = interp(ori,val,'kernel',psi, ...
  'resolution',5*degree,'density')
plot(SO3FAbel,'sigma')

%%
% The Abel-Poisson fit places its peaks in the same broad regions, but its
% tails and peak shapes differ from the de la Vallee Poussin result. Kernel
% family and halfwidth are separate modelling choices.

%% Exact interpolation
%
% If the values are noise-free, the input orientations themselves can be
% used as kernel centres with |'exact'|. For distinct nodes and a
% positive-definite kernel, the resulting kernel matrix is symmetric and
% positive definite, so the linear system has a unique exact solution.
%
% That matrix is generally dense. Construction, solution, and later
% evaluation can therefore become prohibitively expensive for the complete
% data set. The example uses a reproducible subset to make the cost visible
% without attempting the original all-node dense system.

exactNodes = ori(1:20:end);
exactValues = S.values(1:20:end);
numberOfExactNodes = numel(exactNodes)

tic
SO3FExact = SO3FunRBF.interpolate(exactNodes,exactValues, ...
  'exact','halfwidth',7.5*degree);
exactFitTime = toc

plot(SO3FExact,'sigma')

%%
% The exact-centre fit follows the noise-free subset closely. The many local
% peaks also show why exact interpolation is unsuitable for noisy values.
% Because these centres are not a structured grid, later evaluations are
% slower than for a grid-centred RBF model.
%
% LSQR stops at a requested tolerance or iteration limit, so its computed
% residual need not reach machine precision. Exact centres make an exact
% solution available; they do not force the iterative solver to reach it.

relativeExactResidual = ...
  norm(SO3FExact.eval(exactNodes) - exactValues) / norm(exactValues)
minimumExactValue = min(SO3FExact)

%%
% The printed residual checks how closely this run solved the system. Its
% minimum happens to be positive. That outcome does not create a guarantee:
% exact interpolation is unconstrained and may become negative even when
% every supplied value is nonnegative.

%% Choose a least-squares solver
%
% The harmonic page introduces LSQR stopping conditions. RBF interpolation
% uses |'tol'| and |'maxit'| in the same spirit, but its defaults depend on
% the solver: unconstrained |'lsqr'| uses at most 30 iterations, whereas
% density-constrained |'mlsq'| uses at most 100. Both default to |tol=1e-3|.
%
% The available choices serve different constraints:
%
% * |'lsqr'| is the fast default for an unconstrained least-squares fit.
% * |'mlsq'| enforces positive normalized weights and is selected by
%   |'density'|. |'mlrl'| is the corresponding maximum-likelihood option.
% * |'lsqnonneg'|, |'lsqlin'|, and |'nnls'| are alternative nonnegative
%   solvers. |'lsqlin'| requires Optimization Toolbox, while the dense
%   alternatives are practical only for small systems.
%
% The second output of |SO3FunRBF.interpolate| is the iteration count, not
% a convergence flag. Compare residuals and fits when the count reaches the
% selected limit.

[f1,iter1] = SO3FunRBF.interpolate(ori,val);
residualNorm1 = norm(f1.eval(ori) - val);
fprintf('default: iterations %d, residual norm %.6g\n', ...
  iter1,residualNorm1)

[f2,iter2] = SO3FunRBF.interpolate(ori,val, ...
  'tol',1e-15,'maxit',100);
residualNorm2 = norm(f2.eval(ori) - val);
fprintf('tight tol: iterations %d, residual norm %.6g\n', ...
  iter2,residualNorm2)

%%
% If the second run reaches 100 iterations, it has stopped at |'maxit'|
% rather than satisfying the very small tolerance. Increase the limit only
% when the additional accuracy matters to validation or interpretation.
%
% Earlier code labelled |norm(f.eval(ori)-val)| as the "energy functional"
% and added |5e-7*norm(f,2)| in the second run. The first expression is only
% an unscaled residual norm. The added harmonic-style penalty is not part of
% the RBF solver's objective and must not be reported as such.

%% The maths behind RBF approximation
%
% An RBF model places one rotational kernel $\Psi$ at each centre $R_n$:
%
% $$ f(x) = \sum_{n=1}^N c_n\,
% \Psi\!\left(\cos\frac{\omega(x,R_n)}{2}\right). $$
%
% Here $\omega(x,R_n)$ is the rotation angle between the evaluation
% orientation and the centre. The coefficients $c_n$ are the unknown
% weights. With sample pairs $(x_m,v_m)$, unconstrained fitting solves
%
% $$ \min_c \lVert Kc-v\rVert_2^2, \qquad
% K_{mn}=\Psi\!\left(\cos\frac{\omega(x_m,R_n)}{2}\right). $$
%
% The kernel matrix is sparse in the usual grid-centred approximation
% because MTEX neglects interactions outside a halfwidth-dependent angular
% neighbourhood. The |'exact'| flag evaluates every interaction, which is
% why that matrix loses the computational advantage.
%
% For a density fit, modified least squares additionally requires
% nonnegative coefficients with a prescribed sum. MTEX then normalizes the
% resulting RBF function to mean 1. These constraints explain why a density
% fit can have a larger sample residual than unconstrained LSQR.

%% References
%
% * H. Schaeben, F. Bachmann, and J.-J. Fundenberger,
% <https://doi.org/10.1007/s10853-016-0496-1 Construction of weighted
% crystallographic orientations capturing a given orientation density
% function>, _Journal of Materials Science_ 52 (2017), 2077-2090, develops
% the positive normalized RBF approximation implemented by |'mlsq'|.

%% Next
%
% Continue with <SO3FunQuadrature.html Approximation and Quadrature> to
% replace scattered observations by values on a quadrature grid and compute
% a harmonic representation of a known orientation-dependent function.

%#ok<*NOPTS>
