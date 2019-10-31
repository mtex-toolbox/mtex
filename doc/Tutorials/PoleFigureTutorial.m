%% Pole Figure Tutorial
%
%%
% This tutorial explains the basic concepts on ananyzing x-ray, synchrotron
% and neutron diffraction data.
%
%% Import diffraction data
% Click on <matlab:import_wizard('PoleFigure') Import pole figure data> to
% start the import wizard which is a GUI leading you through the import of
% pole figure data. After finishing the wizard you will end up with a
% script similar to the following one.

% This script was automatically created by the import wizard. You should
% run the whole script or parts of it in order to import your data. There
% is no problem in making any changes to this script.
%
% *Specify Crystal and Specimen Symmetries*

% crystal symmetry
CS = crystalSymmetry('6/mmm', [2.633 2.633 4.8], 'X||a*', 'Y||b', 'Z||c');

% specimen symmetry
SS = specimenSymmetry('1');

% plotting convention
setMTEXpref('xAxisDirection','north');
setMTEXpref('zAxisDirection','outOfPlane');

%%
% *Specify File Names*

% path to files
pname = [mtexDataPath filesep 'PoleFigure' filesep 'ZnCuTi' filesep];

% which files to be imported
fname = {...
  [pname 'ZnCuTi_Wal_50_5x5_PF_002_R.UXD'],...
  [pname 'ZnCuTi_Wal_50_5x5_PF_100_R.UXD'],...
  [pname 'ZnCuTi_Wal_50_5x5_PF_101_R.UXD'],...
  [pname 'ZnCuTi_Wal_50_5x5_PF_102_R.UXD'],...
  };

% defocusing
fname_def = {...
  [pname 'ZnCuTi_defocusing_PF_002_R.UXD'],...
  [pname 'ZnCuTi_defocusing_PF_100_R.UXD'],...
  [pname 'ZnCuTi_defocusing_PF_101_R.UXD'],...
  [pname 'ZnCuTi_defocusing_PF_102_R.UXD'],...
  };

%%
% *Specify Miller Indices*

h = { ...
  Miller(0,0,2,CS),...
  Miller(1,0,0,CS),...
  Miller(1,0,1,CS),...
  Miller(1,0,2,CS),...
  };

%%
% *Import the Data*

% create a Pole Figure variable containing the data
pf = PoleFigure.load(fname,h,CS,SS,'interface','uxd');

% defocusing
pf_def = PoleFigure.load(fname_def,h,CS,SS,'interface','uxd');

% correct data
pf = correct(pf,'def',pf_def);

%%
% After running the script the variable |pf| is created which contains all
% information about the pole figure data. You may plot the data using the
% command <PoleFigure.plot.html plot>

plot(pf)

%%
% By default pole figures are plotted as intensity colored dots for any
% data point. There are many options to specify the way pole figures are
% plotted in MTEX. Have a look at the <PoleFigurePlot.html plotting
% section> for more information.
%
% After import make sure that the Miller indices are correctly assigned to
% the pole figures and that the alignment of the specimen coordinate
% system, i.e., X, Y, Z is correct. In case of outliers or misaligned data,
% you may want to correct your raw data. Have a look at the
% <PoleFigureCorrection.html correction section> for further information.
% MTEX offers several methods correcting pole figure data, e.g.
%
% * rotating pole figures
% * scaling pole figures
% * find outliers
% * remove specific measurements
% * superpose pole figures
%
% As an example we set all negative intensities to zero

pf(pf.intensities<0) = 0;
plot(pf)

%
%% ODF Estimation
%
% Once your data are in a good shape, i.e. defocusing correction has been
% done and only few outliers are left you can reconstruct an ODF out of
% these data. This is done by the command <PoleFigure.calcODF.html
% calcODF>.

odf = calcODF(pf,'silent')

%%
% Note that reconstructing an ODF from pole figure data is a severely ill-
% posed problem, i.e., it does *not* provide a unique solution. A more
% throughout discussion on the ambiguity of ODF reconstruction from
% pole figure data can be found <PoleFigure2ODFAmbiguity.html here>. As a
% rule of thumb: as more pole figures you have and as more consistent you
% pole figure data are the better your reconstructed ODF will be.
%
% To check how well your reconstructed ODF fits the measured pole figure
% data do

plotPDF(odf,pf.h)

%%
% Compare the recalculated pole figures with the measured data. 
% A quantitative measure for the fitting are the so called RP values. They
% can be computed by

calcError(odf,pf)

%%
% In the case of a bad fitting, you may want to tweak the reconstruction
% algorithm. See <PoleFigure2ODF.html here> for more information.

%% Visualize the ODF
% Finally one can plot the resulting ODF

plot(odf)
mtexColorMap LaboTeX

%%
% restore old setting
setMTEXpref('xAxisDirection','east');