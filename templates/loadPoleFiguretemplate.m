%% Import Script for PoleFigure Data
%
% This script was automatically created by the import wizard. You should
% run the whoole script or parts of it in order to import your data. There
% is no problem in making any chages to this scrip.

%% Specify Crystal and Specimen Symmetries

% crystal symmetry
CS = {crystal symmetry};

% specimen symmetry
SS = {specimen symmetry};

% plotting convention
{plotting convention}

%% Specify File Names

% path to files
pname = {path to files};

% which files to be imported
fname = {file names};

%% Specify Miller Idice

h = {Miller};

c = {structural coefficients};

%% Import the Data

% create a Pole Figure variable containing the data
pf = loadPoleFigure(fname,h,CS,SS,{structural coefficients},'interface',{interface},{options});

%% Visualize the Data

% plot of the raw data
plot(pf)

%% ODF estimatio

% estimate some ODF
odf = calcODF(pf)

%% Plot Caclulated Pole Figures

plotpdf(odf,h)
