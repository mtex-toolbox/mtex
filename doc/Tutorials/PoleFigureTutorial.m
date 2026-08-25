%% Pole Figure Tutorial
%
%%
% X-ray, synchrotron and neutron diffraction do not see individual crystals.
% They measure, for a few lattice planes, how much of the specimen has that
% plane facing a given direction - a pole figure. This tutorial takes such a
% measurement from the files to an ODF.

%% Importing the data
%
% <matlab:import_wizard Import pole figure data> starts the
% <import_wizard.html import wizard>, which asks for everything that is not
% in the files - the crystal symmetry, which file holds which lattice plane,
% how the specimen is aligned - and ends by writing a script. What follows
% is such a script.

% This script was automatically created by the import wizard. You should
% run the whole script or parts of it in order to import your data. There
% is no problem in making any changes to this script.
%
% *Specify Crystal and Specimen Symmetries*

% crystal symmetry for this ZnCuTi data is hexagonal.  Here we define the crystallographic unit cell and how it relates to cartesian xyz axes.
CS = crystalSymmetry('6/mmm', [2.633 2.633 4.8], 'X||a*', 'Y||b', 'Z||c');

% specimen symmetry tells MTEX if a certain symmetry should be present in the plotted pole figures.  The command used here selects triclinic, the most flexible option.
SS = specimenSymmetry('1');

% plotting convention: z out of the screen, x pointing north
how2plot = plottingConvention(vector3d.Z,-vector3d.Y);
how2plot.makeDefault;

%%
% *Specify File Names*

% path to files downloaded with the MTEX package
pname = [mtexDataPath filesep 'PoleFigure' filesep 'ZnCuTi' filesep];

% which pole figure files are to be imported
fname = {...
  [pname 'ZnCuTi_Wal_50_5x5_PF_002_R.UXD'],...
  [pname 'ZnCuTi_Wal_50_5x5_PF_100_R.UXD'],...
  [pname 'ZnCuTi_Wal_50_5x5_PF_101_R.UXD'],...
  [pname 'ZnCuTi_Wal_50_5x5_PF_102_R.UXD'],...
  };

% defocusing correction to compensate for the equipment-dependent loss of intensity at certain angles.
fname_def = {...
  [pname 'ZnCuTi_defocusing_PF_002_R.UXD'],...
  [pname 'ZnCuTi_defocusing_PF_100_R.UXD'],...
  [pname 'ZnCuTi_defocusing_PF_101_R.UXD'],...
  [pname 'ZnCuTi_defocusing_PF_102_R.UXD'],...
  };

%%
% *Specify Miller Indices*
%
% Nothing in a data file says which lattice plane it belongs to, so this
% list has to be right and in the same order as the file names above.

h = { ...
  Miller(0,0,2,CS),...
  Miller(1,0,0,CS),...
  Miller(1,0,1,CS),...
  Miller(1,0,2,CS),...
  };

%%
% *Import the Data*
%
% The second set of files is a measurement of a texture-free specimen. It
% records how much intensity the instrument loses as the specimen is tilted,
% and dividing it out is the defocusing correction.

% create a Pole Figure variable containing the data
pf = PoleFigure.load(fname,h,CS,SS,'interface','uxd');

% create a defocusing pole figure variable
pf_def = PoleFigure.load(fname_def,h,CS,SS,'interface','uxd');

% correct data by applying the defocusing compensation
pf = correct(pf,'def',pf_def);

%%
% Everything is now in one variable, and the first thing to do with it is to
% look at it.

plot(pf)

%%
% 4608 measurements over four pole figures, each drawn as a dot coloured by
% its intensity - see <PoleFigurePlot.html Plotting> for the other ways.
%
% What to check before going on: that the Miller indices ended up on the
% right pole figures, and that X, Y and Z point where the specimen was
% actually aligned. Both are assumptions made at import, and neither can be
% recovered later. <PoleFigureCorrection.html Data Correction> covers the
% repairs that are possible - rotating, scaling, removing outliers,
% superposing - of which the simplest is to remove impossible values:

pf(pf.intensities<0) = 0;
plot(pf)

%%
% On this data set that line changes nothing, since the defocusing
% correction left no negative intensity behind. On many data sets it does,
% and a negative diffracted intensity is always an artefact of a correction
% rather than a measurement.

%% Reconstructing an ODF
%
% <PoleFigure.calcODF.html |calcODF|> finds an ODF whose pole figures match
% the measured ones.

odf = calcODF(pf,'silent')

%%
% That problem has no unique solution - several ODFs produce the same pole
% figures, and <PoleFigure2ODFAmbiguity.html the ambiguity page> shows why.
% As a rule of thumb: the more pole figures, and the more consistent they
% are with each other, the less the ambiguity matters.
%
% The check is always the same. Recalculate the pole figures from the ODF
% and compare them with the measurement:

plotPDF(odf,pf.h)

%%
% and put a number on it, one per pole figure:

calcError(odf,pf)

%%
% Between 0.04 and 0.06 - a good fit. When it is not,
% <PoleFigure2ODF.html ODF Estimation> discusses what to change.

%% Looking at the result

plot(odf)
mtexColorMap LaboTeX

%%
% The ODF reaches only 1.9 mrd, so this ZnCuTi sheet is weakly textured:
% there is a preferred orientation, but nothing like the factor of ten a
% rolled sheet often shows. <ODFAnalysis.html the ODF chapter> is what to
% read next - how to plot such a function, take it apart into components,
% and compute the material properties that follow from it.
