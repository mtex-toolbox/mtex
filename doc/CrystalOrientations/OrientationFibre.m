%% Fibres of Orientations
%
%%
% A *fibre* is a one-dimensional curve through orientation space. Every
% orientation on a full fibre maps one fixed crystal direction |h| onto one
% fixed specimen direction |r| while leaving rotation about that direction
% free. MTEX stores the curve as a <fibre.fibre.html |@fibre|> variable.
%
% Many real textures concentrate around a line rather than one ideal
% orientation. Rolling textures of cubic metals are therefore commonly
% described by named fibres. A real texture has a finite spread around the
% curve; the curve itself is the ideal centreline.
%
% This page assumes <OrientationDefinition.html orientation construction>,
% <OrientationSymmetry.html symmetry-equivalent orientations>, and
% <OrientationFundamentalRegion.html the fundamental region>. The Cube and
% Goss components below are introduced in
% <OrientationStandard.html Standard Orientations>.
%
% A *reference frame* is the coordinate system in which data are expressed.
% The plotting convention below lays specimen Y upward and specimen X to the
% right. It changes only the screen layout, not the orientations.

plottingConvention.default('y↑→x');

% define crystal and specimen symmetry
cs = crystalSymmetry('432');
ss = specimenSymmetry('1');

% define two ideal orientations
ori1 = orientation.cube(cs,ss);
ori2 = orientation.goss(cs,ss);

% select the representative of Goss nearest to Cube
ori2 = ori2.project2FundamentalRegion(ori1);

%% A Fibre Segment Between Two Orientations
%
% The endpoint constructor joins two orientation representatives by their
% shortest angular path. The result is a finite segment, not yet the full
% closed fibre.

segmentFibre = fibre(ori1,ori2)

%%
% The summary identifies the aligned directions in its |h| and |r| row.
% Its endpoint row runs from Cube at $(0^\circ,0^\circ,0^\circ)$ to Goss at
% $(0^\circ,45^\circ,0^\circ)$ in Bunge Euler angles. Both endpoints, and
% every orientation |ori| between them, satisfy
%
% $$ \mathtt{ori} * h = r. $$
%
% The two directions belong to different reference frames: |h| is in the
% crystal frame and |r| is in the specimen frame.

%% The Segment in Euler Space
%
% The default three-dimensional orientation plot uses Bunge Euler
% coordinates.

plot(segmentFibre,'DisplayName','Fibre segment',...
  'lineWidth',4,'lineColor','green');
hold on
plot(ori1,'DisplayName','Cube','MarkerSize',12,...
  'MarkerFaceColor','darkred','MarkerEdgeColor','k');
plot(ori2,'DisplayName','Goss','MarkerSize',12,...
  'MarkerFaceColor','blue','MarkerEdgeColor','k');
hold off
legend('Location','northwest');

%%
% The green line runs from the dark-red Cube marker to the blue Goss marker.
% It looks straight because only $\Phi$ changes for this pair. In general,
% a shortest angular path need not look straight in Euler coordinates.

%% The Same Segment in Axis--Angle Space

plot(segmentFibre,'lineColor','green','lineWidth',6,'axisAngle');
hold on
plot(ori1,'MarkerFaceColor','darkred','MarkerSize',15,'axisAngle');
plot(ori2,'MarkerFaceColor','blue','MarkerSize',15,'axisAngle');
hold off

%%
% This is the same orientation-space segment in different coordinates.
% The endpoints and angular distances have not changed. Only the coordinate
% map used to draw them has changed.

%% Extending the Segment to a Full Fibre
%
% The option |'full'| discards the finite endpoint and continues through
% every rotation about the aligned direction.

fullFibre = fibre(ori1,ori2,'full')

%%
% The |h| and |r| row is unchanged, while the endpoint row has disappeared.
% Orientation space itself has no boundary, so the full fibre closes into a
% circle. Coordinate domains and symmetry-reduced fundamental regions do
% have seams and boundaries, however, and can cut that circle into arcs.

hold on
plot(fullFibre,'lineColor','gold','lineWidth',3,...
  'project2FundamentalRegion','axisAngle');
hold off

%%
% The gold curve continues the green segment to the faces of the cubic
% fundamental region. Its boundary points reconnect through
% symmetry-equivalent faces, so this boundary-to-boundary line represents
% one closed fibre.

%% Fibres in Pole Figures
%
% Everything that can be plotted for orientations can also be plotted for
% fibres. <fibre.plotPDF.html |plotPDF|> maps the fibre into
% <OrientationPoleFigure.html pole figures>, where one orientation becomes a
% point and a fibre becomes a curve.

h = Miller({1,1,0},{1,1,1},cs);
plotPDF(fullFibre,h,'lineWidth',3,'lineColor','orange');

%%
% Each panel contains one trace from the representative fibre. A trace may
% meet a projection boundary, but it still represents one continuous set of
% orientations.

%% Symmetrising a Fibre
%
% Unlike an orientation pole-figure plot, a fibre is not automatically
% symmetrised. <fibre.symmetrise.html |symmetrise|> generates the
% crystallographically equivalent fibres. The |'unique'| option removes
% repeated copies.

symFibre = fullFibre.symmetrise('unique');
symmetryCopyCount = length(symFibre)

%%
% The six copies correspond to the six cubic equivalents of the aligned
% crystal direction. Plotting them adds the orange traces that were absent
% from the representative-only pole figures.

plotPDF(symFibre,Miller({1,1,0},{2,1,0},{1,1,1},cs),...
  'lineWidth',3,'lineColor','orange');

%% Fibres in Inverse Pole Figures
%
% <fibre.plotIPDF.html |plotIPDF|> maps the fibre into
% <OrientationInversePoleFigure.html inverse pole figures>. It fixes
% specimen directions and draws the crystal directions found along the
% fibre. By default it restricts them to the fundamental sector.

r = [vector3d(1,1,0),vector3d(2,1,0),vector3d(1,1,1)];
plotIPDF(symFibre,r,'lineWidth',3,'lineColor','orange');

%%
% Each panel folds the symmetry copies into one fundamental sector. The
% orange curve is therefore the family of crystal directions that can lie
% along the specimen direction named above that panel.

%% The Complete Inverse Pole Figure
%
% The option |'complete'| removes the fundamental-sector restriction.

plotIPDF(symFibre,vector3d.Z,'complete',...
  'lineWidth',3,'lineColor','orange');

%%
% The complete plot repeats the curve across the full crystal-direction
% sphere. Those repeated traces are symmetry equivalents, not additional
% input fibres.

%% Defining a Fibre by Directions
%
% A <Miller.Miller.html |Miller|> direction and a
% <vector3d.vector3d.html |vector3d|> specimen direction define the full
% fibre directly. The next fibre contains every orientation that makes the
% crystal c-axis $[001]$ parallel to specimen Z.

cAxisFibre = fibre(Miller(0,0,1,cs,'uvw'),vector3d.Z)

%%
% The summary states that [001] is parallel to (0,0,1). The directions are
% shown in crystal and specimen coordinates, respectively.

plot(cAxisFibre,'lineColor','gold','lineWidth',4,...
  'project2FundamentalRegion','axisAngle');

%%
% The gold line is the symmetry-reduced image of every possible rotation
% about the aligned c-axis. Its two boundary ends continue into one another,
% so it represents one full fibre rather than one finite segment.
%
% If both constructor directions are |Miller| variables, the fibre instead
% contains all misorientations that bring one crystal direction into
% alignment with the other.

%% A Fibre Through One Orientation
%
% An initial orientation |ori1| and a crystal direction |h| define all
% orientations that preserve the mapped direction of |ori1|:
%
% $$ \mathtt{ori} * h = \mathtt{ori1} * h. $$
%
% The following full fibre passes through Cube and rotates about its
% $[111]$ axis.

cube111Fibre = fibre(ori1,Miller(1,1,1,cs,'uvw'))

%%
% Its summary reports that [111] is parallel to (1,1,1). Cube maps this
% crystal direction onto the same specimen direction.

plot(cube111Fibre,'lineColor','darkred','lineWidth',4,...
  'project2FundamentalRegion','axisAngle');

%%
% The dark-red curve passes through the Cube orientation at zero angle. Its
% ends meet the boundary at symmetry-equivalent continuations of the curve.
%
% <fibre.orientation.html |orientation|> samples a fibre for numerical work.
% <fibre.angle.html |angle|> measures the angular distance from an
% orientation to its nearest point on a fibre. Their geometric use without
% crystal symmetry is developed in <RotationFibre.html Fibres in Rotation
% Space>.

%% Predefined Rolling Fibres
%
% Cubic rolling textures have named segments, as their ideal components do:
% alpha, beta, gamma, epsilon, eta, tau, and theta. MTEX provides each as a
% static |fibre| constructor. These names assume the conventional rolling
% frame and orthorhombic specimen symmetry.

ss = specimenSymmetry('orthorhombic');
beta = fibre.beta(cs,ss);

%%
% Plot the conventional endpoint segment returned by each constructor.
% Passing |'full'| would extend that segment around its entire direction-pair
% circle.

plot(fibre.alpha(cs,ss),'lineWidth',3,...
  'lineColor',ind2color(1),'DisplayName','alpha');
hold on
plot(fibre.beta(cs,ss),'lineWidth',3,...
  'lineColor',ind2color(2),'DisplayName','beta');
plot(fibre.gamma(cs,ss),'lineWidth',3,...
  'lineColor',ind2color(3),'DisplayName','gamma');
plot(fibre.epsilon(cs,ss),'lineWidth',3,...
  'lineColor',ind2color(4),'DisplayName','epsilon');
plot(fibre.eta(cs,ss),'lineWidth',3,...
  'lineColor',ind2color(5),'DisplayName','eta');
plot(fibre.tau(cs,ss),'lineWidth',3,...
  'lineColor',ind2color(6),'DisplayName','tau');
plot(fibre.theta(cs,ss),'lineWidth',3,...
  'lineColor',ind2color(7),'DisplayName','theta');
hold off
legend('Location','best');

%%
% The coloured curves occupy different routes through Euler space and meet
% at some shared ideal components. Each colour marks only the conventional
% named segment, not every point on its full direction-pair circle.

%% Fibre ODFs
%
% A fibre is a curve of zero orientation-space volume, while a real texture
% has a spread around one. <fibreODF.html |fibreODF|> turns the full curve
% into a density with a given halfwidth. This is the model fitted against a
% measurement.

betaFull = fibre.beta(cs,ss,'full');
odf = fibreODF(betaFull,'halfwidth',10*degree);

%%
% The result is an |SO3FunCBF| with a de la Vallée Poussin kernel. Its
% $10^\circ$ halfwidth is the distance where the density has fallen to half
% its peak, not a cutoff radius. The density is constant along the ideal
% fibre and decays away from it.

plot3d(odf);
hold on
plot(betaFull.symmetrise,...
  'lineColor','blue','lineWidth',4);
hold off

%%
% The blue curves are the ideal centrelines. The surrounding surface is the
% finite-width density, so it forms a tube rather than a line.

%% Evaluating an ODF Along a Fibre
%
% <SO3Fun.plotFibre.html |plotFibre|> evaluates an ODF along a chosen curve.
% Here the beta-fibre ODF is read along the eta fibre.

plotFibre(odf,fibre.eta(cs,ss),'lineWidth',2);

%%
% The vertical axis is density in multiples of a random distribution. The
% broad maximum marks the part of the eta segment closest to the beta-fibre
% ridge.

%% The Volume Around a Fibre
%
% <SO3Fun.volume.html |volume|> integrates the ODF inside a tube of a given
% angular radius about a fibre. This is the quantity meant when a texture is
% reported as "so many percent beta fibre".

volume5Percent = 100 * volume(odf,betaFull,5*degree)

%%
% The result is about 58 percent within $5^\circ$ of the fibre it was built
% on. At the $10^\circ$ kernel halfwidth, the numerical tube integral
% reaches unity.

volume10Percent = 100 * volume(odf,betaFull,10*degree)

%%
% The second result is 100 percent to the precision printed. It does not
% mean the ODF is a zero-width line or vanishes at $10^\circ$.
% <SO3Fun.fibreVolume.html |fibreVolume|> discretises the tube and clips its
% numerical estimate at 1, so the displayed percentage can be exactly 100.

%% The Maths Behind Pole Figures
%
% Let $f(g)$ be an ODF, $h$ a crystal direction, and $r$ a specimen
% direction. The pole density at $r$ is
%
% $$ P_h(r) = \int_{\{g:\,g h=r\}} f(g)\,\mathrm{d}g. $$
%
% The integration set is exactly the full orientation fibre defined by
% |g * h = r|. This crystallographic Radon transform connects the geometry
% on this page to measured pole figures and ODF reconstruction; see the
% <PoleFigureTutorial.html pole figure tutorial>.

%% References
%
% * H.-J. Bunge, <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis
% in Materials Science: Mathematical Methods>, Butterworths, 1982. Chapter
% 5 develops fibre textures and their orientation distributions.
% * A. Morawiec, <https://doi.org/10.1007/978-3-662-09156-2 Orientations
% and Rotations: Computations in Crystallographic Textures>, Springer,
% 2004. This book develops rotation-space geometry and symmetry-reduced
% regions.
% * O. Engler and V. Randle, <https://doi.org/10.1201/9781420063660
% Introduction to Texture Analysis>, CRC Press, 2nd ed., 2010. It connects
% ideal components and fibres to measured macrotexture and microtexture.
% * L. A. I. Kestens and H. Pirgazi,
% <https://doi.org/10.1080/02670836.2016.1231746 Texture formation in metal
% alloys with cubic crystal structures>, _Materials Science and Technology_
% 32 (2016). This review discusses the named rolling fibres of cubic alloys.
% * <https://www.iso.org/standard/82165.html ISO 3785:2023>, _Metallic
% materials -- Designation of test specimen axes in relation to product
% texture_, standardises the specimen-axis language used for rolled products.

%% Next
%
% Fibres of plain rotations, without crystal symmetry, are
% <RotationFibre.html Fibres in Rotation Space>. Density models, halfwidth,
% and fitting are developed in <FibreODFs.html Fibre ODFs>. Pole-figure
% integration over fibres continues in <ODFPoleFigure.html Pole Figures of
% an ODF>.

%#ok<*NOPTS>
