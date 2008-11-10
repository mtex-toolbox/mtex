%% Importing EBSD Data
%
% Importing EBSD data in MTEX means to create a <EBSD_index.html EBSD>
% object from data files containing euler angles. Once such an object has
% been created the data can be analyzed and processed in many ways. See e.g.
%
% [[EBSD_index.html,EBSD manipulation]], 
% <EBSD_plot.html plot>, 
% <EBSD_rotate.html rotate>, <EBSD_delete delete>,
%
% Furthermore, such a EBSD object is the starting point to estimate an ODF
% using the command <EBSD_calcODF.html calcODF>.
%
%
%% Inporting EBSD data using the import wizard
%
% The most simplest way to load EBSD data is to use the 
% [[import_wizard.html,import wizard]], which can be started either by
% typing into the command line 

import_wizard; 

%%
% or using from the start menu the item 
% *Start/Toolboxes/MTEX/Import Wizard EBSD* or by clicking rigth on a
% data file and choosing *import*. The import
% wizard provides a gui to import data of almost all data formats MTEX
% currently supports and to specify crystal symmetry, specimen symmetry,
% Euler angle convention and phase. The gui allows to save the imported
% them as a <EBSD_index.html EBSD> object to the workspace or to
% generate a m-file loading the data automatically.
%
%
%% Importing EBSD data using the method loadEBSD
%
% So far only diffraction data that are stored in a ascii file that consists
% of a table containing in each row the Eule angles of a single orientation
% can be imported using the command <loadEBSD.html loadEBSD>. 

% specify crystal and specimen symmetry
cs = symmetry('cubic');
ss = symmetry('triclinic');

% load EBSD data
ebsd = loadEBSD([mtexDataPath,'/aachen_ebsd/85_829grad_07_09_06.txt'],cs,ss,...
  'header',1,'layout',[5,6,7],'xy',[3 4])

plot(ebsd)

%% Importing EBSD data from unknown formats
%
% MTEX also provides a way to import data from formats currently not
% directly supported. Therefore you have to read the single orientations
% using standard MATLAB input and output commands. Then you have to call the
% constructor [[EBSD_EBSD.html,EBSD]] with these data to generate a EBSD
% obejct.
%
%% Writing your own interface
%
% Once you have written an interface that reads data from certain data files
% and generates a EBSD object you can integrate this method into MTEX by
% copying it into the folder |MTEX/qta/interfacesEBSD|. Then it will be
% automatical called by the methods loadEBSD. Examples how to write such an
% interface can be found in the directory |MTEX/qta/interfacesEBSD|.
%

