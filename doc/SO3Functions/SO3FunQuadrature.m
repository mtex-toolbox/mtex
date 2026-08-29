%% Quadrature of Orientation-Dependent Functions
%
% The preceding interpolation pages start from observations at fixed
% orientations. Quadrature addresses a different problem: the function can
% be evaluated at orientations chosen by MTEX. Those evaluations may come
% from an @SO3Fun, a |@function_handle|, a simulation, or a physical
% experiment that can be queried at prescribed orientations.
%
% MTEX chooses a grid of orientations and matching integration weights.
% It then converts the evaluated values into the Fourier coefficients of an
% <SO3FunHarmonicRepresentation.html |SO3FunHarmonic|>. This page shows the
% one-command route and the explicit grid--evaluate--quadrature sequence.

plottingConvention.default('y↑→x');

%% Approximate a known function
%
% Use the Dubna orientation distribution function (ODF) as the evaluator.
% An ODF is a nonnegative orientation-dependent density with mean 1.
%
% The <SO3FunHarmonic.SO3FunHarmonic.html |SO3FunHarmonic|> constructor falls
% back on <SO3FunHarmonic.quadrature.html |SO3FunHarmonic.quadrature|> only
% when its input has no faster route of its own. The Dubna ODF is an
% @SO3FunRBF, which builds its coefficients from its centres and kernel, so
% no quadrature grid is used in the call below. The explicit sequence later
% on this page takes the quadrature route.
%
% The bandwidth is the largest harmonic degree retained in the result.
% Bandwidth 14 is deliberately lower than the bandwidth of the supplied
% ODF, so this first conversion is an approximation rather than exact
% recovery.

odf = SO3Fun.dubna
odfHarmonic = SO3FunHarmonic(odf,'bandwidth',14)
relativeApproximationError = calcError(odf,odfHarmonic)

plot(odf,'sigma')

%%
% The original section plot contains narrow maxima as well as broad regions
% of high density. Compare it with the bandwidth-limited result.

plot(odfHarmonic,'sigma')

%%
% The main maxima stay in the same sections, but their sharpest structure
% is smoothed. The printed error is truncation alone, since this route
% carries no quadrature step. Raising the bandwidth represents finer angular
% detail but requires more evaluations.
%
% Clenshaw--Curtis is the default quadrature scheme. Add the
% |'GaussLegendre'| flag to select the other predefined scheme.

odfGauss = SO3FunHarmonic(odf,'bandwidth',14,'GaussLegendre')

%% Choose and evaluate the quadrature nodes
%
% When evaluations come from an external routine, construct the quadrature
% grid explicitly. The next function handle stands in for a simulation or
% experiment. Replace only its body in an application; the remaining
% sequence stays the same.
%
% Exactness can only be tested against a band-limited function. Truncate the
% known ODF at bandwidth 14 to create such a reference for this controlled
% example.

bw = 14;
reference = SO3FunHarmonic(odf);
reference.bandwidth = bw;
experiment = @(ori) reference.eval(ori);
cs = reference.CS;
ss = reference.SS;

CC_grid = quadratureSO3Grid(bw,'ClenshawCurtis',cs,ss);
CC_orientations = CC_grid(:);
CC_values = experiment(CC_orientations);
CC_result = SO3FunHarmonic.quadrature(CC_grid,CC_values)

%%
% The symmetry of the crystal and specimen makes many nodes equivalent.
% |CC_grid(:)| contains the smaller unique set on which the expensive
% evaluator is called. The grid object retains the mapping and weights
% needed to integrate over the complete orientation space.
%
% <SO3FunHarmonic.interpolate.html |SO3FunHarmonic.interpolate|> recognizes
% a |quadratureSO3Grid| and performs the same calculation. For example,
% |SO3FunHarmonic.interpolate(CC_grid,CC_values)| is equivalent here.

numberOfCCEvaluations = numel(CC_grid)
numberOfCCFullGridNodes = numel(CC_grid.fullGrid)
CCRecoveryError = calcError(reference,CC_result)

%% Compare the two schemes
%
% Gauss--Legendre uses fewer nodes in the second Euler angle. It therefore
% needs about half as many function evaluations as Clenshaw--Curtis at the
% same bandwidth. The transform itself is slightly more time-consuming,
% so Gauss--Legendre is most attractive when each external evaluation is
% expensive.

GL_grid = quadratureSO3Grid(bw,'GaussLegendre',cs,ss);
GL_orientations = GL_grid(:);
GL_values = experiment(GL_orientations);
GL_result = SO3FunHarmonic.quadrature(GL_grid,GL_values)

numberOfGLEvaluations = numel(GL_grid)
numberOfGLFullGridNodes = numel(GL_grid.fullGrid)
GLRecoveryError = calcError(reference,GL_result)
schemeDifference = calcError(CC_result,GL_result)

%%
% For this bandwidth and symmetry, the printed unique-node counts are 4500
% for Clenshaw--Curtis and 2400 for Gauss--Legendre. Thus Gauss--Legendre
% uses 53 percent as many external evaluations. Both recover the reference
% to the numerical accuracy of the transforms, and their difference is of
% the same small order.
%
% Both rules are exact, up to numerical transform accuracy, for rotational
% harmonic functions whose bandwidth does not exceed the grid bandwidth.
% They need not return the same truncation of a function containing higher
% degrees. This distinction is why the example tests exactness with
% |reference| rather than directly with the bandwidth-48 |odf|.

%% When the orientations cannot be chosen
%
% Quadrature is not appropriate when an instrument has already fixed the
% sample orientations. Random orientations do not become a quadrature rule
% merely because there are many of them. Use
% <SO3FunApproximationTheory.html interpolation from discrete data> in that
% case.
%
% If an external experiment can be run at arbitrary orientations, the
% quadrature grid is the optimal structured choice for a harmonic result.
% If an RBF result is required instead, evaluate an
% <equispacedSO3Grid.html |equispacedSO3Grid|> and pass
% the resulting orientation--value pairs to
% <SO3FunRBF.interpolate.html |SO3FunRBF.interpolate|>.

%% Quadrature is not RBF fitting
%
% <RBFApproximationTheory.html RBF-Kernel Interpolation> develops the RBF
% workflow in full. An <SO3FunRBF.SO3FunRBF.html |SO3FunRBF|> represents a
% function as a weighted sum of rotational kernels centred at chosen
% orientations. Its spatial method chooses the coefficients by minimizing
% pointwise error at an evaluation grid. MATLAB's |lsqr| is the default
% unconstrained solver. Although stationarity can be expressed through the
% normal equations, LSQR does not form those equations explicitly.
%
% The |'density'| flag selects modified least squares, |'mlsq'|. It
% constrains the weights to be nonnegative, and MTEX normalizes the result
% to mean 1. The commands |min(F)| and |mean(F)| check these two density
% properties after a fit.
%
% These constructor forms summarize the choices described on the RBF page:
%
%   F = SO3FunRBF(odfHarmonic,'density');
%   F = SO3FunRBF(odfHarmonic,'halfwidth',5*degree, ...
%     'resolution',10*degree);
%   psi = SO3AbelPoissonKernel('halfwidth',5*degree);
%   centres = orientation.rand(1000,odfHarmonic.CS);
%   F = SO3FunRBF(odfHarmonic,'kernel',psi,'SO3Grid',centres);
%   F = SO3FunRBF(odfHarmonic,'halfwidth',5*degree, ...
%     'approxresolution',5*degree);
%
% |'kernel'| or |'halfwidth'| chooses the radial kernel.
% |'SO3Grid'| supplies its centres, while |'resolution'| constructs a centre
% grid. |'approxresolution'| controls the separate grid on which the input
% function is evaluated. Use |calcError(odfHarmonic,F)| to compare a fitted
% representation with its source.

%% Spatial and harmonic RBF errors
%
% The default RBF method minimizes pointwise error between the source $f$
% and the RBF model $g$ at evaluation orientations $x_m$:
%
% $$ \sum_{m=1}^M \lvert f(x_m)-g(x_m)\rvert^2. $$
%
% The |'harmonic'| flag instead chooses the kernel weights so that the
% Fourier coefficients of $f$ and $g$ are close. It minimizes
%
% $$ \sum_{n=0}^N\sum_{k,l=-n}^n
% \lvert\hat f_n^{k,l}-\hat g_n^{k,l}\rvert^2. $$
%
% The spatial method is usually better suited to sharp, high-bandwidth
% functions. The harmonic system is better suited to low bandwidth because
% its matrix grows quickly with the number of Fourier coefficients. Select
% it with |SO3FunRBF(odfHarmonic,'harmonic')|.
%
% Both |lsqr| and |mlsq| stop according to |'tol'| and |'maxit'|. Their
% default tolerance is |1e-3|. Unconstrained |lsqr| uses at most 30
% iterations, whereas |mlsq| uses at most 100. Tighten these settings only
% when a validation error or a physical conclusion requires it.

%% The maths behind quadrature
%
% A band-limited rotational function is a finite series of
% <WignerFunctions.html Wigner-D functions>:
%
% $$ f(R)=\sum_{n=0}^N\sum_{k,l=-n}^n
% \hat f_n^{k,l}D_n^{k,l}(R). $$
%
% Its Fourier coefficients are integrals over orientation space with the
% normalized Haar measure $\mu$:
%
% $$ \hat f_n^{k,l}=\int_{\mathrm{SO}(3)} f(R)\,
% \overline{D_n^{k,l}(R)}\,\mathrm{d}\mu(R). $$
%
% A quadrature rule replaces each integral by values at nodes $R_m$ and
% prescribed weights $\omega_m$:
%
% $$ \hat f_n^{k,l}\approx\sum_{m=1}^M \omega_m f(R_m)
% \overline{D_n^{k,l}(R_m)}. $$
%
% The weights are part of the rule. Treating all structured nodes equally,
% or substituting arbitrary random orientations, changes the integral.
% MTEX combines periodic quadrature in the first and third Euler angles
% with either Clenshaw--Curtis or Gauss--Legendre nodes in the second angle.

%% References
%
% * P. J. Kostelec and D. N. Rockmore,
% <https://doi.org/10.1007/s00041-008-9013-5 FFTs on the rotation group>,
% _Journal of Fourier Analysis and Applications_ 14 (2008), 145--179,
% develops fast Fourier transforms for band-limited functions on
% $\mathrm{SO}(3)$.
% * H. Schaeben, F. Bachmann, and J.-J. Fundenberger,
% <https://doi.org/10.1007/s10853-016-0496-1 Construction of weighted
% crystallographic orientations capturing a given orientation density
% function>, _Journal of Materials Science_ 52 (2017), 2077--2090,
% develops the positive normalized RBF approximation summarized above.

%% Next
%
% Continue with <SO3FunHarmonicRepresentation.html Harmonic Representation>
% to inspect and manipulate the Fourier coefficients produced by
% quadrature. Then use <RadialODFs.html Radial Basis Functions> to study the
% kernel representation contrasted with quadrature on this page.

%#ok<*NOPTS>
