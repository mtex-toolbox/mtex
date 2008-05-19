%% MTEX - Generic Pole Figure Data Interface
%
% The generic interface allows to import pole figure data that are stored in a 
% ASCII file in the following way
%
%  theta_1 rho_1 intensity_1 background_1
%  theta_2 rho_2 intensity_2 background_2
%  theta_3 rho_3 intensity_3 background_3
%  .      .       .       .
%  .      .       .       .
%  .      .       .       .
%  theta_M rho_M intensity_M background_m
%
% The actual position and order of the columns in the file can be specified
% by the option |LAYOUT|. Furthermore, the files can be contain any number
% of header lines to be ignored using the option |HEADER|.
% 
% The following example was provided by Dr. Garbe from Munich

%% specify crystal and specimen symmetries

cs = symmetry('-3m',[4.7578,4.7578,12.97]);
ss = symmetry;

%% specify the file names

fname = {...
  [mtexDataPath '/munich/munich_003.txt'],...
  };

%% set data layout
% the Munich data format consists of 4 columns, where
%  first column  -> intensities
%  second column -> rho angle
%  third column  -> theta angle
%  fourth column  -> background intensity
% this can be passed to the loadPoleFigure method by specifying
layout = [2 3 1 4];

%% import the data

pf = loadPoleFigure(fname,cs,ss,'layout',layout);

%% using the import wizard
% one may also use the import wizard to determine the right layout

pf = loadPoleFigure(fname,cs,ss);


%% plot data

close; figure('position',[100,100,400,500]);
plot(pf)

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
