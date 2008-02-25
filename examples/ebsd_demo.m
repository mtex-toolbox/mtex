%% MTEX - Analysis of EBSD Data
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

%% plot pole figures as scatter plots
h = [Miller(1,0,0),Miller(1,1,0),Miller(1,1,1)];
close; figure('position',[100,100,600,300])
plotpdf(ebsd,h,'points',500,'reduced')

%% kernel density estimation
odf = calcODF(ebsd)

%% plot pole figures
plotpdf(odf,h,'reduced')

%% plot ODF
close;figure('position',[46   171   752   486]);
plotodf(odf,'alpha','sections',18,'resolution',2*degree,...
     'plain','gray','contourf','FontSize',10)

%% a sythetic example
%
% simulate EBSD data for the Santafee sample ODF

ebsd = simulateEBSD(santafee,10000)
plotodf(santafee,'alpha','sections',18,'resolution',5*degree,...
     'plain','gray','contourf','FontSize',10)

%% 
% estimate an ODF from the simulated EBSD data

odf = calcODF(ebsd,'halfwidth',10*degree)

%%
% plot the estimated ODF

plotodf(odf,'alpha','sections',18,'resolution',5*degree,...
     'plain','gray','contourf','FontSize',10)

%%
% calculate estimation error
calcerror(odf,santafee,'resolution',5*degree)

%% Exploration of the relationship between estimation error and number of single orientations
%
% simulate 10, 100, ..., 1000000 single orientations of the Santafee sample ODF, 
% estimate an ODF from these data and calcuate the estimation error

for i = 1:6

  ebsd = simulateEBSD(santafee,10^i);

  odf = calcODF(ebsd);

  e(i) = calcerror(odf,santafee,'resolution',2.5*degree);
  
end

%% 
% plot the error in dependency of the number of single orientations
close all;
semilogx(10.^(1:6),e)
