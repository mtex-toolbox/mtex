%% Import Pole Figure Data
%
%%
% A pole-figure file contains three pieces of information that must meet in
% one object: the measured specimen directions, the intensity at each
% direction, and the lattice plane whose diffraction peak was measured.
% Importing is therefore more than reading a numeric table. The crystal
% symmetry, Miller indices, angular units and specimen frame have to be
% stated correctly before an ODF can be reconstructed.
%
% MTEX stores the result in a <PoleFigure.PoleFigure.html |PoleFigure|>
% object. Its entries are one or more measured pole figures, not pixels or
% individual orientations.

%% Start with the import wizard
%
% For an unfamiliar format, start the graphical wizard by entering
%
%   import_wizard
%
% and select *Pole Figure Data*. The preview makes it possible to identify
% columns, angular units and the specimen axes before importing. The wizard
% can put the result in the workspace, but its more valuable output is an
% import script: save that script with the analysis so that the choices can
% be checked and the import repeated.
%
% The wizard asks for the <CrystalSymmetries.html crystal symmetry>, the
% Miller index of every measured reflection, and the specimen convention.
% These are scientific inputs, not display preferences. In particular,
% changing the plotting convention only changes where a direction is drawn;
% correcting a wrong specimen frame changes what the data mean. See
% <EBSDReferenceFrame.html Reference Frames> for the same distinction in an
% EBSD setting.

%% A reproducible import script
%
% The following is the essential part of the script for the bundled Dubna
% quartz data. Declare the plotting convention before loading so the
% specimen directions enter the intended frame.

plottingConvention.default('y↑→x');

cs = crystalSymmetry('32',[1.4,1.4,1.5]);

fnames = {...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(10-10)_amp.cnv'),...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(10-11)(01-11)_amp.cnv')};

%%
% The two cells below correspond one for one to the two filenames. The
% first file measures one reflection, $(10\bar{1}0)$. The peak in the
% second file contains two reflections that the instrument could not
% resolve, so its cell contains two Miller indices.

h = {Miller(1,0,-1,0,cs),...
  [Miller(0,1,-1,1,cs),Miller(1,0,-1,1,cs)]};

%%
% A combined peak is a weighted sum. Its relative structure coefficients
% must be supplied in the same order as its Miller indices. The first pole
% figure has only one contribution and therefore weight 1.

c = {1,[0.52,1.23]};

%%
% <PoleFigure.load.html |PoleFigure.load|> detects the file format and
% joins the files, reflections and weights into one object.

pf = PoleFigure.load(fnames,h,cs,'superposition',c)

%% What was imported
%
% The display reports the crystal symmetry and one line per measured pole
% figure. Here both files contain a $72 \times 19$ grid of specimen
% directions. The double Miller label on the second line is deliberate: it
% records the superposed peak rather than pretending it was a single
% reflection.
%
% The four parts of the object can be inspected directly:
%
% * |pf.allH| contains the crystal plane normals;
% * |pf.allR| contains the specimen directions at which intensities were
%   measured;
% * |pf.allI| contains those intensities; and
% * |pf.c| contains the structure coefficients.
%
% The cell structure matters because different pole figures may have
% different grids and different numbers of contributing reflections.

pf.allH
pf.c

%%
% Plot the raw measurements immediately. This catches transposed polar and
% azimuth columns, degrees read as radians, a flipped specimen axis, missing
% values and implausible intensity ranges before they become an ODF problem.

plot(pf)

%% Superposed reflections are part of the measurement model
%
% The coefficients in |pf.c| are not optional cosmetic weights. For the
% second file the forward model used during reconstruction is the sum
%
% $$I(r) = 0.52\,P_{(01\bar{1}1)}(r)
%          + 1.23\,P_{(10\bar{1}1)}(r).$$
%
% Replacing that pair by one Miller index asks the inversion to explain a
% measured sum as a single pole figure and generally biases the recovered
% ODF. If peaks overlap, record every contributing reflection and use
% relative coefficients appropriate to the radiation and phase being
% measured.

%% Generic text files
%
% When no dedicated reader matches, MTEX falls back to the
% <loadPoleFigure_generic.html generic ASCII reader>. A common file is one
% row per measurement,
%
%   polar_angle  azimuth_angle  intensity
%
% with any number of header or unused columns. State the column meanings,
% their positions and the angular unit explicitly when they cannot be
% inferred safely. For example:
%
%   pf = PoleFigure.load(fname,Miller(1,1,1,cs),cs,...
%     'interface','generic','ColumnNames',...
%     {'polar angle','azimuth angle','intensity'},...
%     'Columns',[1 2 3],'degree','Header',21);
%
% Supplying the Miller index is safer than relying on a filename. A name
% containing an unrelated number can otherwise be mistaken for a
% reflection. If auto-detection chooses the wrong reader, select one
% explicitly with |'interface'|, for example |'interface','dubna'|.

%% Supported formats and custom readers
%
% MTEX ships readers for common Dubna, PopLA, LaboTEX, BearTex, Siemens,
% Philips, Bruker, PANalytical, Rigaku, Seifert, Juelich and other text and
% vendor formats. <PoleFigure.load.html |PoleFigure.load|> tries the
% installed |loadPoleFigure_*| readers and then the generic reader, so its
% reference page and the files in the repository's |interfaces| directory
% are the version-specific source of truth.
%
% A format-specific reader is an ordinary function named
% |loadPoleFigure_name| that returns a |PoleFigure| object. Put it on the
% MATLAB path and call
%
%   pf = PoleFigure.load(fname,...,'interface','name');
%
% during development. Install it in MTEX's |interfaces| directory only if
% it should participate in automatic format detection. Existing readers
% such as <loadPoleFigure_dubna.html |loadPoleFigure_dubna|> and
% <loadPoleFigure_generic.html |loadPoleFigure_generic|> are compact
% templates.

%% Before reconstructing an ODF
%
% Confirm the phase and lattice parameters, the reflection assigned to
% every file, all superposition coefficients, the angular unit, specimen
% axes, intensity range and angular coverage. Then apply justified
% background, defocusing and normalization corrections in
% <PoleFigureCorrection.html Modify Pole Figures> before continuing to
% <PoleFigure2ODF.html ODF Reconstruction>.
%
