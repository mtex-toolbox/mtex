%% Import from VPSC
%
% A VPSC simulation can record how a polycrystal's orientations and slip
% activity change with strain. This page imports both histories and shows
% how to compare their deformation steps in MTEX.
%
% <https://public.lanl.gov/lebenso/ VPSC> is a crystal-plasticity code
% originally written by Ricardo Lebensohn and Carlos Tomé at Los Alamos
% National Laboratory. The original code can be requested from
% lebenso@lanl.gov.

%% Import the texture history
%
% A VPSC run usually writes |TEX_PH1.OUT| for phase 1. The file contains
% one block of weighted orientations for each recorded strain level.
% It does not contain crystal symmetry, so supply that information first.

cs = crystalSymmetry('222',[4.762 10.225 5.994],...
  'mineral','olivine');

%%
% <SO3Fun.load.html |SO3Fun.load|> reads each block and estimates an
% <ODFTheory.html orientation distribution function> (ODF) from its
% weighted orientations. The |'halfwidth'| is the smoothing width of that
% estimate; it is not a parameter read from VPSC.

path2file = fullfile(mtexDataPath,'VPSC');
odf = SO3Fun.load(fullfile(path2file,'TEX_PH1.OUT'),...
  'halfwidth',10*degree,'CS',cs);

%%
% A file with several blocks returns a cell array with one ODF per block.
% This sample contains nine ODFs. Its first eight steps run from strain
% 0.25 to 2.00, and the final block is another result at strain 2.00.

strain = cellfun(@(f) f.opt.strain,odf)

%% Inspect one deformation step
%
% Use braces to select one ODF. A sigma-section plot exposes the
% three-dimensional orientation density as a sequence of two-dimensional
% sections.

plotSection(odf{2},'sigma','figSize','normal')

%%
% The section maxima identify the preferred orientations at strain 0.50.
% Their unequal intensities show that this simulated texture is already
% far from a uniform orientation distribution.
%
% VPSC header values and the original orientation table remain available
% in |opt|. The fields below contain the strain, the phase-ellipsoid axes
% and angles, the 1000 imported orientations, and the three extra numeric
% columns from this file.

odf{1}.opt

%% File conventions and input weight files
%
% The same command reads weight files with the |.wts| extension that are
% handed *to* VPSC. It also reads files written by
% <orientation.export_VPSC.html |export_VPSC|>. Those files carry neither
% strain nor a phase ellipsoid, so the corresponding |odf.opt| entries are
% |NaN|.
%
% The fourth header line names the Euler-angle convention. VPSC uses |B|
% for Bunge, |K| for Kocks, and |R| for Roe, and MTEX follows the convention
% announced by each file.

%% Compare pole figures during deformation
%
% A pole figure plots where selected crystal directions lie in the specimen.
% Plotting the same directions at successive strain levels makes the texture
% evolution visible without comparing full ODF section plots.

h = Miller({1,0,0},{0,1,0},{0,0,1},cs,'uvw');

fig = newMtexFigure('layout',[4,3],'figSize','huge');
subSet = 1:4;

for n = subSet
  nextAxis
  plotPDF(odf{n},h,'lower','contourf','doNotDraw');
  ylabel(fig.children(end-2),...
    ['\epsilon = ',xnum2str(odf{n}.opt.strain)]);
end
setColorRange('equal')
mtexColorbar

%%
% Read the rows from top to bottom as strain increases from 0.25 to 1.00.
% The shared colour range makes intensities comparable between rows; the
% changing peak positions and strengths are therefore texture evolution,
% not independent plot scaling.

%% Visualize slip-system activity
%
% VPSC also writes |ACT_PH1.OUT| alongside the orientation data. It contains
% the activity of the different slip modes during deformation. Read it as a
% MATLAB table so its |STRAIN| and |MODE1| through |MODE9| columns retain
% their names.

ACT = readtable(fullfile(path2file,'ACT_PH1.OUT'),'FileType','text')

%%
% Plot every mode against strain. |AVACS| is the second column and is not a
% slip mode, so the loop begins at the third table column.

close all
for n = 3:size(ACT,2)
  plot(ACT.STRAIN,table2array(ACT(:,n)),'lineWidth',2,...
    'DisplayName',['Slip mode ',num2str(n-2)])
  hold on
end
hold off

xlabel('Strain')
ylabel('Slip activity')
legend('show','location','NorthEastOutside')
set(gca,'YLim',[-0.005 1])
set(gcf,'MenuBar','none','units','normalized',...
  'position',[0.25 0.25 0.5 0.5])

%%
% Modes 1--3 dominate this simulation. Mode 3 rises to its maximum near
% strain 1, mode 2 steadily weakens, and mode 1 nearly catches mode 3 at the
% final step. To inspect a single mode as a smooth curve, for example mode
% 3, one can fit |csapi(ACT.STRAIN,ACT.MODE3)| and plot it with |fnplt|.

%% References
%
% * R. A. Lebensohn and C. N. Tomé,
% <https://doi.org/10.1016/0956-7151(93)90130-K A self-consistent
% anisotropic approach for the simulation of plastic deformation and
% texture development of polycrystals>, _Acta Metallurgica et Materialia_
% 41 (1993), 2611--2624. This paper introduces the VPSC formulation used to
% compute the imported deformation history.

%% Next
%
% <TextureEvolution.html Texture Evolution> rotates every orientation by the
% Taylor-model spin over small strain increments. It provides
% the next step when the texture path should be computed inside MTEX rather
% than imported from VPSC.

%#ok<*NOPTS>
