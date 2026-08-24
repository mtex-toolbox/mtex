%% Pole Figures
%
%%
% X-ray and neutron diffraction do not see individual crystals. They see
% the whole illuminated volume at once, and what they measure is how much
% of it happens to have a chosen lattice plane facing a chosen direction.
% Rotate the sample, record the intensity of one diffraction peak at every
% setting, and the result is a *pole figure*: the density of one crystal
% direction over all specimen directions.
%
% This is the older road into texture analysis and still the right one for
% many problems. It averages over a volume rather than a polished surface,
% it needs no vacuum and no conductive sample, and the counting statistics
% come from far more crystals than any map contains. What it cannot tell
% you is where anything is.

plottingConvention.default('y↑→x');
mtexdata dubna silent

plot(pf,'figSize','small')

%%
% Seven pole figures are shown because one is not enough, and that is the
% central difficulty of this chapter rather than an incidental detail.
%
% One of the seven is labelled with two lattice planes rather than one.
% Their diffraction peaks fall too close together to separate, so what was
% recorded is the sum of two pole figures. This is common, it is not an
% error, and a reconstruction has to be told about it rather than left to
% treat the measurement as a single plane.
%
%% Why one pole figure is not enough
%
% Orientations live in a three-dimensional space; a pole figure is a
% two-dimensional picture. Each point of it collects every orientation that
% puts the chosen crystal direction along that specimen direction - a whole
% curve of orientations, added together and reported as one number. The
% information lost is exactly the position along that curve.
%
% Reconstructing an ODF therefore means combining several pole figures,
% measured for different lattice planes, and solving for the function
% consistent with all of them. That problem is solvable but it is not a
% simple inversion, and it does not have a unique answer.
%
%% The ghost effect
%
% There is a further loss that no amount of extra measurement repairs.
% Diffraction cannot distinguish a lattice plane's two sides, so a pole
% figure is always centrosymmetric even when the material is not. Written
% as a series expansion, the measurement determines the even-order terms of
% the ODF and says nothing whatever about the odd-order ones.
%
% The missing part has to be supplied by an assumption, and different
% assumptions give visibly different ODFs - typically spurious peaks where
% the material has none, which is where the name *ghost* comes from. This
% is not a numerical artefact to be tuned away. It is a genuine gap in what
% the experiment can know, and the pages below are about making a defensible
% choice rather than a hidden one.
%
%% Where to start
%
% <PoleFigureImport.html Import> and <PoleFigurePlot.html Plot> get data in
% and on screen. <PoleFigureCorrection.html Modify> covers the corrections
% that come before anything else - background, defocusing, normalisation,
% and removing points you have reason to distrust.
%
% <PoleFigure2ODF.html ODF Reconstruction> is the heart of the chapter, and
% <PoleFigureRefinement.html Iterative ODF Reconstruction> controls it in
% more detail. Read <PoleFigure2ODFAmbiguity.html The Ghost Effect> and
% <PoleFigure2ODFGhostCorrection.html Ghost Correction> alongside them
% rather than afterwards - they say what the reconstruction cannot do, which
% is the part that determines how far the result can be trusted.
%
% <PoleFigureSimulation.html Simulation> goes the other way, computing pole
% figures from a known ODF. This is the most reliable way to develop
% judgement here: reconstruct an ODF you already know and see what survives.
%
% Two worked examples follow the whole chain on real and standard data,
% <PoleFigureSantaFe.html Santa Fe Example> and
% <PoleFigureDubna.html Dubna Example>, and
% <PoleFigureExport.html Export> handles files.
%
%% Next
%
% What a reconstruction produces is an <ODFAnalysis.html ODF>. The same
% quantity measured one crystal at a time is <EBSDAnalysis.html EBSD>. The
% mathematics of the inversion belongs to
% <SphericalFunctions.html Spherical Functions> and
% <SO3Functions.html Orientation Functions>.
%
