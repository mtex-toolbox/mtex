%% Export Pole Figure Data
%
% Pole figure data are exported by the command
% <PoleFigure.export.html |export|>. It writes plain ASCII files that can
% be read back by MTEX and by most other texture software, and it is the
% counterpart of <PoleFigureImport.html importing pole figure data>.
%
%% Exporting measured pole figures
%
% Let us consider the Dubna quartz data set, which consists of seven pole
% figures

plottingConvention.default('y↑→x');
mtexdata dubna silent

pf

%%
% Each of these pole figures is written into its own file, because in
% general they are measured on different specimen grids and hence do not
% share a common list of directions. The file name is composed from the
% name passed to |export| and the Miller indices of the pole figure.

% we write into the temporary folder to not pollute the MTEX folder
fname = fullfile(tempdir,'dubna');

export(pf,fname,'degree')

%%
% and indeed we get one file per pole figure

d = dir([fname,'_*.txt']);
disp({d.name}')

%%
% Every file is a table with three columns - the polar angle |theta| of the
% specimen direction, its azimuth angle |rho|, and the measured diffraction
% intensity. Without the option |'degree'| the two angles are written in
% radians.

%% Reading the data back
%
% Since the format is exactly the one understood by
% <loadPoleFigure_generic.html |loadPoleFigure_generic|>, the files can be
% imported again by <PoleFigure.load.html |PoleFigure.load|>. We only have
% to say which crystal direction belongs to which file and which crystal
% symmetry to use, as the ASCII files carry no such information.

% reconstruct the file names from the Miller indices
fnames = cellfun(@(h) [fname,'_',char(h),'.txt'], pf.allH,'UniformOutput',false);

pf2 = PoleFigure.load(fnames,pf.allH,pf.CS,pf.SS,...
  'ColumnNames',{'polar angle','azimuth angle','intensity'},'degree')

%%
% The intensities survive the round trip up to the precision of the ASCII
% representation

max(abs(pf.intensities(:) - pf2.intensities(:)))

%%
% What is lost is the grid structure - the specimen directions come back as
% a plain list of |72 x 19 = 1368| points rather than as a regular
% $\theta$/$\rho$ grid. For all computations in MTEX this makes no
% difference.

%%

plot(pf2)

%% Exporting recalculated pole figures
%
% The same command applies to pole figures that were not measured but
% computed from an ODF by <SO3Fun.calcPoleFigure.html |calcPoleFigure|>.
% This is the usual way to hand MTEX results over to other programs.

odf = calcODF(pf,'silent');

pfSim = calcPoleFigure(odf,pf.allH,pf.allR,'superposition',pf.c)

%%
% Note that the superposition weights have to be passed on explicitly here.
% The third Dubna pole figure superposes $(10\bar11)$ and $(01\bar11)$ with
% the weights |pf.c{3}|, and without them |calcPoleFigure| would not know
% how many intensities to compute per specimen direction.
%
%%

export(pfSim,fullfile(tempdir,'dubnaRecalculated'),'degree')

%%
% Note that an ODF itself is better exported as an ODF, see
% <ODFExport.html Exporting ODFs>, since a set of pole figures does not
% determine it uniquely.

% clean up
delete([fname,'_*.txt'])
delete(fullfile(tempdir,'dubnaRecalculated_*.txt'))
