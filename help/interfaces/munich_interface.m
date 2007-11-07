%% Munich data interface
%% 
% The following examples shows how to import a Munich data set.

%% specify crystal and specimen symmetries

cs = symmetry('-3m',[4.7578,4.7578,12.97]);
ss = symmetry;

%% specify the file names

fname = {...
  [mtexDataPath '/munich/munich_003.txt'],...
  [mtexDataPath '/munich/munich_024.txt'],...
  [mtexDataPath '/munich/munich_110.txt'],...
  [mtexDataPath '/munich/munich_113.txt'],...
  [mtexDataPath '/munich/munich_114.txt'],...
  [mtexDataPath '/munich/munich_116.txt'],...
  [mtexDataPath '/munich/munich_214.txt']};

%% set data layout
% the Munich data format consists of 4 columns, where
%  first column  -> intensities
%  second column -> rho angle
%  third column  -> theta angle
% this can be passed to the loadPoleFigure method by specifying
layout = [2 3 1];

%% import the data

pf = loadPoleFigure(fname,cs,ss,'layout',layout);

%% plot data

close; figure('position',[100,100,400,500]);
plot(pf(1))

%% See also
% [[interfaces_index.html,interfaces]] [[loadPoleFigure.html,loadPoleFigure]]
% [[S2Grid_plot.html,plot]] [[symmetry_symmetry.html,symmetry]]

%% Specification
%
% * *.txt ascii - files
% * one file per pole figure
% * one headerline
% * table with 4 colums containing: intensity, theta, rho, correction
% * angles in degree
%
