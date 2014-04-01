%% Simulating EBSD data
% How to simulate an arbitrary number of individual orientations data from
% any ODF. 
%
%% Open in Editor
%
%% Contents
%
%% 
% MTEX allows one to simulate an arbitary number of EBSD data from any ODF.
% This is quite helpful if you want to analyse the EBSD to ODF estimation
% routine.
%
%% 
% *Define a Model ODF*
%
% Let us first define a simple fibre symmetric ODF.

cs = symmetry('32');
fibre_odf = 0.5*uniformODF(cs) + 0.5*fibreODF(Miller(0,0,0,1),zvector,cs);

%%
%
plotODF(fibre_odf,'sections',6,'silent')


%% Simulate EBSD Data
%
% This ODF we use now to simulate 10000 individual orientations.

ebsd = calcEBSD(fibre_odf,10000)

%% ODF Estimation from EBSD Data
%
% From the 10000 individual orientations we can now estimate an ODF. First
% we determine the optimal kernel function

psi = calcKernel(ebsd)

%%
% and then we use this kernel function for kernel density estimation

odf = calcODF(ebsd,'kernel',psi)

%%
% which can be plotted,

plotODF(odf,'sections',6,'silent')


%%
% and compared to the original model ODF.

calcError(odf,fibre_odf,'resolution',5*degree)


%% Exploration of the relationship between estimation error and number of single orientations
%
% For a more systematic analysis of the estimation error we simulate 10,
% 100, ..., 1000000 single orientations of the model ODF and 
% calculate the approximation error for the ODFs estimated from these data.

e = [];
for i = 1:6

  ebsd = calcEBSD(fibre_odf,10^i,'silent');
  
  psi1 = calcKernel(ebsd,'SamplingSize',10000,'silent');
  odf = calcODF(ebsd,'kernel',psi1,'silent');
  e(i,1) = calcError(odf,fibre_odf,'resolution',2.5*degree);
  
  psi2 = calcKernel(ebsd,'method','RuleOfThumb','silent');
  odf = calcODF(ebsd,'kernel',psi2,'silent');
  e(i,2) = calcError(odf,fibre_odf,'resolution',2.5*degree);  

  disp(['Rule of thumb: ' int2str(psi2.halfwidth/degree) mtexdegchar ...
    'Kullback Leibler cross validation: ' int2str(psi1.halfwidth/degree) mtexdegchar]);
  
end


%% 
% Plot the error in dependency of the number of single orientations.

close all;
semilogx(10.^(1:length(e)),e)
legend('Default','RuleOfThumb')
xlabel('Number of orientations')
ylabel('Estimation Error')
title('Error between original fibre ODF model and simulated ebsd','FontWeight','bold')
