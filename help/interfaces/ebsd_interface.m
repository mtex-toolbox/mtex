%% The Generic EBSD Data Interface
%
% The generic interface allows to import EBSD data that are stored in a 
% ASCII file in the following way
%
%  alpha_1 beta_1 gamma_1 phase_1
%  alpha_2 beta_2 gamma_2 phase_2
%  alpha_3 beta_3 gamma_3 phase_3
%  .      .       .       .
%  .      .       .       .
%  .      .       .       .
%  alpha_M beta_M gamma_M phase_m
%
% The actual position and order of the columns in the file can be specified
% by the option |LAYOUT|. Furthermore, the files can be contain any number
% of header lines to be ignored using the option |HEADER|. By using the |phase| 
% option a specific phase can be specified to be imported
% 
% The following example was provided by Dr. Lischwski from Aachen.

%% specify crystal and specimen symmetry

cs = symmetry('cubic');
ss = symmetry('triclinic');

%% load EBSD data

ebsd = loadEBSD([mtexDataPath,'/aachen_ebsd/85_829grad_07_09_06.txt'],cs,ss,... 
                'interface','generic','header',1,'layout',[5,6,7,2],'phase',1)

%% plot pole figures

plotpdf(ebsd,[Miller(1,0,0,cs),Miller(1,1,0,cs)],'points',500,'reduced')

%% kernel density estimation

odf = calcODF(ebsd,'halfwidth',5*degree)

%% plot pole figures

h = [Miller(1,0,0),Miller(1,1,0),Miller(1,1,1)];
plotpdf(odf,h,'reduced')

%% plot ODF

close;figure('position',[46   171   752   486]);
plotodf(odf,'sections',9,'FontSize',10,'silent')
