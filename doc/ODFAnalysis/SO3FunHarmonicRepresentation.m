%% Harmonic Representation of Rotational Functions
%
%%
% A rotational function can be stored as a finite list of coefficients
% instead of as values on an orientation grid. This is the harmonic
% representation used by |SO3FunHarmonic|. It is useful for analysing
% smoothness, filtering by angular scale, and turning many operations on
% functions into algebra on their coefficients.
%
% This page assumes the definition and normalization of an
% <ODFTheory.html orientation distribution function (ODF)> and the common
% interface introduced in <SO3FunConcept.html Orientation Dependent
% Functions>. An ODF is one important rotational function, but the
% harmonic representation applies to any scalar function on the rotation
% group.

plottingConvention.default('y↑→x');

%% The Series and Its Bandwidth
%
% Fourier series replace a complicated function by a weighted sum of known
% basis functions. On a circle those basis functions are sines and cosines.
% On the rotation group they are Wigner-D functions. Thus a rotational
% function $f\colon \mathrm{SO}(3) \to \mathbb C$ can be written as
%
% $$ f(\mathbf{R}) = \sum_{n=0}^N \sum_{k,l=-n}^n
% \hat f_n^{k,l}\,\mathrm{D}_n^{k,l}(\mathbf{R}). $$
%
% Here $\hat f_n^{k,l}$ are the Fourier coefficients and
% $\mathrm{D}_n^{k,l}$ are the
% <WignerFunctions.html Wigner-D functions>. The largest retained degree
% $N$ is the *bandwidth*. Increasing the bandwidth permits narrower detail,
% but it does not recover information already absent from the source data.
% A sharp cutoff removes fine scales and therefore smooths the function,
% although it can also cause ringing near sharp features.
%
% Before symmetry is taken into account, degree $n$ contributes
% $(2n+1)^2$ coefficients. A series through bandwidth $N$ therefore has
%
% $$ \sum_{n=0}^N(2n+1)^2 =
% \frac{(N+1)(2N+1)(2N+3)}{3} $$
%
% coefficients. This cubic growth is why bandwidth affects storage and
% computation much more strongly than its name may suggest.
%
% Several normalizations of Wigner-D functions occur in the literature.
% MTEX uses an orthonormal basis with respect to the normalized measure on
% $\mathrm{SO}(3)$, so
%
% $$ \|\mathrm{D}_n^{k,l}\|_2 = 1. $$
%
% Crystal and specimen symmetry restrict which coefficient combinations
% are admissible. MTEX applies those restrictions through the symmetries
% attached to the function. The basis convention and its relation to other
% conventions are detailed under <WignerFunctions.html Wigner-D Functions>.

%% Converting an ODF
%
% Start with an ODF reconstructed from the Dubna pole figure data. The
% zero-range flag belongs to that reconstruction; the page on
% <PoleFigureDubna.html the Dubna example> explains why it is used.

mtexdata dubna silent
odf = calcODF(pf,'resolution',5*degree,'zeroRange','silent');

%%
% Converting any |SO3Fun| to |SO3FunHarmonic| computes a finite harmonic
% approximation. Here the requested bandwidth is 32. The conversion keeps
% the crystal and specimen symmetries of the ODF.

f = SO3FunHarmonic(odf,'bandwidth',32);

%% Coefficient Storage
%
% The complex Fourier coefficients are stored in |f.fhat| as one vector.
% The degree-zero block is |f.fhat(1)|. The nine entries
% |f.fhat(2:10)| form the degree-one block, and the next 25 entries form the
% degree-two block. Within a block, rows correspond to $k=-n,\ldots,n$ and
% columns to $l=-n,\ldots,n$. MATLAB stores the columns one after another.
% The degree-two coefficient matrix is therefore

reshape(f.fhat(11:35),5,5)

%%
% Up to its bandwidth, this vector completely characterizes the harmonic
% function. The compact representation also makes many calculations
% algebraic. For example, orientation averages of symmetric second-rank
% single-crystal properties such as thermal expansion or conductivity need
% only low harmonic degrees. Fourth-rank elastic properties additionally
% involve degree four. The effective property still depends on the
% single-crystal tensor; the ODF coefficients describe the texture part of
% the average.

%% Constructing a Function from Coefficients
%
% A harmonic function can also be constructed directly from its coefficient
% vector. In the following example $\hat f_0^{0,0}=0.5$ and the degree-one
% block is
%
% $$ \hat f_1 = \left(\begin{array}{rrr}
% 1 & 4 & 7 \\
% 2 & 5 & 8 \\
% 3 & 6 & 9
% \end{array}\right). $$

f2 = SO3FunHarmonic([0.5,1:9]');
f2.isReal

%%
% The printed false value is deliberate. Real entries in |f.fhat| do not
% by themselves define a real-valued rotational function; paired
% coefficients must satisfy the conjugate symmetry imposed by the Wigner-D
% basis. This distinction matters before plotting, because a plot of a
% complex function can show only one real-valued part.
%
% Identity matrices satisfy the reality relation and give a small example
% through degree two. The vector order is degree first, then $l$, then $k$.

cs = crystalSymmetry('1');
fhat = [1;reshape(eye(3),[],1);reshape(eye(5),[],1)];
fExample = SO3FunHarmonic(fhat,cs)

minimumValue = min(fExample)

%%
% The summary shows that MTEX inferred bandwidth 2 from the vector length.
% The negative minimum shows why a coefficient vector does not
% automatically define an ODF. An ODF must be real, nonnegative, and
% normalized to mean one. Truncating the series of a sharp positive ODF can
% likewise create small negative undershoots, just as a truncated ordinary
% Fourier series can ring near a sharp edge.

plot(fExample,'sections',6,'silent','sigma');
mtexColorbar('title','function value');

%%
% The sigma sections show the full rotational function. The colorbar spans
% negative and positive values, which is the visible consequence of
% choosing coefficients without enforcing ODF positivity.

plotPDF(fExample,[Miller(1,0,0,cs),Miller(1,1,0,cs)],'antipodal');

%%
% These pole figures are projections of the same coefficient series. A
% plausible-looking projection is not evidence that the function itself is
% a valid ODF; the reality, positivity, and normalization checks still
% apply in orientation space.

%% Reading a Spectrum
%
% <SO3Fun.plotSpektra.html |plotSpektra|> groups the coefficients by degree.
% At each degree it plots the square root of their summed squared
% magnitudes, not the individual coefficients.

close all;
plotSpektra(f);

%%
% Read the curve from left to right as the amount of progressively finer
% angular structure. Fast decay means that a lower bandwidth may preserve
% the function well. A slow or irregular tail means that high-degree
% content remains. In a pole-figure inversion, that tail can also indicate
% the ghost effect; see <PoleFigure2ODFGhostCorrection.html Ghost
% Correction>.

%% Harmonic Approximation of a General SO3Fun
%
% Nothing in the harmonic representation requires the function to be an
% ODF. As an example, take the misorientation angle to a fixed orientation.
% It is nonnegative, but it is not normalized to mean one and is therefore
% not an ODF.

cs = crystalSymmetry('432');
oriRef = orientation.byEuler(30*degree,50*degree,10*degree,cs);
fAngle = SO3FunHandle(@(ori) angle(ori,oriRef)./degree,cs);

%%
% <SO3FunHarmonic.quadrature.html |quadrature|> evaluates the function on a
% quadrature grid and computes its Fourier coefficients. Request the same
% bandwidth 32 used above.

fAngleHarm = SO3FunHarmonic.quadrature(fAngle,'bandwidth',32);

%%
% The maximum pointwise error below measures this random sample only. It is
% not a guaranteed global error bound.

ori = orientation.rand(1000,cs);

maxApproximationError = max(abs(fAngle.eval(ori) - fAngleHarm.eval(ori)))

%%
% The nonzero error is a truncation effect. The angle function has a cusp at
% |oriRef| and further cusps where two symmetry-equivalent distance branches
% tie. It is continuous but not differentiable there, so its coefficients
% decay slowly and the finite cutoff is felt away from the cusps as well.

close all;
plotSpektra(fAngleHarm);

%%
% Unlike the reconstructed ODF spectrum, this spectrum retains appreciable
% power near the cutoff. That slow decay is the spectral signature of the
% nonsmooth angle function. In general, smoother functions have faster
% coefficient decay and need less bandwidth for the same accuracy.

plotSection(fAngleHarm,'sigma');
mtexColorbar('title','misorientation angle in degree');

%%
% The section plot is smooth over most of orientation space but changes
% direction sharply along the symmetry cut loci. Those ridges are why a
% finite smooth series cannot reproduce the angle function exactly.

%% References
%
% * <https://doi.org/10.1016/C2013-0-11769-2 Bunge, Texture Analysis in
% Materials Science> develops generalized spherical harmonics, texture
% coefficients, and crystal and specimen symmetry.
% * <https://doi.org/10.1063/1.1714396 Roe (1965)> gives the classical
% generalized-harmonic solution of the pole-figure inversion problem.
% * <https://doi.org/10.1007/s00041-008-9013-5 Kostelec and Rockmore
% (2008)> develop fast Fourier transforms for band-limited functions on
% $\mathrm{SO}(3)$.
% * <https://doi.org/10.1142/0270 Varshalovich, Moskalev, and Khersonskii,
% Quantum Theory of Angular Momentum> is a standard reference for Wigner-D
% functions and their convention-dependent normalizations.

%% Next
%
% The basis behind this representation is developed in
% <WignerFunctions.html Wigner-D Functions>. The calculations enabled by
% the common function interface are collected in
% <SO3FunOperations.html Operations on Rotational Functions>. For the
% inverse problem that produced the measured ODF above, continue with
% <PoleFigure2ODF.html Reconstructing an ODF>. Approximation from scattered
% values, including regularization and overfitting, is covered in
% <HarmonicApproximationTheory.html Harmonic Approximation from Discrete
% Data>. The next page in this chapter, <ODFImport.html Importing an ODF>,
% explains how MTEX reconstructs function objects from common file
% representations.

%#ok<*NASGU>
%#ok<*NOPTS>
