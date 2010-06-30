%% Generic Pole Figure Data Interface
% generic interface to import Pole Figure data
%
%%
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
% by the options |ColumnNames| and |Columns|. Furthermore, the files can be
% contain any number of header lines to be ignored using the option
% |HEADER|. If you feel unsure how to set the options use the import wizard
% to create a template. 
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
%  fourth column -> background intensity
% this can be passed to the loadPoleFigure method by specifying
ColumnNames = {'intensity' 'polar angle' 'azimuth angle' 'background'};
Columns = [1 2 3 4];

%% import the data

pf = loadPoleFigure(fname,cs,ss,'ColumnNames',ColumnNames,'Columns',Columns);


%% plot data

close; figure('position',[100,100,400,500]);
plot(pf)

%% See also
% [[interfacesPoleFigure_index.html,interfaces]] [[loadPoleFigure.html,loadPoleFigure]]
% [[S2Grid_plot.html,plot]] [[symmetry_symmetry.html,symmetry]]

