%% Importing and Exporting ODF Data
% Explains how to read and write ODFs to a data file
%
%% Open in Editor 
% 
%% Contents
%
%%
% MTEX suport the following formats for storing and importing of ODFs:
%
% * .mat file - lossless, specific for MTEX, binary format
% * MTEX file - lossless, specific for MTEX, ASCII format
% * VPSC file - not lossless, ASCII format
% * .txt file - not lossless, ASCII format
%
%
%% Define an Model ODF
%
% We will demonstrate the the import and export of ODFs at the following
% sample ODF which is defined as the superposition of several model ODFs.

cs = symmetry('cubic');
ss = symmetry('triclinic');
mod1 = orientation('axis',xvector,'angle',45*degree,cs);
mod2 = orientation('axis',yvector,'angle',65*degree,ss);
model_odf = 0.5*uniformODF(cs,ss) + ...
  0.05*fibreODF(Miller(1,0,0),xvector,cs,ss,'halfwidth',10*degree) + ...
  0.05*fibreODF(Miller(0,1,0),yvector,cs,ss,'halfwidth',10*degree) + ...
  0.05*fibreODF(Miller(0,0,1),zvector,cs,ss,'halfwidth',10*degree) + ...
  0.05*unimodalODF(mod1,cs,ss,'halfwidth',15*degree) + ...
  0.3*unimodalODF(mod2,cs,ss,'halfwidth',25*degree);
plot(model_odf,'sections',6,'silent')

%% Save as .mat file
%
% The most simplest way to store an ODF is to store the corresponding
% variabe odf as any other MATLAB variabel. 

% the filename
fname = fullfile(mtexDataPath, 'ODF', 'odf.mat');
save(fname,'model_odf')

%%
%
% Importing a .mat file is done simply by

load(fname)


%% Export as an generic ASCII file
%
% By default and ODF is exported in an ASCII file which consists of a large
% table with four columns, where the first three column describe the Euler
% angles of a regular 5° grid in the orientation space and the fourth
% column contains the value of the ODF at this specific position.

% the filename
fname = fullfile(mtexDataPath, 'ODF', 'odf.txt');

% export the ODF
export(model_odf,fname,'Bunge')

%%
% Other Euler angle conventions or other resolutions can by specified by
% options to <ODF.export.html export>. Even more control you have,
% if you specify the grid in the orientation space directly.

% define a equispaced grid in orientation space with resolution of 5 degree
S3G = SO3Grid(5 * degree,cs,ss);

% export the ODF by values at these locations
export(model_odf,fname,S3G,'Bunge','generic')



%% Export an ODF to an MTEX ASCII File
% Using the options *MTEX* the ODF is exported to an ASCII file which contains
% descriptions of all componets of the ODF in a human readable fassion.
% This format can be imported by MTEX without loss.

% the filename
fname = [mtexDataPath '/ODF/odf.mtex'];

% export the ODF
export(model_odf,fname,'Bunge','MTEX')

%%  Export to VPSC format
%
% TODO!!!

%% Import ODF Data using the import wizard
%
% Importing ODF data into MTEX means to create an ODF variable from data
% files containing euler angles and weigts. Once such an variable has been
% created the data can be analyzed and processed in many ways. See e.g.
% [[ODFCalculations.html,ODFCalculations]]. The most simplest way to import
% ODF data is to use the import wizard, which can be started either by
% typing into the command line

import_wizard('ODF')

%%
% or using from the start menu the item Start/Toolboxes/MTEX/Import Wizard.
% The import wizard provides a gui to import data of almost all ASCII
% data formats and allows to save the imported data as an ODF variable to
% the workspace or to generate a m-file loading the data automatically.
%
%% Importing EBSD data using the method loadODF
%
% A script generated by the import wizard typpicaly look as follows.

% define crystal and specimen symmetry
cs = symmetry('cubic');
ss = symmetry('triclinic');

% the file name
fname = [mtexDataPath '/odf/odf.txt'];

% the resolution used for the reconstruction of the ODF
res = 10*degree;

% load the data
odf = loadODF(fname,cs,ss,'resolution',res,'Bunge',...
  'ColumnNames',{'Euler 1','Euler 2','Euler 3','weight'});

% plot data
plotodf(odf,'sections',6,'silent')

%%
% So far ODFs may only exported from and imported into ASCII files that
% consists of a table of orientatiotions and weights. The orientations may
% be given either as Euler angles or as quaternions. The weight may either
% represent the value of the ODF at this specific orientation or it may
% represent the volume of a bell shaped function centerd at this
% orientation.
%
