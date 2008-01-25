%% MTEX - Analysing of EBSD data
%
% Analysis of single orientation measurement
%
% 
% 

%% specify crystal and specimen symmetry

cs = symmetry('cubic');
ss = symmetry('tricline');

%% load EBSD data

ebsd = loadEBSD_txt([mtexDataPath,'/aachen_ebsd/85_829grad_07_09_06.txt'],cs,ss,'header',1,'layout',[5,6,7])


%% plot pole figures
plotpdf(ebsd,xvector)

%% plot single orientations
plotodf(ebsd)

%% kernel density estimation
odf = calcODF(ebsd)

%% plot pole figures
h = [Miller(1,0,0),Miller(1,1,0),Miller(1,1,1)];
plotpdf(odf,h)

%% a sythetic example

for i = 1:5

  ebsd = simulateEBSD(santafee,10^i)

  %%
  odf = calcODF(ebsd)

  %%
  e(i) = calcerror(odf,santafee,SO3Grid(2.5*degree,symmetry('cubic'),symmetry()));
end

plot(e)
  

