%% Tutorials
%
%%
% Crystallographic texture is the statistical distribution of crystal
% orientations in a specimen. MTEX reaches that distribution from two main
% kinds of measurement: orientation maps and diffraction pole figures.
%
% Each tutorial below follows one short, reproducible analysis from data
% import to an interpreted result. Open a tutorial in the MATLAB editor,
% run it section by section, and change one choice at a time.
%
%   edit EBSDTutorial;
%
% A tutorial is a worked route, not a measurement protocol. Parameters such
% as reconstruction thresholds and smoothing widths depend on the specimen
% and the scientific question. The linked chapters explain those choices.
%
%% Before you start
%
% <GeneralConcepts.html General Concepts> introduces the MTEX object model.
% One variable usually holds a vectorized list of measurements or grains,
% and selecting a subset is how an analysis narrows its question.
%
% <NotationAndConventions.html Notation and Conventions> states MTEX's
% choices for angles, Euler angles, and the direction of an orientation.
% It distinguishes planes from directions and covers crystal-axis alignment,
% plotting conventions, units, and the names used in examples.
%
% Before the diffraction route, read <CrystalDirections.html Miller Indices>
% and <SpecimenSymmetry.html Specimen Symmetry>. They introduce Miller indices
% and the specimen invariance used in pole-figure reconstruction.
%
%% Choose the route that matches your measurement
%
% *Electron backscatter diffraction (EBSD)* records a phase and an
% orientation at each sampled position on a polished surface. The resulting
% orientation map retains spatial information: it says what was measured
% and where it was measured.
%
% Start with <EBSDTutorial.html EBSD>, which imports and audits a map.
% It plots phase and orientation maps, reconstructs grains, and plots pole
% figures and inverse pole figures. Continue with <GrainTutorial.html Grains>
% to compare pixel and grain orientations. It selects and measures grains
% and previews boundaries between phases. Then use
% <BoundaryTutorial.html Grain Boundaries> to analyse their interfaces.
%
% Before importing your own map, read <EBSDReferenceFrame.html Reference
% Frame>. A reference frame is the coordinate system in which the data are
% expressed. It is distinct from crystal symmetry and from the plotting
% convention that lays the frame out on screen.
%
% *X-ray and neutron diffraction* measure many crystals together. For one
% selected lattice plane, a pole figure records intensity over specimen
% directions. It describes an illuminated volume but does not retain the
% spatial position of each contributing crystal.
%
% Start with <PoleFigureTutorial.html Pole Figure Data>, which imports and
% corrects measured pole figures. It reconstructs an ODF and checks it
% against the measurements. Continue with <ODFTutorial.html ODFs> for ODFs
% estimated from orientations and for model ODFs.
%
%% Where the two routes meet
%
% An orientation distribution function (ODF) is a continuous density over
% crystal orientations. It can be estimated from individual EBSD
% orientations or reconstructed from diffraction pole figures.
%
% The ODF is therefore a common representation for texture from either
% route. An EBSD orientation list can also be projected directly into pole
% figures when that is the comparison the experiment requires.
% Continue with <ODFTutorial.html ODFs> from either route. It estimates an
% ODF from individual EBSD orientations, reconstructs one from pole figures,
% and defines a model ODF.
%
% <VPSCImport.html VPSC> starts from a third kind of input: simulated texture
% from the visco-plastic self-consistent deformation code. It is intended
% for readers who already have modelling output rather than measurements.
%
%% Continue into the chapters
%
% The worked EBSD route leads into <EBSDAnalysis.html EBSD>,
% <Grains.html Grains>, and <GrainBoundaries.html Grain Boundaries>.
% The diffraction route leads into <PoleFigureAnalysis.html Pole Figures>,
% and both routes meet again in <ODFAnalysis.html ODF>.
%
% The objects used throughout these chapters begin with
% <Vectors.html Vectors> and <CrystalGeometry.html Crystal Geometry>.
% Return to those foundations when directions, rotations, orientations, or
% symmetry become the subject rather than merely an input.
%
%% Further reading
%
% * O. Engler, S. Zaefferer and V. Randle,
% <https://doi.org/10.1201/9781003258339 Introduction to Texture Analysis:
% Macrotexture, Microtexture, and Orientation Mapping>, 3rd ed., CRC Press,
% 2024, connects diffraction measurements with orientation microscopy.
% * H.-J. Bunge, <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis
% in Materials Science: Mathematical Methods>, Butterworths, English ed.,
% 1982, develops the classical pole-figure and ODF theory.
% * <https://doi.org/10.1520/E0081-96R24 ASTM E81-96(2024)> covers X-ray
% acquisition of quantitative pole figures.
% * <https://www.iso.org/standard/74309.html ISO 13067:2020> specifies EBSD
% procedures for measuring average grain size on two-dimensional sections.
%
