%% Import Pole Figure Data
%
%%
% A pole-figure file brings three pieces of information into one object.
% They are the measured specimen directions, the intensity at each direction
% and the lattice plane whose diffraction peak was measured.
% Importing is therefore more than reading a numeric table. The crystal
% symmetry, Miller indices and angular units have to be stated correctly.
% So does the specimen frame, before an ODF can be reconstructed.
%
% MTEX stores the result in a <PoleFigure.PoleFigure.html |PoleFigure|>
% object. Its entries are one or more measured pole figures, not pixels or
% individual orientations. The imported values are diffraction intensities.
% They are not yet normalized pole densities in multiples of a random
% distribution (mrd).
%
% This page assumes the pole-figure idea from
% <PoleFigureAnalysis.html Pole Figures>. Miller-index notation is introduced
% in <CrystalDirections.html Miller Indices>. Review it if unfamiliar.

%% Start with the import wizard
%
% For an unfamiliar format, start the graphical wizard by entering
%
%   import_wizard
%
% and select *Pole Figure Data*. The preview makes it possible to identify
% columns, angular units and the specimen axes before importing. The wizard
% can put the result in the workspace. Its more valuable output is an import
% script. Save that script with the analysis so the choices can be checked
% and the import repeated.
%
% The wizard asks for the <CrystalSymmetries.html crystal symmetry>, the
% Miller index of every measured reflection, and the specimen convention.
% These are scientific inputs, not display preferences. A plotting convention
% changes only where a direction is drawn. Correcting a wrong specimen frame
% changes what the data mean. The same distinction is explained in
% <EBSDReferenceFrame.html Reference Frames> for EBSD.

%% A reproducible import script
%
% The following is the essential script for the bundled Dubna quartz data.
% Declare the plotting convention before loading so the specimen directions
% enter the intended frame.

plottingConvention.default('y↑→x');

cs = crystalSymmetry('32',[1.4,1.4,1.5]);

%%
% The |cs| definition pairs trigonal symmetry with a crystal frame. That
% frame holds the relative lattice parameters and interprets Miller indices.
% Both must describe the measured phase. The default frame is X||a*, Z||c.

fnames = {...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(10-10)_amp.cnv'),...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(10-11)(01-11)_amp.cnv')};

%%
% The two cells below correspond one for one to the two filenames. The first
% file measures one reflection, $(10\bar{1}0)$. The peak in the second file
% contains two reflections. The instrument could not resolve them, so its
% cell contains two Miller indices.

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
% directions. The double Miller label on the second line is deliberate.
% It records the superposed peak rather than pretending it was one reflection.
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
% azimuth columns or degrees read as radians. A flipped specimen axis and
% missing values are also visible. So are implausible intensity ranges,
% before any of them is mistaken for an ODF problem.

plot(pf)
mtexColorbar

%%
% Both panels use the same $72 \times 19$ direction grid, but their strong
% spots occupy different regions. The title of the second panel contains two
% Miller indices because it is the unresolved peak. Notice also that its raw
% intensity scale is much larger than the first. Raw scales must not be
% compared as mrd before correction and normalization.

%% Superposed reflections are part of the measurement model
%
% The coefficients in |pf.c| are not optional cosmetic weights. For the
% second file the forward model used during reconstruction is the sum
%
% $$I(r) = 0.52\,P_{(01\bar{1}1)}(r)
%          + 1.23\,P_{(10\bar{1}1)}(r).$$
%
% Replacing that pair by one Miller index asks the inversion to explain a
% measured sum as a single pole figure. This generally biases the recovered
% ODF. If peaks overlap, record every contributing reflection. Use relative
% coefficients appropriate to the radiation and measured phase.

%% Generic text files
%
% When no dedicated reader matches, MTEX falls back to the
% <loadPoleFigure_generic.html generic ASCII reader>. A common file is one
% row per measurement,
%
%   polar_angle  azimuth_angle  intensity
%
% with any number of header or unused columns. State the column meanings and
% positions explicitly when they cannot be inferred safely. State the
% angular unit as well. For example:
%
%   pf = PoleFigure.load(fname,Miller(1,1,1,cs),cs,...
%     'interface','generic','ColumnNames',...
%     {'polar angle','azimuth angle','intensity'},...
%     'Columns',[1 2 3],'degree','Header',21);
%
% Supplying the Miller index is safer than relying on a filename. A name with
% an unrelated number can otherwise be mistaken for a reflection. If
% auto-detection chooses the wrong reader, select one with |'interface'|.
% For example, use |'interface','dubna'| for this format.

%% Supported formats and custom readers
%
% MTEX ships readers for common text and vendor formats. Interface names
% include |dubna|, |popla|, |labotex|, |beartex| and |siemens|. Others include
% |philips|, |rigaku|, |nja|, |juelich|, |uxd| and |xrdml|. Together they
% cover Dubna, PopLA, LaboTEX, BearTex, Siemens and Philips data. Rigaku,
% Seifert, Juelich, Bruker and PANalytical data are covered too.
%
% <PoleFigure.load.html |PoleFigure.load|> tries the installed
% |loadPoleFigure_*| readers and then the generic reader. Its reference page
% is version-specific. So are the reader files in the repository's
% |interfaces| directory.
%
% A format-specific reader is an ordinary function named
% |loadPoleFigure_name| that returns a |PoleFigure| object. Put it on the
% MATLAB path and call
%
%   pf = PoleFigure.load(fname,...,'interface','name');
%
% during development. Install it in MTEX's |interfaces| directory only when
% it should participate in automatic format detection. The
% <loadPoleFigure_dubna.html |loadPoleFigure_dubna|> reader is a compact
% format-specific template. The
% <loadPoleFigure_generic.html |loadPoleFigure_generic|> reader is the
% corresponding generic template.

%% Before reconstructing an ODF
%
% Confirm the phase, lattice parameters and reflection assigned to every
% file. Confirm all superposition coefficients, the angular unit, specimen
% axes, intensity range and angular coverage. Apply only justified background,
% defocusing and normalization corrections. They are explained in
% <PoleFigureCorrection.html Modify Pole Figures>. Continue afterwards to
% <PoleFigure2ODF.html ODF Reconstruction>.
%

%% Further reading
%
% * ASTM International,
% <https://doi.org/10.1520/E0081-96R24 ASTM E81-96(2024): Standard Test
% Method for Preparing Quantitative Pole Figures>. It distinguishes complete,
% partial and calculated X-ray pole figures and describes their preparation.
% * D. Chateigner, L. Lutterotti and M. Morales,
% <https://doi.org/10.1107/97809553602060000968 Quantitative texture analysis
% and combined analysis>, _International Tables for Crystallography_, Volume
% H, chapter 5.3, 2019. It connects measured intensity, experimental
% corrections, normalized pole density and overlapping reflections.
% * H.-J. Bunge,
% <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis in Materials
% Science: Mathematical Methods>, Butterworths, English ed., 1982. It gives
% the classical treatment of pole figures and ODF reconstruction.
%
