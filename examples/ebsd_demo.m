%% MTEX - Analysis of EBSD Data
%
% Analysis of single orientation measurement.
%
%
%

%% Specify Crystal and Specimen Symmetry

% specify crystal and specimen symmetry
CS = {...
  symmetry('m-3m'),... % crystal symmetry phase 1
  symmetry('m-3m')};   % crystal symmetry phase 2
SS = symmetry('-1');   % specimen symmetry

%% import ebsd data

% file name
fname = [mtexDataPath '/aachen_ebsd/85_829grad_07_09_06.txt'];

ebsd = loadEBSD(fname,CS,SS,'interface','generic',...
  'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3' 'Mad' 'BC'},...
  'Columns', [2 3 4 5 6 7 8 9],...
  'ignorePhase', 0, 'Bunge');



%% Plot Spatial Data

plot(ebsd)

%% Plot Pole Figures as Scatter Plots

h = [Miller(1,0,0),Miller(1,1,0),Miller(1,1,1)];
close; figure('position',[100,100,600,300])
plotpdf(ebsd,h,'points',500,'antipodal')

%% Kernel Density Estimation
%
% The crucial point in kernel density estimation in the choice of the
% halfwidth of the kernel function used for estimation. If the halfwidth of
% is chosen to small the single orientations are visible rather
% then the ODF (compare plot of ODF1). If the halfwidth is chosen to wide
% the estimated ODF becomes very smooth (ODF2).
%
odf1 = calcODF(ebsd)
odf2 = calcODF(ebsd,'halfwidth',5*degree)

%% plot pole figures

close all;figure('position',[160   389   632   216])
plotpdf(odf1,h,'antipodal')
figure('position',[160   389   632   216])
plotpdf(odf2,h,'antipodal')

%% plot ODF

close;figure('position',[46   300   702   300]);
plotodf(odf2,'sections',9,'resolution',2*degree,...
  'FontSize',10,'silent')

%% Estimation of Fourier Coefficients
%
% Once, a ODF has been estimated from EBSD data it is straight forward to
% calculate Fourier coefficients. E.g. by
F2 = Fourier(odf2,'order',4);

%%
% However this is a biased estimator of the Fourier coefficents which
% underestimates the true Fourier coefficients by a factor that
% correspondes to the decay rate of the Fourier coeffients of the kernel
% used for ODF estimation. One obtains a *unbiased* estimator of the
% Fourier coefficients if they are calculated from the ODF estimated with
% the help fo the Direchlet kernel. I.e.

dirichlet = kernel('dirichlet',32);
odf3 = calcODF(ebsd,'kernel',dirichlet);
F3 = Fourier(odf3,'order',4);

%%
% Let us compare the Fourier coefficients obtained by both methods.
%

plotFourier(odf2,'bandwidth',32)
hold all
plotFourier(odf3,'bandwidth',32)
hold off

%% A Sythetic Example
%
% Simulate EBSD data from a given standard ODF
CS = symmetry('trigonal');
fibre_odf = 0.5*uniformODF(CS,SS) + 0.5*fibreODF(Miller(0,0,0,1),zvector,CS,SS);
plotodf(fibre_odf,'sections',6,'silent')
ebsd = simulateEBSD(fibre_odf,10000)

%%
% Estimate an ODF from the simulated EBSD data

odf = calcODF(ebsd)

%%
% plot the estimated ODF

plotodf(odf,'sections',6,'silent')

%%
% calculate estimation error
calcerror(odf,fibre_odf,'resolution',5*degree)

%%
% For a more exhausive example see the
% <EBSDSimulation_demo.html EBSD Simulation demo>!
%

%%% Exercises
%
% 5)
%
% a) Load the EBSD data: |data/ebsd\_txt/85\_829grad\_07\_09\_06.txt|!

import_wizard('type','ebsd')

%%
% b) Estimate an ODF from the above EBSD data.

odf = calcODF(ebsd)


%%
% c) Visualize the ODF and some of its pole figures!

plot(odf,'sections',6,'silent')

%%
% d) Explore the influence of the halfwidth to the kernel density estimation by looking at the pole figures!


