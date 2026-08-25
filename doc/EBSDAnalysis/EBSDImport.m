%% Importing EBSD Data
%
%%
% An EBSD file is a table with one row per measured point: where the beam
% was, which phase the pattern was indexed as, and the three Euler angles
% that describe the crystal orientation there. Importing means reading that
% table into a variable of type @EBSD, together with the crystallography
% each phase needs and the coordinate frames the numbers refer to.
%
% Reading the table is the easy part. One command does it for every format
% MTEX knows, and which format it is follows from the file itself.

plottingConvention.default('y↓→x');

fileName = [mtexEBSDPath filesep 'EMSphinx.h5'];
ebsd = EBSD.load(fileName)

%%
% The display is worth reading once, because it is the whole import in
% summary. This file holds four scans and the first of them was taken. Its
% three phases arrived with lattice parameters, so they are full crystal
% symmetries and not just names. Two are cubic and 99% of the points are
% the gamma iron; the map is a square grid of 508 × 955 points covering
% 382 × 203 microns; and every point carries three further columns beyond
% its orientation, here the image quality |IQ|, the |Metric| the indexing
% reported and an |oldId|.
%
% From here the map plots, and the picture is the first thing that tells
% you whether the import was right.

plot(ebsd('Fe(gamma-iron)'),ebsd('Fe(gamma-iron)').orientations)

%%
% The variable is the starting point for everything else -
% <GrainReconstruction.html grain reconstruction>,
% <EBSD2ODF.html ODF estimation>,
% <Misorientations.html misorientation analysis>.
%
%% What import cannot guess
%
% Two coordinate systems are involved in every EBSD measurement: the one
% the map coordinates were written in, and the one the Euler angles were
% written in. They need not agree, vendors align them differently, and
% nothing in the file forces the two to be consistent or even records which
% choice was made.
%
% The failure mode is quiet. A map imported with the wrong alignment still
% plots, still reconstructs into grains and still yields pole figures -
% they are simply rotated or mirrored with respect to the specimen, and no
% number in the data set says so. This is the one part of importing that
% you have to supply, and <EBSDReferenceFrame.html Reference Frame>
% explains how.
%
%% The import wizard
%
% The wizard is the interactive way to do exactly that. It is started by
% <matlab:import_wizard |import_wizard|> and works on EBSD, pole figure and
% ODF data alike.
%
% <<importWizard.png>>
%
% You point it at a file, and it shows what the file contains: its data
% sets, its phases, and the map drawn with the alignment currently
% selected. Changing the alignment redraws the map, so the choice is made
% by looking at the specimen rather than by guessing a convention.
%
% The wizard can hand you the finished variable, but the better option is
% to let it write an import script. That script is reproducible, it can be
% re-run without the wizard, and it is a natural place to grow the rest of
% the analysis.
%
%% The import script
%
% A generated script looks like this - the phases, the alignment, the file,
% the frame correction, and a first plot to check the result by.

% crystal symmetry
csList = [
  notIndexed(), ...
  crystalSymmetry('m-3m', [2.8665 2.8665 2.8665], ...
    'mineral', 'Fe(alpha-iron)', 'color', 'LightSkyBlue'), ...
  crystalSymmetry('m-3m', [3.591 3.591 3.591], ...
    'mineral', 'Fe(gamma-iron)', 'color', 'DarkSeaGreen'), ...
  crystalSymmetry('6/mmm', [2.5071 2.5071 4.0686], ...
    'mineral', 'Co(alpha-cobalt)', 'color', 'Goldenrod', 'X||a', 'Y||b*', 'Z||c')
];

% how the map is aligned on screen
pC = plottingConvention('y↓→x');

% path to files
pname = mtexEBSDPath;

% which files to be imported
fname = [pname filesep 'EMSphinx.h5'];

% rotates the Euler angle reference frame onto the map reference frame
EulerCorrection = rotation.map(xvector,xvector,zvector,-zvector);

% create an EBSD variable containing the data
ebsd = EBSD.load(fname,csList,'dataSet',1, ...
  'EulerCorrection',EulerCorrection,pC)

% everything derived later that states no frame of its own follows this
plottingConvention.default(pC);

%%
% Two lines in there deserve a second look. The |EulerCorrection| is the
% wizard's answer to the previous section, written out as the rotation that
% takes one frame onto the other - the |-zvector| is what a map with $y$
% pointing down and Euler angles measured with $y$ up comes to. And |pC| is
% passed into the import as well as set as the session default, because
% data that lands in a named reference frame carries that frame's
% convention and would otherwise not follow the session.
%
% The sanity plot the wizard appends is the one from the top of this page.

plot(ebsd('Fe(gamma-iron)'),ebsd('Fe(gamma-iron)').orientations)

%% Supported data formats
%
% || <loadEBSD_ang.html .ang> || EDAX and EMSphInx text files ||
% || <loadEBSD_ctf.html .ctf> || Oxford / HKL text files ||
% || <loadEBSD_osc.html .osc> || EDAX binary files ||
% || <loadEBSD_crc.html .crc, .cpr> || Oxford binary files ||
% || <loadEBSD_h5.html .h5, .hdf5, .oh5, .h5oina, .edaxh5> || Bruker, EDAX, Oxford, ThermoFisher, EMsoft and EMSphInx binary files ||
% || <loadEBSD_generic.html .txt> || plain text with the columns in any order ||
%
% The generic loader is the fallback for a text file that no vendor
% interface recognises. If it holds Euler angles, a phase and spatial
% coordinates as columns
%
%  alpha_1 beta_1 gamma_1 phase_1 x_1 y_1
%  alpha_2 beta_2 gamma_2 phase_2 x_2 y_2
%  alpha_3 beta_3 gamma_3 phase_3 x_3 y_3
%  .       .      .       .       .   .
%  alpha_M beta_M gamma_M phase_M x_M y_M
%
% then the wizard lets you say which column is which. Orientations without
% spatial coordinates are not a map and are imported as described in
% <OrientationImport.html Importing Orientations>.
%
%% HDF5 Files With Several Data Sets
%
% HDF5 files are often project files holding more than one map - an EDAX
% project stores its maps as |Area N/OIM Map N|, an Oxford project its
% slices as |/1|, |/2|, ..., an EMSphInx file its scans as |Scan N|.
% Whenever a file contains more than one, the import lists them and states
% which one it took
%
%  ├── Data sets    : 2
%  │   ▸ [1] Area 1/OIM Map 1/EBSD
%  │     [2] Area 2/OIM Map 7/EBSD
%
% Pick another one by its number or by (part of) its name
%
%   ebsd = EBSD.load(fname,'dataSet',2)
%   ebsd = EBSD.load(fname,'dataSet','OIM Map 7')
%
% The data set that has been imported is recorded as its full HDF5 path in
% |ebsd.opt.dataSet|, the short names of all of them in
% |ebsd.opt.dataSets|. In order to see what a file contains without
% importing any data use
%
%   ebsd = EBSD.load(fname,'headerOnly')
%
% The import wizard lists everything a file offers below its file browser -
% selecting a row imports it.
%
%% Raw and Post Processed Data
%
% An Oxford |h5oina| file may store the map twice - as recorded by the
% detector under |EBSD| and as cleaned up by the vendor software under
% |Data Processing|. Both are simply data sets of that file, so they are
% listed and picked exactly like the maps above, the cleaned up one first
%
%   ebsd = EBSD.load(fname)                        % post processed
%   ebsd = EBSD.load(fname,'dataSet','EBSD')       % as recorded
%
% The recorded version comes with the full set of per pixel properties -
% band contrast, band slope, pattern quality, the pattern centre, ... -
% while the cleaned up one keeps only a few of them, but has its bad pixels
% cleaned up. Both refer to the same reference frame, so orientations may be
% compared between them directly.
%
% A file that was never processed holds the recorded version alone and
% simply lists one data set per map.
%
%% Writing your own interface
%
% A format that none of the above reads needs a function of its own. Write
% it as |loadEBSD_xxx.m|, returning an @EBSD variable, and copy it into the
% folder |mtex/interfaces| - the loaders are found by that name, so nothing
% else has to be registered, and the import wizard picks it up as well. The
% existing files in that folder are the examples to work from.
%
