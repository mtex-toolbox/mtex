%% Generic EBSD Data Interface
% generic interface to import EBSD data
%
%% 
% Interface to import EBSD data that are stored in a 
% column oriented way, i.e.
%
%  EULER1  EULER2 EULER3  PHASE
%  alpha_1 beta_1 gamma_1 phase_1
%  alpha_2 beta_2 gamma_2 phase_2
%  alpha_3 beta_3 gamma_3 phase_3
%  .      .       .       .
%  .      .       .       .
%  .      .       .       .
%  alpha_M beta_M gamma_M phase_m
%
% The actual position and order of the columns in the file has to be specified
% by the options |ColumnNames| and |Columns|. 
% 
% The following example was provided by Dr. Lischwski from Aachen.

%% specify crystal and specimen symmetry

cs = symmetry('cubic');
ss = symmetry('triclinic');

%% load EBSD data

ebsd = loadEBSD([mtexDataPath,'/aachen_ebsd/85_829grad_07_09_06.txt'],cs,ss,... 
                'interface','generic','phase',1,'Bunge',...
                 'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3'},...
                 'Columns', [2 3 4 5 6 7]);

%% plot pole figures

plotpdf(ebsd,[Miller(1,0,0,cs),Miller(1,1,0,cs)],'points',500,'antipodal')

%% kernel density estimation

odf = calcODF(ebsd,'halfwidth',5*degree)

%% plot pole figures

h = [Miller(1,0,0),Miller(1,1,0),Miller(1,1,1)];
plotpdf(odf,h,'antipodal')

%% plot ODF

close;figure('position',[46   171   752   486]);
plotodf(odf,'sections',9,'FontSize',10,'silent')
