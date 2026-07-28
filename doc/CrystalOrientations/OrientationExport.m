%% Exporting Crystal Orientations
%
%%
% Orientations are exported as plain ASCII files, which keeps them readable
% by any other software. This page is the counterpart of
% <OrientationImport.html Importing Crystal Orientations>.
%
% As an example we take a random sample from a model ODF.

cs = crystalSymmetry.load('quartz.cif');

odf = unimodalODF(orientation.byEuler(30*degree,50*degree,10*degree,cs), ...
  'halfwidth',10*degree);

ori = odf.discreteSample(100)

%% Exporting Euler Angles
%
% The command <quaternion.export.html |export|> writes the orientations
% into an ASCII file. By default the three Bunge Euler angles are written
% in degree, preceded by a header line naming the columns.

fname = fullfile(tempdir,'orientations.txt');
export(ori,fname)

%%
% Let us look at the beginning of the resulting file

fid = fopen(fname);
for k = 1:4, disp(fgetl(fid)); end
fclose(fid);

%% Other Conventions and Units
%
% Any of the Euler angle conventions described in
% <RotationDefinition.html Defining Rotations> may be used instead, and the
% angles may be written in radians rather than in degree.

export(ori,fname,'Matthies','radians')

fid = fopen(fname);
for k = 1:4, disp(fgetl(fid)); end
fclose(fid);

%%
% Passing the option |quaternion| writes the four quaternion components
% instead of Euler angles. This is the only one of the formats on this page
% that involves no angle conversion at all.

export(ori,fname,'quaternion')

fid = fopen(fname);
for k = 1:3, disp(fgetl(fid)); end
fclose(fid);

%% Exporting Additional Properties
%
% Often one wants to store more than the orientations alone - weights,
% grain sizes, or any other per orientation quantity. A struct passed to
% <quaternion.export.html |export|> is appended as additional columns, one
% per field, using the field names as column headers.

S.angle = ori.angle ./ degree;
S.weight = ones(size(ori)) ./ length(ori);

export(ori,fname,S)

fid = fopen(fname);
for k = 1:3, disp(fgetl(fid)); end
fclose(fid);

%% The VPSC Format
%
% Individual orientations are exported to the format expected by the VPSC
% code with <orientation.export_VPSC.html |export_VPSC|>. It always writes
% Euler angles together with a weight column, normalised to sum up to one.

fnameVPSC = fullfile(tempdir,'orientations_vpsc.txt');
export_VPSC(ori,fnameVPSC)

fid = fopen(fnameVPSC);
for k = 1:4, disp(fgetl(fid)); end
fclose(fid);

%%
% Weights differing from orientation to orientation are passed with the
% option |weights|.

export_VPSC(ori,fnameVPSC,'weights',rand(size(ori)))

%%
% Note that a whole ODF, rather than a list of individual orientations, is
% exported by the commands discussed in <ODFExport.html ODF Export>.

% clean up the temporary files
delete(fname); delete(fnameVPSC);
