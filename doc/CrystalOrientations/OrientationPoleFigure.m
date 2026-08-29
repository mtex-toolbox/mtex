%% Pole Figures
%
%%
% A pole figure answers one question: given a crystal direction, where in
% the specimen does it point? A pole is a direction fixed in the lattice,
% commonly the normal to a lattice plane. The plot therefore turns a
% population of orientations into a two dimensional view in the specimen
% reference frame.
%
% This page assumes the coordinate map from
% <DefinitionAsCoordinateTransform.html Theory>, the equivalent directions
% from <OrientationSymmetry.html Symmetry>, and the Miller notation from
% <CrystalDirections.html Crystal Directions>. The choice of hemisphere and
% projection is developed in <SphericalProjections.html Spherical
% Projections>. MTEX uses an equal-area projection by default.
%
% A *reference frame* is the coordinate system in which data are expressed.
% The plotting convention below lays specimen Y upward and specimen X to the
% right. It changes only the screen layout; it does not rotate the specimen
% or re-express the data.

plottingConvention.default('y↑→x');

cs = crystalSymmetry('321');

ori = orientation.rand(cs);

%% Building One by Hand
%
% Fix the normal to the $(100)$ lattice plane in the crystal frame.
% Parentheses denote plane-normal |hkl| notation; square brackets would
% denote a lattice direction in |uvw| notation.

h = Miller({1,0,0},cs);

%%
% <Miller.symmetrise.html |symmetrise|> applies the crystal point group to
% the pole. The orientation then maps every returned pole into the specimen
% frame.

r = ori * h.symmetrise;

poleCount = length(r)

%%
% The count is six. Point group 321 has six operations, and all six produce
% distinct directions for this pole. A pole on a symmetry axis can have
% fewer distinct directions because several operations may coincide.
%
% Plot the specimen directions in a spherical projection.

plot(r);

%%
% Notice three points on each hemisphere. Together they are the six
% crystallographically equivalent positions of the $(100)$ pole for one
% orientation; they are not six different orientations.

%% The Shortcut
%
% <orientation.plotPDF.html |plotPDF|> performs the symmetrisation, coordinate
% map, and projection for several poles at once.

plotPDF(ori,Miller({1,0,-1,0},{0,0,0,1},{1,1,-2,1},ori.CS));

%%
% The first two pole figures need only one hemisphere, while the third needs
% both. MTEX makes that decision from symmetry. It uses one hemisphere when
% |h| and |-h| are crystallographically equivalent, because the other half
% then repeats the same information.
%
% In 321 this holds for $(10\bar{1}0)$ and $(0001)$. The twofold axes in the
% basal plane turn the c-axis pole into its opposite. It does not hold for
% $(11\bar{2}1)$, so that pole figure retains both hemispheres.
%
% The |'antipodal'| flag identifies opposite poles even when crystal symmetry
% does not. This is a modelling choice, not another point-group operation.
% It is conventional for kinematic diffraction under Friedel's law, but
% resonant scattering can distinguish a Friedel pair. See
% <VectorsAxes.html Axes and Antipodal Symmetry>.
%
% This orientation has the default identity specimen symmetry. If an
% orientation carries a nontrivial specimen symmetry, |plotPDF| also repeats
% the poles by that symmetry in the specimen frame. Crystal symmetry acts
% before the orientation map; specimen symmetry acts after it. See
% <SpecimenSymmetry.html Specimen Symmetry>.

%% What One Pole Figure Leaves Out
%
% A pole position fixes where one crystal direction points, but not the
% rotation of the crystal about that direction. All orientations that put
% |h| at one specimen direction form an
% <OrientationFibre.html orientation fibre>. One pole figure therefore
% cannot determine a complete orientation or ODF by itself.
%
% Combining pole figures for several lattice planes constrains the missing
% information. That is the inverse problem treated in
% <PoleFigureAnalysis.html Pole Figure Analysis>.

%% Contour Plots
%
% The option |'contourf'| replaces the discrete markers with a kernel density
% estimate on the sphere.

plotPDF(ori,Miller({1,0,-1,0},{0,0,0,1},{1,1,-2,1},ori.CS),...
  'contourf');
mtexColorbar;

%%
% For this single orientation the contours merely spread each discrete pole
% into a small spot; the first family still represents only six poles. For a
% population of measured or simulated orientations, the contours instead
% show where poles concentrate.
%
% The colour scale is in multiples of a random distribution (m.r.d.). A
% value of 1 is the pole density of an untextured population, while 2 means
% twice that density. Pole densities computed directly from an ODF are
% developed in <ODFPoleFigure.html Pole Figures of an ODF>.

%% The Maths Behind a Pole Figure
%
% Let $\mathbf{O}$ map crystal coordinates to specimen coordinates. Let
% $\mathbf{C}$ be a crystal-symmetry operation and $\mathbf{P}$ a
% specimen-symmetry operation. Every pole drawn by |plotPDF| has the form
%
% $$ \mathbf{r} = \mathbf{P}\,\mathbf{O}\,\mathbf{C}\,\mathbf{h},
%    \qquad \mathbf{C} \in \mathrm{S}_{\mathrm{c}}, \quad
%    \mathbf{P} \in \mathrm{S}_{\mathrm{s}}. $$
%
% In this example the specimen group contains only the identity, so the hand
% construction reduces to $\mathbf{r}=\mathbf{O}\mathbf{C}\mathbf{h}$.

%% References
%
% * H.-J. Bunge, <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis
% in Materials Science: Mathematical Methods>, Butterworths, English ed.,
% 1982, develops pole figures and their relation to orientation densities.
% * U. F. Kocks, C. N. Tomé and H.-R. Wenk,
% <https://assets.cambridge.org/97805217/94206/excerpt/9780521794206_excerpt.pdf
% Texture and Anisotropy>, Cambridge University Press, 1998, connects pole
% figures, texture, and anisotropic material properties.
% * R.-J. Roe, <https://doi.org/10.1063/1.1714396 Description of Crystallite
% Orientation in Polycrystalline Materials. III. General Solution to Pole
% Figure Inversion>, _Journal of Applied Physics_ 36 (1965), 2024-2031,
% gives the classical harmonic relation between pole figures and an ODF.
% * The International Union of Crystallography,
% <https://dictionary.iucr.org/Friedel%27s_law Friedel's law>, states when
% opposite reflections have equal intensities and when they may differ.
% * <https://doi.org/10.1520/E0081-96R24 ASTM E81-96(2024)>, _Standard Test
% Method for Preparing Quantitative Pole Figures_, covers quantitative
% X-ray pole-figure measurement by reflection and transmission methods.

%% Next
%
% The opposite question - given a specimen direction, which crystal
% direction points along it - is the
% <OrientationInversePoleFigure.html Inverse Pole Figure>. Both are
% projections and both discard information. The full orientation space is
% shown in <OrientationVisualization3d.html 3D Plots> and
% <OrientationVisualizationSections.html Section Plots>.

%#ok<*NOPTS>
