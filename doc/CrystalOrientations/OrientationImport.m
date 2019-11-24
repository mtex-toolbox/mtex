%% Importing Crystal Orientations
%
%%
% In order to import orientation data from a text file we first need to
% defined the corresponding <CrystalSymmetries.html crystal symmetry>, e.g.
% by a cif file

cs = crystalSymmetry.load('quartz.cif')

%%
% In the second step we may use the command <orientation.load.html
% |orientation.load|> to load the data. This function requires that one
% specifies the meaning of the column of the import file by the option
% |columnNames|.

fname = fullfile(mtexDataPath,'orientation','Tongue_Quartzite_Bunge_Euler');
ori = orientation.load(fname,'columnNames',{'phi1','Phi','phi2'},cs)

%%
% This creates a variable of type @orientation which can be used for
% further analysis, e.g. to plot pole figures

plotPDF(ori,Miller({0,0,0,1},{1,0,-1,0},cs))
