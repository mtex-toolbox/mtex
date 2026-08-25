%% Importing Crystal Orientations
%
%%
% A list of crystal orientations usually arrives as a text file with one
% orientation per row. Unlike an EBSD map, the list has no spatial
% positions. Importing it requires the numeric representation, the crystal
% symmetry, and the reference frames in which the numbers were defined.
%
% This page assumes the orientation map introduced in
% <OrientationDefinition.html Defining Orientations> and the Euler-angle
% conventions from <RotationDefinition.html Defining Rotations>. It uses a
% three-column file of Bunge Euler angles in degrees.

plottingConvention.default('y↑→x');

% load the quartz symmetry and its crystal reference frame from a CIF file
cs = crystalSymmetry.load('quartz.cif');

%% Name the Columns
%
% The file contains three numeric columns but no header. Their names tell
% <orientation.load.html |orientation.load|> that the columns are the
% Bunge angles $(\varphi_1,\Phi,\varphi_2)$.

fname = fullfile(mtexDataPath,'orientation','Tongue_Quartzite_Bunge_Euler');

ori = orientation.load(fname,cs,'ColumnNames',{'phi1','Phi','phi2'})

%%
% The display reports a $382 \times 1$ <orientation.orientation.html
% |orientation|> array. It also identifies the quartz crystal symmetry and
% the specimen frame. MTEX stores all 382 orientations in this one
% vectorized object.

%% Check the Imported Texture
%
% A pole figure is a useful first sanity check, although it cannot prove a
% convention by itself. Here the $(0001)$ and $(10\bar{1}0)$ poles should
% show the texture carried by the imported orientations.

plotPDF(ori,Miller({0,0,0,1},{1,0,-1,0},cs));

%%
% Notice that the $(0001)$ poles concentrate around ND, whereas many
% $(10\bar{1}0)$ poles lie closer to the rim. The imported population is
% therefore textured rather than randomly distributed.

%% What the Options Are For
%
% For Euler input, the three angle columns are mandatory. Further named
% columns are returned in a struct when a second output is requested, as in
% |[ori,properties] = orientation.load(...)|. The field names are converted
% to lower case and have whitespace removed.
%
% || |'ColumnNames'| || what each imported column contains ||
% || |'Columns'| || positions of those columns in the file ||
% || |'radians'| || angles are in radians rather than degrees; see the limitation below ||
% || |'header'| || number of header lines to skip ||
% || |'delimiter'| || character that separates the numbers ||
% || |'passive'| || request the inverse map; see the limitation below ||
%
% The names and positions solve different problems. For example,
% |'Columns',[4 2 7]| selects physical columns 4, 2, and 7, while
% |'ColumnNames',{'phi1','Phi','phi2'}| assigns their meanings in that order.
%
% The generic importer advertises quaternion columns named
% |{'Quat real','Quat i','Quat j','Quat k'}|. In the current implementation,
% however, that path passes all four columns as one matrix to a constructor
% that expects four arrays and raises an error. Until it is fixed, read the
% numeric columns separately and construct
% |orientation(quaternion(a,b,c,d),cs)|. Quaternions avoid the Euler-angle
% sequence and angular-unit questions, but they do not identify the mapping
% direction or either reference frame.

%% Four Questions to Answer Before Trusting the Result
%
% A plain numeric file does not contain enough information to distinguish
% several valid interpretations. All four questions below must be answered
% from its header, accompanying documentation, or a known physical feature.
%
% * *Which Euler-angle convention?* This example uses the Bunge column names.
%   Equal angle triplets in other conventions describe different
%   orientations. Import those numeric columns and pass them to
%   <orientation.byEuler.html |orientation.byEuler|> with the convention
%   named explicitly; see <RotationDefinition.html Defining Rotations>.
%
% * *Degrees or radians?* The generic text importer ignores |'radians'| and
%   decides the unit from the values instead: a file is read as degrees only
%   when some angle exceeds 15, and as radians otherwise. A file of small
%   angles in degrees is therefore read as radians, silently and with
%   valid-looking results, so the values alone are not a reliable test.
%
% * *Active or passive?* MTEX orientations map coordinates from the crystal
%   frame into the specimen frame. Do not select |'passive'| merely because
%   a source calls its convention Bunge: reported Bunge Euler angles are
%   copied directly when the frames agree. The distinction is developed in
%   <MTEXvsBungeConvention.html MTEX vs. Bunge Convention>.
%
%   The generic text importer currently applies |'passive'| twice, so the
%   two inversions cancel and the option has no effect. Until that defect is
%   fixed, import first and use |ori = inv(ori)| only when an independent
%   convention check establishes that the stored map is the inverse.
%
% * *Which crystal and specimen frames?* The alignment between Cartesian
%   crystal axes and lattice axes belongs to the |crystalSymmetry| loaded
%   above; see <CrystalReferenceSystem.html The Crystal Reference System>.
%   The file documentation must also say which physical specimen directions
%   its axes denote. The explicit plotting convention on this page states
%   TD upward and RD to the right; it does not infer those directions from
%   the three columns.
%
% A known direction provides the strongest check. Verify that one indexed
% crystal direction maps to the specimen direction observed in the
% experiment. A plausible pole figure alone cannot distinguish every wrong
% combination of convention and frame.

%% References
%
% * H.-J. Bunge, <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis
% in Materials Science: Mathematical Methods>, Butterworths, English ed.,
% 1982, establishes the Euler-angle convention used in texture analysis.
% * G. Nolze, <https://doi.org/10.1002/crat.201400427 Euler angles and
% crystal symmetry>, _Crystal Research and Technology_ 50, 188--201, 2015,
% explains why unit-cell settings and specimen axes can give different
% Euler triplets for the same orientation.
% * D. Rowenhorst et al.,
% <https://doi.org/10.1088/0965-0393/23/8/083501 Consistent representations
% of and conversions between 3D rotations>, _Modelling and Simulation in
% Materials Science and Engineering_ 23, 083501, 2015, gives reproducible
% conversion rules for Euler angles, matrices, axis--angle pairs, and
% quaternions.
% * <https://www.iso.org/standard/82749.html ISO 24173:2024>, _Microbeam
% analysis -- Guidelines for orientation measurement using electron
% backscatter diffraction_, covers reliable and reproducible orientation
% measurements when a list originates from EBSD.

%% Next
%
% Writing orientations back to a file is
% <OrientationExport.html Export>. Orientations measured on a grid across a
% specimen are imported as a map instead; see
% <EBSDImport.html Importing EBSD Data>.

%#ok<*NOPTS>
