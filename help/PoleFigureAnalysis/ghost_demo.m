%% MTEX Ghost Effect Demo
%
%% Open in Editor
%
%% Abstract
% A general problem in estimating an ODF from pole figure data is the fact,
% that the odd order Fourier coefficients of the ODF are not present
% anymore in the pole figure data and therefore it is difficult to estimate
% them. Artefacts in the estimated ODF that are due to underestimated odd
% order Fourier coefficients are called *ghost effect*. It is known that
% for sharp textures the ghost effect is relatively small due to the strict
% nonnegativity condition. For weak textures, however, the ghost effect
% might be remarkable. For those cases *MTEX* provides the option 
% *ghost_ correction* which tries to determine the uniform portion of the
% unknown ODF and to transform the unknown weak ODF into a sharp ODF by
% substracting this uniform portion. This is allmost the approach Matthies
% proposed in his book (He called the uniform portion *phon*).
% 
%% Contents
%
%%
% In this example we are going to demonstarte the power of ghost correction
% at a simple, synthetic example.

%% Construct Model ODF
%
% A unimodal ODF with a high uniform portion.

cs = symmetry('mmm');
ss = symmetry('triclinic');
mod1 = orientation('Euler',0,0,0);
odf = 0.9*uniformODF(cs,ss) + ...
  0.1*unimodalODF(mod1,cs,ss,'halfwidth',10*degree)

%% Simulate pole figures
% 
r = S2Grid('equispaced','resolution',5*degree,'antipodal');
h = [Miller(1,0,0),Miller(0,1,0),Miller(0,0,1)];
pf = simulatePoleFigure(odf,h,r);

%% ODF Estimation
% without ghost correction:
rec = calcODF(pf);
%%
% with ghost correction:
rec_cor = calcODF(pf,'ghost_correction');

%% Compare RP Errors

%% 
% without ghost correction:
calcerror(pf,rec,'RP')

%% 
% with ghost correction:
calcerror(pf,rec_cor,'RP')

%% Compare Reconstruction Errors

%% 
% without ghost correction:
calcerror(rec,odf)

%% 
% with ghost correction:
calcerror(rec_cor,odf)


%% Plot the ODFs

%% 
% without ghost correction:
plotodf(rec,'sections',9,'silent')

%% 
% with ghost correction:
plotodf(rec_cor,'sections',9,'silent')

%% 
% radial plot of the true ODF
close all
plotodf(odf,'radially','center',idquaternion,'axes',yvector,'color','b')
hold on

% radial plot without ghost correction:
plotodf(rec,'radially','center',idquaternion,'axes',yvector,'color','g')

% radial plot with ghost correction:
plotodf(rec_cor,'radially','center',idquaternion,'axes',yvector,'color','r','linestyle','--')
hold off
legend({'true ODF','without ghost correction','with ghost correction'})

%% Calculate Fourier coefficients
odf = calcFourier(odf,25);
rec = calcFourier(rec,25);
rec_cor = calcFourier(rec_cor,25);

%% Calculate Reconstruction Errors from Fourier Coefficients

%% 
% without ghost correction:
calcerror(rec,odf,'Fourier','L2')

%% 
% with ghost correction:
calcerror(rec_cor,odf,'Fourier','L2')


%% Plot Fourier Coefficients   
%
% Plotting the Fourier coefficients of the recalculated ODFs show that the
% Fourier coefficients with ghost correction oszillates much more the the
% Fourier coefficients with ghost correction


% true ODF
close all;
plotFourier(odf)

% keep plotting windows and add next plots
hold all

% Without ghost correction:
plotFourier(rec)

% with ghost correction
plotFourier(rec_cor)
legend({'true ODF','without ghost correction','with ghost correction'})
% next plot command overwrites plot window
hold off
