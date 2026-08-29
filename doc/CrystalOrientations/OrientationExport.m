%% Exporting Crystal Orientations
%
%%
% Exporting an orientation means choosing a numerical representation that
% the receiving program understands. MTEX writes plain ASCII tables, so any
% program can read the numbers once their columns and conventions are known.
% This page is the counterpart of
% <OrientationImport.html Importing Crystal Orientations>.
%
% The table does not contain the complete MTEX |orientation| object. In
% particular, it does not store crystal symmetry or the crystal and specimen
% reference frames. A reference frame is the coordinate system in which data
% are expressed. The direction of the orientation map is also not stored.
%
% Record those choices beside the file. Their meaning is introduced in
% <DefinitionAsCoordinateTransform.html Crystal Orientation as Coordinate
% Transformation> and compared with Bunge's map direction in
% <MTEXvsBungeConvention.html MTEX vs. Bunge Convention>.

%% Define an Orientation Sample
%
% We use a random sample of 100 orientations from a model orientation
% distribution function (ODF).

cs = crystalSymmetry.load('quartz.cif');

odf = unimodalODF(orientation.byEuler(30*degree,50*degree,10*degree,cs), ...
  'halfwidth',10*degree);

ori = odf.discreteSample(100);
numOrientations = length(ori)

%%
% The output confirms that the list has 100 entries. The record count in a
% VPSC header later on must agree with this value.

%% Exporting Euler Angles
%
% <quaternion.export.html |export|> writes one orientation per row. Here we
% name the Bunge convention explicitly, so a session preference cannot
% change the file. The angles are written in degree unless |'radians'| is
% passed.

fname = fullfile(tempdir,'orientations.txt');
export(ori,fname,'Bunge')

%%
% The first line names the three columns. The following lines contain the
% Bunge Euler angles $(\varphi_1,\Phi,\varphi_2)$ in degree.

fid = fopen(fname);
for k = 1:4, disp(fgetl(fid)); end
fclose(fid);

%% Other Conventions and Units
%
% Without an explicit convention, |export| follows the session's Euler-angle
% preference. Any convention described in
% <RotationDefinition.html Defining Rotations> may be named instead.
% The next file uses Matthies angles in radians.

export(ori,fname,'Matthies','radians')

fid = fopen(fname);
for k = 1:4, disp(fgetl(fid)); end
fclose(fid);

%%
% The new header and values describe the same orientations in a different
% convention and unit. The file does not label the unit, so it must be
% recorded separately for the receiver.

%% Exporting Quaternions
%
% Passing |'quaternion'| writes the four quaternion components instead of
% Euler angles. This is the only format on this page that performs no angle
% conversion.

export(ori,fname,'quaternion')

fid = fopen(fname);
for k = 1:3, disp(fgetl(fid)); end
fclose(fid);

%%
% MTEX writes the scalar component first, in the order |a|, |b|, |c|, |d|.
% Other programs may use another order or sign convention, and a unit
% quaternion and its negative describe the same rotation. Check the
% receiver's contract before exchanging quaternion columns.

%% Exporting Additional Columns
%
% Often an orientation needs an associated weight, grain size, or another
% quantity. A struct passed to <quaternion.export.html |export|> appends one
% column per field and uses the field names as column headers. Every field
% must supply one value per orientation.

S.angle = ori.angle ./ degree;
S.weight = ones(size(ori)) ./ length(ori);

export(ori,fname,S,'Bunge')

fid = fopen(fname);
for k = 1:3, disp(fgetl(fid)); end
fclose(fid);

%%
% The preview shows that |angle| and |weight| remain aligned with the Euler
% angles on each row.

%% The VPSC Format
%
% <orientation.export_VPSC.html |export_VPSC|> writes individual
% orientations in the texture format expected by the VPSC crystal
% plasticity code. It writes three Euler angles and one relative volume
% fraction per row.
%
% VPSC supports the Bunge, Kocks, and Roe conventions. MTEX defaults to
% Bunge for this format regardless of the session preference. The fourth
% header line records |B|, |K|, or |R| together with the number of rows.

fnameVPSC = fullfile(tempdir,'orientations_vpsc.txt');
export_VPSC(ori,fnameVPSC)

fid = fopen(fnameVPSC);
for k = 1:6, disp(fgetl(fid)); end
fclose(fid);

%%
% The line |B 100| identifies Bunge angles and the 100 orientations. The
% following rows contain three angles in degree and a uniform weight.

%% Unequal VPSC Weights
%
% Pass weights that differ between orientations with the |'weights'| option.
% VPSC interprets them as relative volume fractions, so use nonnegative
% values with a positive sum. MTEX divides the supplied values by their sum
% before writing them.

weights = reshape(1:numOrientations,size(ori));
export_VPSC(ori,fnameVPSC,'weights',weights)

fid = fopen(fnameVPSC);
for k = 1:6, disp(fgetl(fid)); end
fclose(fid);

vpscData = readmatrix(fnameVPSC,'NumHeaderLines',4);
writtenWeightSum = sum(vpscData(:,4))

%%
% The first two written weights now differ. The final output checks their
% sum after the values have been rounded for the text file.

%% Choosing a Format
%
% Use Euler angles when the receiver specifies a convention and unit. Use
% quaternions when both programs agree on component order and signs. Use
% the VPSC format only when a polycrystal code expects its weighted texture
% table.
%
% If the data will stay in MTEX, MATLAB's |save| preserves the orientation
% object more completely than a numeric table. A whole ODF, rather than a
% list of individual orientations, is exported by the commands in
% <ODFExport.html ODF Export>.

%%
% Remove the temporary files.

delete(fname); delete(fnameVPSC);

%% References
%
% * H.-J. Bunge, <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis
% in Materials Science: Mathematical Methods>, Butterworths, English ed.,
% 1982, establishes the Euler-angle convention used in texture analysis.
% * D. Rowenhorst et al.,
% <https://doi.org/10.1088/0965-0393/23/8/083501 Consistent representations
% of and conversions between 3D rotations>, _Modelling and Simulation in
% Materials Science and Engineering_ 23, 083501, 2015, compares Euler,
% matrix, axis--angle, and quaternion conventions.
% * R. A. Lebensohn and C. N. Tomé,
% <https://doi.org/10.1016/0956-7151(93)90130-K A self-consistent anisotropic
% approach for the simulation of plastic deformation and texture development
% of polycrystals>, _Acta Metallurgica et Materialia_ 41, 2611--2624, 1993,
% introduces the VPSC formulation.
% * The <https://public.lanl.gov/lebenso/ VPSC project and manual> describe
% the weighted orientation input used by the code.

%% Next
%
% <OrientationEmbeddings.html Embeddings of Orientations> is the next page
% in this chapter. It replaces coordinate representations with tensors for
% statistics and machine learning. For a continuous orientation density,
% continue with <ODFExport.html ODF Export>.
