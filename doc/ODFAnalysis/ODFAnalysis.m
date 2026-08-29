%% Orientation Distribution Functions
%
%%
% *Crystallographic texture* is the distribution of crystal orientations in
% a specimen. A measured orientation list says what was observed, but an
% orientation distribution function (ODF) describes the population as a
% continuous density over orientation space.
%
% This chapter assumes that an orientation maps the crystal frame into the
% specimen frame. Review <DefinitionAsCoordinateTransform.html Orientation
% Theory> and <OrientationSymmetry.html Orientation Symmetry> if that map or
% its symmetry-equivalent representatives are not yet familiar.
%
% Density is the central idea. In the continuous model, the volume fraction
% at one exact orientation is zero, just as the fraction of people who are
% exactly 180 centimetres tall is zero. A material fraction comes from
% integrating the ODF over a region of orientations.
%
% MTEX reports density in *multiples of a random distribution* (mrd). A
% uniform texture is 1 mrd everywhere. A value of 20 mrd means that the
% density near that orientation is twenty times the random reference, not
% that 20 percent of the material has that exact orientation.

plottingConvention.default('y↑→x');

%% From Measured Orientations to a Density
%
% The same EBSD data are shown below as discrete points and as a density.
% <rotation.calcDensity.html |calcDensity|> places a kernel around each
% measured orientation. <SO3Fun.plotPDF.html |plotPDF|> then projects the
% estimated ODF into a pole density figure for the crystal direction |h|.

mtexdata forsterite silent
ori = ebsd('Forsterite').orientations;

odf = calcDensity(ori,'halfwidth',10*degree);
h = Miller(1,0,0,ori.CS);

plotPDF(odf,h,'contourf','figSize','small')
hold on
plotPDF(ori(1:200:end),h,'MarkerSize',3, ...
  'MarkerFaceColor','k','MarkerEdgeColor','k')
hold off
mtexColorbar('title','mrd')

%%
% Each black dot is the specimen direction of |h| for one orientation in a
% regular subsample. The dots gather along a single high-density band. The
% band leaves the disc at one point of the rim and returns at the opposite
% point, because a pole figure identifies opposite directions and its rim is
% glued to itself. Isolated dots remain outside the filled contours,
% because the colours show a smoothed estimate rather than an outline around
% every observation.
%
% The step from dots to colours requires a smoothing scale. The |halfwidth|
% states how far each measurement is spread through orientation space. Too
% small a halfwidth gives a bumpy record of the particular sample. Too large
% a halfwidth flattens real peaks. No value is correct independently of the
% data; <DensityEstimation.html Density Estimation> develops this choice.
%
% A second choice is what should count once. Pixel orientations weight the
% scanned area when the pixels have equal area. Grain mean orientations
% weight grains equally unless grain areas are supplied with the |'weights'|
% option. Both choices are useful, but they answer different physical
% questions.

%% A Function on Rotations, Not on a Sphere
%
% An ODF lives on the set of rotations. This space is three-dimensional and
% curved, so it has no faithful picture on a flat page. Every ODF figure is
% therefore a view with a specific loss of information.
%
% A pole figure integrates the ODF along an orientation fibre. An inverse
% pole figure exchanges the chosen crystal and specimen directions. A
% section evaluates a two-dimensional slice and hides density away from that
% slice. These plots can resemble one another while answering different
% questions.
%
% Crystal symmetry identifies equivalent numerical rotations exactly as it
% does for a single orientation. Specimen symmetry may identify further
% copies, but it should only be imposed when the specimen supports that
% assumption. Equivalent copies are not additional material.

%% Recommended Reading Order
%
% Begin with <ODFTheory.html Theory> for the normalization and the
% density-versus-volume distinction. If the ODF comes from measured
% orientations, read <DensityEstimation.html Density Estimation> next.
% <ODFModeling.html Calculations> then builds uniform, unimodal, and fibre
% ODFs with known answers.
%
% <ODFPlot.html Plot> compares the available views. Continue in the order
% used by the chapter contents: <ODFPoleFigure.html Pole Figures>,
% <ODFInversePoleFigure.html Inverse Pole Figures>,
% <EulerAngleSections.html Euler Angle Sections>, and
% <SigmaSections.html Sigma Sections>. Conventional $\varphi_2$ sections are
% compact for many cubic rolling textures. Sigma sections are often easier
% to interpret for trigonal, tetragonal, and hexagonal crystals because each
% panel reads like a pole figure of one chosen crystal axis, with the panel
% angle recording the remaining rotation about that axis.
%
% After the section pages, <ODFComponents.html Components> locates and
% partitions modal populations. <ODFCharacteristics.html Properties>
% extracts texture index, entropy, modes, and volume fractions. These are
% the scalar quantities most papers report when they compare textures.
%
% The remaining pages are branches rather than one linear course.
% <ODFShapes.html Shapes> compares kernels; read it before
% <RadialODFs.html Radial ODFs>, whose components are sums of those kernels.
% <FibreODFs.html Fibre ODFs> spreads density along a curve, while
% <BinghamODFs.html Bingham ODFs> fits a parametric statistical model.
% <SO3FunHarmonicRepresentation.html Series Expansion> explains harmonic
% coefficients, bandwidth, and approximation. These representations share
% the |SO3Fun| interface, but differ in storage cost and in how efficiently
% they represent sharp features.
%
% <ODFImport.html Import> and <ODFExport.html Export> handle files.
% <RandomSampling.html Random Sampling> turns a continuous ODF back into a
% finite orientation list, the reverse direction from density estimation.
% <DetectionOfSampleSymmetry.html Sample Symmetry> aligns an assumed specimen
% symmetry and explains why that alignment is not proof that the symmetry
% exists.

%% Further Reading
%
% * H.-J. Bunge, <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis
% in Materials Science: Mathematical Methods>, Butterworths, English ed.,
% 1982. This is the classical treatment of ODFs, symmetry, pole figures, and
% Euler sections.
% * U. F. Kocks, C. N. Tomé, and H.-R. Wenk,
% <https://books.google.com/books?id=vkyU9KZBTioC Texture and Anisotropy>,
% Cambridge University Press, 2000. It connects measured texture to
% anisotropic material properties and processing history.
% * H. Schaeben,
% <https://doi.org/10.1107/S0021889892009270 Towards Statistics of Crystal
% Orientations in Quantitative Texture Analysis>, _Journal of Applied
% Crystallography_ 26 (1993), 112-121. It develops statistical models and
% kernel density estimation for individual orientation measurements.

%% Next
%
% ODFs are estimated from maps in <EBSDAnalysis.html EBSD> and reconstructed
% from diffraction data in <PoleFigureAnalysis.html Pole Figures>. The
% general machinery behind them is <SO3Functions.html Orientation
% Functions>. Using an ODF to predict a material property is covered in
% <Tensors.html Tensors> and <Elasticity.html Elasticity>.
%
