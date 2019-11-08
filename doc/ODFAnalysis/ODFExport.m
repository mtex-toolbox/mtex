%% ODF Export
%
%%
% MTEX support the following formats for storing and importing of ODFs:
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

cs = crystalSymmetry('cubic');
mod1 = orientation.byAxisAngle(xvector,45*degree,cs);
mod2 = orientation.byAxisAngle(yvector,65*degree,cs);
model_odf = 0.5*uniformODF(cs) + ...
  0.05*fibreODF(Miller(1,0,0,cs),xvector,'halfwidth',10*degree) + ...
  0.05*fibreODF(Miller(0,1,0,cs),yvector,'halfwidth',10*degree) + ...
  0.05*fibreODF(Miller(0,0,1,cs),zvector,'halfwidth',10*degree) + ...
  0.05*unimodalODF(mod1,'halfwidth',15*degree) + ...
  0.3*unimodalODF(mod2,'halfwidth',25*degree);
plot(model_odf,'sections',6,'silent')

%% Save as .mat file
%
% The most simplest way to store an ODF is to store the corresponding
% variable odf as any other MATLAB variable. 

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
S3G = equispacedSO3Grid(cs,'resolution',5*degree);

% export the ODF by values at these locations
export(model_odf,fname,S3G,'Bunge','generic')



%% Export an ODF to an MTEX ASCII File
% Using the options *MTEX* the ODF is exported to an ASCII file which contains
% descriptions of all components of the ODF in a human readable fassion.
% This format can be imported by MTEX without loss.

% the filename
fname = [mtexDataPath '/ODF/odf.mtex'];

% export the ODF
export(model_odf,fname,'Bunge','MTEX')

%%  Export to VPSC format
%
% TODO!!!
