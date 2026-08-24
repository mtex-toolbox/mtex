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
% The simplest way to store an ODF is to store the corresponding
% variable |model_odf| as any other MATLAB variable using the command
% |save|. Note that you have to specify the variable name as a string.

% the filename - all files on this page are written into the temporary
% directory, so that running it does not overwrite the ODF files shipped
% with MTEX
fname = fullfile(tempdir, 'odf.mat');
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
fname = fullfile(tempdir, 'odf.txt');

% export the ODF
export(model_odf,fname,'Bunge')

%%
% Other Euler angle conventions or other resolutions can by specified by
% options to <SO3Fun.export.html export>. Even more control you have,
% if you specify the grid in the orientation space directly.

% define a equispaced grid in orientation space with resolution of 5 degree
S3G = equispacedSO3Grid(cs,'resolution',5*degree);

% export the ODF by values at these locations
export(model_odf,fname,S3G,'Bunge','generic')



%% Export an ODF to an MTEX ASCII File
% Using the options *MTEX* the ODF is exported to an ASCII file which contains
% descriptions of all components of the ODF in a human readable fashion.
% This format can be imported by MTEX without loss.

% the filename
fname = fullfile(tempdir, 'odf.mtex');

% export the ODF
export(model_odf,fname,'Bunge','interface','mtex')

%%  Export to VPSC format
%
% <https://public.lanl.gov/lebenso/ VPSC> and other crystal plasticity
% codes do not read an ODF but a list of weighted orientations. The VPSC
% interface therefore draws a discrete sample from the ODF and writes it in
% the VPSC texture format - a three line header, the number of points, and
% then one row of Bunge Euler angles plus a weight per orientation.
%
% Note that the interface has to be selected explicitly. Writing
% |export(odf,fname,'VPSC')| is *not* enough - |'VPSC'| would be read as an
% unknown flag and the generic interface used instead.

fname = fullfile(tempdir, 'odfvpsc.txt');

export(model_odf,fname,'interface','VPSC','points',5000)

%%
% Let us look at the beginning of the resulting file

fid = fopen(fname);
for k = 1:6, disp(fgetl(fid)); end
fclose(fid);

%%
% The number of orientations is controlled by the option |'points'|, which
% defaults to 10000. The counterpart, reading such a file back, is
% described in <VPSCImport.html Import from VPSC>.

delete(fname)




