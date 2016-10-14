%% ODF Estimation from EBSD data
% How to estimate an ODF from single orientation measurements.
%
%% Open in Editor
%  
%% Contents
%
%
% The starting point of any ODF estimation from EBSD data is the
% <EBSD_index.html EBSD> object, which here is imported by a
% [[matlab:edit mtexdata, script file]]

mtexdata forsterite

%% ODF Estimation
%
% These EBSD datasets consist of two phases, Iron, and Magnesium. The ODF of the Iron
% phase is computed by the command

odf = calcODF(ebsd('fo').orientations)

%%
% The function <EBSD.calcODF.html calcODF> implements the ODF estimation from
% EBSD data in MTEX. The underlying statistical method is called kernel
% density estimation, which can be seen as a generalized histogram.
% To be more precise, let's $\psi : SO(3) \to R$ be a radially symmetric,
% unimodal model ODF. Then the kernel density estimator for the individual
% orientation data $o_1,o_2,\ldots,o_M$ is defined as
%
% $$f(o) = \frac{1}{M} \sum_{i=1}^{M} \psi(o o_i^{-1})$$
%
% The choice of the model ODF $\psi$ and in particular its halfwidth has a
% great impact in the resulting ODF. If no halfwidth is specified the
% default halfwidth of 10 degrees is selected.


%% Automatic halfwidth selection
%
% MTEX includes an automatic halfwidth selection algorithm which is called
% by the command <EBSD.calcKernel.html calcKernel>. To work properly, this algorithm 
% needs spatially independent EBSD data as in the case of this dataset of very rough 
% EBSD measurements (only one measurement per grain). 

% try to compute an optimal kernel
psi = calcKernel(ebsd('fo').orientations)

%%
% In the above example, the EBSD measurements are spatial dependent and the
% resulting halfwidth is too small. To avoid this problem we have to perform
% grain reconstruction first and then estimate the halfwidth from the
% grains.

% grains reconstruction
grains = calcGrains(ebsd);

% correct for to small grains
grains = grains(grains.grainSize>5);

% compute optimal halfwidth from the meanorientations of grains
psi = calcKernel(grains('fo').meanOrientation)

% compute the ODF with the kernel psi
odf = calcODF(ebsd('fo').orientations,'kernel',psi)


%%
% Once an ODF is estimated all the functionality MTEX offers for 
% <ODFCalculations.html ODF analysis> and <ODFPlot.html ODF visualization> is available. 

h = [Miller(1,0,0,odf.CS),Miller(1,1,0,odf.CS),Miller(1,1,1,odf.CS)];
plotPDF(odf,h,'antipodal','silent')


%% Effect of halfwidth selection
%
% As mentioned above a proper halfwidth selection is crucial for ODF
% estimation. The following simple numerical experiment illustrates the
% dependency between the kernel halfwidth and the estimated error.
%
% Let's start with a model ODF and simulate some individual orientation data.

modelODF = fibreODF(Miller(1,1,1,crystalSymmetry('cubic')),xvector);
ori = calcOrientations(modelODF,10000)

%%
% Next we define a list of kernel halfwidth ,

hw = [1*degree, 2*degree, 4*degree, 8*degree, 16*degree, 32*degree];

%%
% estimate for each halfwidth an ODF and compare it to the original ODF.

e = zeros(size(hw));
for i = 1:length(hw)
  
  odf = calcODF(ori,'halfwidth',hw(i),'silent');
  e(i) = calcError(modelODF, odf);
  
end

%%
% After visualizing the estimation error we observe that its value is large 
% either if we choose a very small or a very large halfwidth.
% In this specific example, the optimal halfwidth seems to be about 4
% degrees.

close all
plot(hw/degree,e)
xlabel('halfwidth in degree')
ylabel('esimation error')
