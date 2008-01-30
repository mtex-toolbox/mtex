%% MTEX - Analysing of EBSD data
%
% Analysis of single orientation measurement.
%
% 
% 

%% specify crystal and specimen symmetry

cs = symmetry('cubic');
ss = symmetry('tricline');

%% load EBSD data

ebsd = loadEBSD([mtexDataPath,'/aachen_ebsd/85_829grad_07_09_06.txt'],cs, ...
                ss,'header',1,'layout',[5,6,7])

%% plot pole figures
plotpdf(ebsd,xvector,'points',500,'reduced')

%% kernel density estimation
odf = calcODF(ebsd)

%% plot pole figures
h = [Miller(1,0,0),Miller(1,1,0),Miller(1,1,1)];
plotpdf(odf,h,'reduced')

%% plot ODF
close;figure('position',[46   171   752   486]);
plotodf(odf,'alpha','sections',18,'resolution',5*degree,...
     'plain','gray','contourf','FontSize',10)

%% a sythetic example

ebsd = simulateEBSD(santafee,10000)
plotodf(santafee,'alpha','sections',18,'resolution',5*degree,...
     'plain','gray','contourf','FontSize',10)

%%
odf = calcODF(ebsd,'halfwidth',10*degree)

%%
plotodf(odf,'alpha','sections',18,'resolution',5*degree,...
     'plain','gray','contourf','FontSize',10)

%%
calcerror(odf,santafee,'resolution',5*degree)
  

