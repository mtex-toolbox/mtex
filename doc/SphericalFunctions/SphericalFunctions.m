%% Spherical Functions
%
%%
% A great deal of texture analysis is a number attached to every direction.
% A pole figure is one: an intensity for each specimen direction. So is the
% speed of a wave through a crystal, the density of measured axes, the
% Schmid factor of a slip system under a rotating load. Each is a *function
% on the sphere*.
%
% Treating these as one kind of object pays off immediately. Add two of
% them, take a maximum, integrate one, rotate one, smooth one, find its
% peaks - the operation means the same thing whether the function came from
% a diffractometer or from an elastic tensor, so it can be written once.
%
% Below is such a function, drawn on the sphere it lives on.

plottingConvention.default('y↑→x');

sF = S2Fun.smiley;

plot(sF,'upper')

%%
% The picture is a *representation* of the function, sampled densely enough
% to look continuous. The function itself is not a grid of values.
%
%% Several representations, one interface
%
% There is more than one way to store a function on a sphere, and the
% choices are genuinely different rather than a matter of taste.
%
% A *harmonic* representation keeps a list of coefficients in the spherical
% harmonic basis, the sphere's equivalent of a Fourier series. It is exact
% for smooth functions, it makes rotation and convolution cheap, and it
% needs many coefficients to represent anything sharp. A *kernel* or radial
% representation stores a sum of bumps at chosen positions, which is the
% natural fit for a density estimated from scattered measurements. A
% *triangulated* representation stores values at nodes and interpolates
% between them, which handles data that is neither smooth nor bump-like.
%
% MTEX puts these behind one interface, so a function can be built one way
% and used another without the code that uses it knowing which. The place
% it does matter is cost and sharpness, and choosing badly shows up as a
% slow computation or a peak that will not stay sharp.
%
%% Bandwidth is the parameter that matters
%
% A harmonic representation is cut off at some *bandwidth* - the highest
% harmonic degree kept - and that single number decides both how fine a
% detail can be represented and how expensive everything is. Too low and
% sharp peaks are smeared and ringing appears around them; too high and the
% representation faithfully reproduces noise.
%
% This is the same trade-off as the halfwidth in density estimation, seen
% from the other side, and it recurs unchanged for functions on rotations
% in <SO3Functions.html Orientation Functions>.
%
%% Where to start
%
% <S2FunConcept.html Concept> is the overview of the representations above.
% <S2FunOperations.html Operations> covers the arithmetic - sums, products,
% integrals, rotations, minima and maxima - and
% <S2FunPlotting.html Plotting> the ways of drawing a sphere on a page.
%
% Getting a function from data is
% <S2FunApproximationInterpolation.html Approximation and Interpolation>;
% going the other way, choosing where to evaluate it, is
% <S2FunSampling.html Sampling>. The second matters more than it sounds
% whenever an integral has to be computed from a finite number of
% evaluations.
%
% <SphericalHarmonics.html Spherical Harmonics> and
% <S2FunHarmonicRepresentation.html Harmonic Representation> develop the
% basis and the bandwidth above. <S2Kernels.html Spherical Kernel Functions>
% covers the bumps of the kernel representation, and
% <SO3FunConvolution.html Convolution> the operation that smooths one
% function with another - which is what density estimation is.
%
% <S2FunSym.html Symmetric Function> handles functions invariant under a
% symmetry, as any function of crystal directions must be, and
% <S2Bingham.html Bingham Distribution> is a specific statistical model for
% directions.
%
% <S2FunRadon.html Radon Transform> is the operation that turns an
% orientation density into a pole figure, and so the mathematical heart of
% <PoleFigureAnalysis.html pole figure inversion>.
%
% Functions whose values are not numbers have their own pages:
% <S2FunVectorValued.html Vector Valued Spherical Functions>,
% <S2FunVectorField.html Vector Field> and
% <S2FunAxisField.html Axis Field> - the last being for fields of axes,
% where direction has no sign, exactly as in <Vectors.html Vectors>.
%
% <S1FunHarmonics.html Fourier Series> is the one-dimensional relative, for
% functions of a single angle.
%
%% Next
%
% The same ideas for functions on rotations rather than directions are
% <SO3Functions.html Orientation Functions>, and the most important such
% function is the <ODFAnalysis.html ODF>. The directions these functions are
% defined over are <Vectors.html Vectors>.
%
