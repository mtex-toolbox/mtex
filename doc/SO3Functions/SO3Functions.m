%% Orientation Functions
%
%%
% An orientation density function is a function on the set of all
% rotations. So is a misorientation distribution, so is the Schmid factor
% of a slip system as the crystal turns, so is the stiffness of a grain
% along a fixed specimen direction. This chapter is about that set of
% functions in general - the machinery of which an
% <ODFAnalysis.html ODF> is the most familiar instance.
%
% Keeping the two apart is useful. The ODF chapter is about texture: what
% the function means, how to estimate it, how to read its plots. This
% chapter is about the function: how it is stored, what it costs to
% evaluate, how to approximate one from data, what happens when you convolve
% or rotate or differentiate it.
%
% Below is such a function, shown in sigma sections - one of the ways of
% slicing a three-dimensional curved domain into flat pictures.

plottingConvention.default('y↑→x');

cs = crystalSymmetry('432');
odf = unimodalODF(orientation.byEuler(30*degree,50*degree,10*degree,cs),'halfwidth',15*degree);

plot(odf,'sigma','sections',6,'figSize','medium')

%%
% Six slices, and a single peak appearing in several of them. Rotations do
% not lie flat, and every plot in this chapter is a compromise of this kind.
%
%% Why rotations are harder than the sphere
%
% Functions on a sphere are two-dimensional and functions on rotations are
% three-dimensional, so everything costs more - but the real difficulties
% are elsewhere.
%
% Rotation space closes up on itself in a way that has no two-dimensional
% analogue, so there is no picture of it without cuts, and quantities that
% look far apart in Euler angles can be neighbours. Symmetry then folds it
% further: a function of crystal orientations is invariant under the crystal
% symmetry acting on one side and, if the specimen has symmetry, under that
% acting on the other. The domain a texture actually lives on is a small
% folded piece of the whole, and its shape depends on the point groups
% involved.
%
% The basis functions are the *Wigner-D functions*, the rotational
% counterpart of spherical harmonics. Bandwidth means the same thing as it
% does there, and costs more: the number of coefficients grows with the cube
% of the bandwidth rather than the square.
%
%% Where to start
%
% <SO3FunConcept.html Concept> and <SO3FunDefinition.html Definition>
% introduce the representations - harmonic, radial basis function, fibre,
% Bingham - and how to build each.
% <SO3FunOperations.html Operations> is the arithmetic.
%
% For viewing, <ODFPlot.html Plotting> is the overview and
% <SigmaSections.html Sigma Sections> and
% <EulerAngleSections.html Euler Angle Sections> are the two families of
% slice. These pages are shared with the ODF chapter, since the plots are
% the same whatever the function means.
%
% Approximation from data is the longest thread here, and the pages differ
% in method rather than in aim. <SO3FunApproximationTheory.html
% Interpolation> is the overview;
% <HarmonicApproximationTheory.html Harmonic Interpolation> fits
% coefficients, <RBFApproximationTheory.html RBF-Kernel Interpolation> fits
% a sum of bumps, and <SO3FunQuadrature.html Approximation and Quadrature>
% covers the numerical integration all of it rests on - how to evaluate an
% integral over rotations from finitely many samples, which is not obvious
% and not cheap.
%
% The representations themselves have pages of their own:
% <SO3FunHarmonicRepresentation.html Harmonic Representation>,
% <RadialODFs.html Radial Basis Functions>,
% <FibreODFs.html Fibre Functions> and <BinghamODFs.html Bingham ODF>.
% <SO3Kernels.html Rotational Kernel Functions> and
% <WignerFunctions.html Wigner-D Functions> are the building blocks
% underneath, and <SO3FunConvolution.html Convolution> the operation that
% joins them - smoothing, and the step from measurements to a density.
%
% <SO3FunSymmetricFunctions.html Symmetry> makes the folding described
% above explicit.
%
% Functions whose values are not scalars are
% <SO3FunVectorValued.html Vector Valued Functions> and
% <SO3FunVectorField.html Rotational Vector Fields>. The latter is how a
% texture's response to deformation is expressed, since it assigns to every
% orientation the direction it is being turned.
%
% <ODFImport.html Import> and <ODFExport.html Export> handle files.
%
%% Next
%
% What these functions mean when they describe a texture is
% <ODFAnalysis.html ODF>. The two-dimensional relatives are
% <SphericalFunctions.html Spherical Functions>, and the rotations
% underneath are <Rotations.html Rotations> and
% <CrystalOrientations.html Orientations>.
%
