%% Import EBSD Data
%
%% Abstract
% Importing EBSD data into MTEX means to create a variable of type
% <EBSD_index.html EBSD> from certain data files. Once such an variable has
% been created the data can be <EBSDPlot.html plotted> and  
% <ModifyEBSDData.html analyzed and processed> in many ways.
% Furthermore, such an EBSD variable is the starting point for
% <GrainModelling.html grain reconstruction> and <EBSD2ODF_estimation.html
% ODF estimation>.
%
%% Contents
%
%% Inporting EBSD data using the import wizard
%
% The most simplest way to load EBSD data is to use the 
% <matlab:import_wizard('EBSD') import wizard>, which 
% can be started either by typing into the command line 

import_wizard('EBSD'); 

%%
% or using from the start menu the item 
% *Start/Toolboxes/MTEX/Import Wizard EBSD* or by clicking on a
% data file and choosing *import* from the context menu. The import
% wizard provides a gui to import data of almost all EBSD data formats
% and to save the imported data as a <EBSD_index.html EBSD> variable to the
% workspace or to generate a m-file loading the data automatically.
%
%% Features of the import wizard
%
% * import Euler angles in various conventions
% * import quaternions
% * import EBSD data with weights
% * import multiple phases with multiple crystal symmetries
% * import arbitrary additional data, e.g. MAD, BC, ...
% * specify crystal symmetry by CIF files
% 
%% Supported Interfaces
%
% MTEX inlcudes interfaces to the EBSD data formates 
%
% * [[loadEBSD_ang.html,.ang]]
% * [[loadEBSD_ctf.html,.ctf]]
% * [[loadEBSD_xxx.html,.csv]]
% * [[loadEBSD_generic.html,.txt]]
%
% In the case of generic text files MTEX is unsure about the column
% association in the data file. It will ask the user which colums
% corresponds to which physical properties.
%
%% The Import Script
%
% A script generated by the import wizard has the following form. Running
% the script imports the data and stores them in a variable with name ebsd.
% The script can be freely modyfied and extended to the needs of the user. 

% specify crystal and specimen symmetry
CS = {...
  symmetry('m-3m'),... % crystal symmetry phase 1
  symmetry('m-3m')};   % crystal symmetry phase 2
SS = symmetry('-1');   % specimen symmetry

% file name
fname = [mtexDataPath '/aachen_ebsd/85_829grad_07_09_06.txt'];

% import ebsd data
ebsd = loadEBSD(fname,CS,SS,'interface','generic',...
  'ColumnNames', { 'id' 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3' 'Mad' 'BC'},...
  'ignorePhase', 0, 'Bunge');

plot(ebsd,'phase',1)


%% Writing your own interface
%
% It is not very difficult to write an interface for importing your own
% data format. Once you have written an interface that reads data from
% certain data files and generates a EBSD object you can integrate this
% method into MTEX by copying it into the folder |MTEX/qta/interfaces|.
% Then it will be automatical recognized by the import wizard. Examples how
% to write such an interface can be found in the directory
% |MTEX/qta/interfaces|. 
%

