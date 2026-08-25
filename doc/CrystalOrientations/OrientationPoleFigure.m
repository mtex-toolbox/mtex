%% Pole Figures
%
%%
% A pole figure answers one question: given a crystal direction, where in
% the specimen does it point? It is the standard two dimensional view of
% orientation data, and it is built from the coordinate transform of
% <DefinitionAsCoordinateTransform.html Theory> in three steps.

plottingConvention.default('y↑→x');

cs = crystalSymmetry('321')

%%

ori = orientation.rand(cs)

%% Building One by Hand
%
% Fix a crystal direction.

% the fixed crystal direction (100)
h = Miller({1,0,0},cs);

%%
% Apply the orientation to every direction symmetrically equivalent to it,
% which gives the specimen directions the crystal sends them to.

r = ori * h.symmetrise

%%
% Plot the result in a spherical projection.

plot(r)

%%
% Six points, because the trigonal group 321 has six symmetry elements and
% each of them contributes one equivalent direction, see
% <OrientationSymmetry.html Symmetry>. All six are the same physical
% direction of the same crystal.

%% The Shortcut
%
% <orientation.plotPDF.html |plotPDF|> does all of that, for several crystal
% directions at once.

plotPDF(ori,Miller({1,0,-1,0},{0,0,0,1},{1,1,-2,1},ori.CS))

%%
% Some of the three pole figures show one hemisphere, others show both. The
% rule is symmetry: where |h| and |-h| are symmetrically equivalent, the two
% hemispheres carry the same information and MTEX draws only the upper one.
% In 321 that holds for $(10\bar10)$ and for $(0001)$, since the twofold
% axes in the basal plane turn c into -c. It does not hold for
% $(11\bar21)$, so that pole figure needs both hemispheres. Imposing the
% reduced view regardless is what the |'antipodal'| flag does, see
% <VectorsAxes.html Axes and Antipodal Symmetry>.

%% Contour Plots
%
% The option |'contourf'| replaces the markers by filled contours.

plotPDF(ori,Miller({1,0,-1,0},{0,0,0,1},{1,1,-2,1},ori.CS),'contourf')
mtexColorbar

%%
% For a single orientation this only smears six points, but it is how pole
% figures of a whole population are read - measured ones, or ones computed
% from an ODF, where the contours are a density and the colorbar counts
% multiples of a random distribution. See
% <ODFPoleFigure.html Pole Figures of an ODF> and
% <PoleFigureAnalysis.html Pole Figure Analysis>.

%% Next
%
% The opposite question - given a specimen direction, which crystal
% direction points along it - is the
% <OrientationInversePoleFigure.html Inverse Pole Figure>. Both are
% projections and both discard information; the full picture is
% <OrientationVisualization3d.html 3D Plots> and
% <OrientationVisualizationSections.html Section Plots>.

%#ok<*NOPTS>
