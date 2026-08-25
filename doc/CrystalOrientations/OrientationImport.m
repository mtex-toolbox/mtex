%% Importing Crystal Orientations
%
%%
% Lists of orientations usually arrive as a text file of Euler angles - one
% orientation per line, three columns. Reading it needs two things: the
% crystal symmetry the angles refer to, and a statement of what the columns
% contain.

plottingConvention.default('y↑→x');

% the crystal symmetry, here from a cif file
cs = crystalSymmetry.load('quartz.cif');

%%
% <orientation.load.html |orientation.load|> then reads the file.

fname = fullfile(mtexDataPath,'orientation','Tongue_Quartzite_Bunge_Euler');

ori = orientation.load(fname,'columnNames',{'phi1','Phi','phi2'},cs)

%%
% The result is an ordinary <orientation.orientation.html |@orientation|>
% list, ready for a pole figure.

plotPDF(ori,Miller({0,0,0,1},{1,0,-1,0},cs))

%% What the Options Are For
%
% The three angles are the mandatory columns; further columns are named
% alongside them and come back as a struct of properties.
%
% || |'columnNames'| || what each column holds ||
% || |'columns'| || which column positions to read them from ||
% || |'radians'| || the file is in radians, not degree ||
% || |'header'| || number of header lines to skip ||
% || |'delimiter'| || what separates the numbers ||
% || |'passive'| || the angles describe passive rotations ||
%
%% Two Conventions to Check Before Trusting the Result
%
% A file of Euler angles does not say which convention produced it, and
% reading it in the wrong one is silent - the orientations are simply all
% wrong, by a fixed transformation. Two questions have to be answered from
% outside the file:
%
% * *Which Euler angle convention?* |orientation.load| reads Bunge angles.
%   Other conventions are converted with
%   <orientation.byEuler.html |orientation.byEuler|>, see
%   <RotationDefinition.html Defining Rotations>.
%
% * *Active or passive?* MTEX orientations map crystal coordinates to
%   specimen coordinates. Much of the literature uses the opposite
%   direction, which is the |'passive'| flag here and is discussed in
%   <MTEXvsBungeConvention.html MTEX vs. Bunge Convention>.
%
% A third question - which crystal axes the Cartesian frame is aligned with
% - is answered by the |crystalSymmetry| the data is imported with, see
% <CrystalReferenceSystem.html The Crystal Reference System>.

%% Next
%
% Writing orientations back to a file is
% <OrientationExport.html Export>. Orientations measured on a grid across a
% specimen are imported as a map instead, see
% <EBSDImport.html Importing EBSD Data>.

%#ok<*NOPTS>
