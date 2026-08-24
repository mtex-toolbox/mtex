%% ODF
%
%%
% A million measured orientations are not an answer. The orientation
% distribution function, or ODF, is the answer: a single function that says
% how much of the material sits at each orientation, in place of the list of
% individual measurements it was built from.
%
% Being a *density* is the whole point, and it is where most
% misunderstandings start. An ODF does not assign a volume fraction to one
% exact orientation - the fraction of any material sitting at exactly one
% orientation is zero, in the same way that no one in a room is exactly 180
% centimetres tall. It assigns a fraction to a *region* of orientations, and
% the function tells you how that fraction concentrates. The value is
% reported in multiples of a random distribution: 1 everywhere means no
% texture at all, and a peak of 20 means twenty times as much material near
% that orientation as random chance would put there.
%
% Below, the same data as points and as a density. The black dots are
% individual measured orientations; the colours are the ODF estimated from
% them, both shown in the same pole figure.

mtexdata forsterite silent
ori = ebsd('Forsterite').orientations;

odf = calcDensity(ori,'halfwidth',10*degree);

h = Miller(1,0,0,ori.CS);

plotPDF(odf,h,'contourf','figSize','small')
hold on
plotPDF(ori(1:200:end),h,'MarkerSize',3,'MarkerFaceColor','k','MarkerEdgeColor','k')
hold off

%%
% The step from dots to colours involved a choice: how wide a region each
% measurement should be spread over, the |halfwidth| above. Too small and
% the density is a bumpy record of exactly which orientations happened to be
% measured; too large and real peaks are flattened away. There is no value
% that is correct independently of the data, which is why
% <DensityEstimation.html Density Estimation> is a page of its own rather
% than a default nobody mentions.
%
%% A function on rotations, not on a sphere
%
% An ODF lives on the set of all rotations, which is three-dimensional and
% curved and has no faithful picture on a flat page. Everything you will
% ever see of an ODF is therefore a projection or a slice, and each kind
% throws away something different: a pole figure integrates along a line, a
% section shows one plane and hides the rest. Reading these plots is a
% skill, and it is worth knowing which information each one has discarded.
%
% Crystal symmetry applies here exactly as it does to a single orientation,
% and specimen symmetry may apply too, so an ODF is periodic in ways that
% are not obvious from any single view.
%
%% Where to start
%
% <ODFTheory.html Theory> defines the function and the normalisation above.
% <ODFModeling.html Calculations> builds ODFs directly - uniform, unimodal,
% fibre - which is the fastest way to learn to read the plots, since you
% know the answer in advance.
%
% The viewing pages come next. <ODFPlot.html Plot> is the overview;
% <ODFPoleFigure.html Pole Figures> and
% <ODFInversePoleFigure.html Inverse Pole Figures> are the two projections;
% <EulerAngleSections.html Euler Angle Sections> and
% <SigmaSections.html Sigma Sections> are the two common ways to slice.
% Sigma sections are usually the more honest of the two, because the
% distortion of Euler space near the poles makes Euler sections misleading
% about how concentrated a texture really is.
%
% <ODFComponents.html Components> and
% <ODFCharacteristics.html Properties> extract numbers - texture index,
% entropy, volume fractions, modes - which is what most papers actually
% report.
%
% How an ODF is represented internally matters once you compute with it.
% <SO3FunHarmonicRepresentation.html Series Expansion> stores coefficients,
% <RadialODFs.html Radial ODF> stores a sum of bumps,
% <FibreODFs.html Fibre ODF> stores density along a curve, and
% <BinghamODFs.html Bingham ODF> fits a specific statistical model. They are
% interchangeable in use and very different in cost and in what they can
% represent sharply.
%
% <DensityEstimation.html Density Estimation> and
% <RandomSampling.html Random Sampling> are the two directions between a
% list of orientations and a density.
% <DetectionOfSampleSymmetry.html Sample Symmetry> asks whether the
% specimen symmetry you assumed is really there,
% <ODFShapes.html Shapes> concerns the shape of the peaks themselves, and
% <ODFImport.html Import> and <ODFExport.html Export> handle files.
%
%% Next
%
% ODFs are estimated from maps in <EBSDAnalysis.html EBSD> and from
% diffraction data in <PoleFigureAnalysis.html Pole Figures>. The general
% machinery behind them is <SO3Functions.html Orientation Functions>. Using
% an ODF to predict a material property is <Tensors.html Tensors> and
% <Elasticity.html Elasticity>.
%
