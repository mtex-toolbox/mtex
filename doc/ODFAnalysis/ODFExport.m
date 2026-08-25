%% ODF Export
%
%%
% Export is a choice about which information the receiving program needs.
% MTEX supports four common representations:
%
% * a |.mat| file with the MTEX object - exact and binary;
% * an MTEX ASCII file with its components - exact for supported component
% representations and readable by MTEX;
% * a generic table of ODF values on an orientation grid;
% * a VPSC table of weighted discrete orientations.
%
% The last two are finite approximations to a continuous ODF. Record the
% grid resolution or number of orientations whenever results must be
% reproducible.
%
%% Define a Model ODF
%
% We demonstrate the formats with a mixture of uniform, fibre and unimodal
% components.

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


%% Export as a Generic ASCII File
%
% By default an ODF is exported as a table with four columns. The first
% three contain the Euler angles of a regular $5^\circ$ orientation grid;
% the fourth contains the ODF value at that location. This samples the
% function rather than preserving its internal representation, so a grid
% that is too coarse can miss narrow texture components.

% the filename
fname = fullfile(tempdir, 'odf.txt');

% export the ODF
export(model_odf,fname,'Bunge')

%%
% Other Euler-angle conventions and resolutions can be specified with
% options to <SO3Fun.export.html |export|>. For complete control, construct
% and pass the orientation grid directly.

% define a equispaced grid in orientation space with resolution of 5 degree
S3G = equispacedSO3Grid(cs,'resolution',5*degree);

% export the ODF by values at these locations
export(model_odf,fname,S3G,'Bunge','generic')



%% Export an ODF to an MTEX ASCII File
% With the |'mtex'| interface the ODF is exported as a human-readable
% description of its components. MTEX can import this representation again
% without replacing those components by samples on a grid.

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
% The shorthand |'VPSC'| selects this interface directly. The number of
% orientations controls how finely the continuous ODF is represented.

fname = fullfile(tempdir, 'odfvpsc.txt');

export(model_odf,fname,'VPSC','points',5000)

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

%% Choosing a Format
%
% Use |.mat| while continuing an analysis in MTEX, and MTEX ASCII when a
% readable component description is useful. Use a generic grid when the
% receiving program expects function values, and VPSC when it expects a
% synthetic polycrystal. Grid spacing and sample size are accuracy
% parameters, not merely file-format options. The difference between a
% random statistical sample and an optimized numerical representation is
% discussed in <RandomSampling.html Random Sampling>.



