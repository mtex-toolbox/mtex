%% ODF Estimation from EBSD data
% How to estimate an ODF from single orientation measurements.
%
%% Open in Editor
%  
%% Contents
%
%
% Starting point of any ODF estimation from EBSD data is a 
% <EBSD_index.html EBSD> object, which here is imported by a
% [[matlab:edit mtexdata, script file]]

mtexdata aachen

%% ODF Estimation
%
% These data consist of two phases, Iron and Magnesium. The ODF of the Iron
% phase is computed by the command

odf = calcODF(ebsd('Fe'))

%%
% The function <EBSD.calcODF.html calcODF> implements ODF estimation from
% EBSD data in MTEX. The underlaying statistical method is called as kernel
% density estimation, which can be seen as a generalized histogram.
% To be more precise, let $\psi : SO(3) \to R$ be a radially symmetric,
% unimodal model ODF. Then the kernel density estimator for the individual
% orientation data $o_1,o_2,\ldots,o_M$ is defined as
%
% $$f(o) = \frac{1}{M} \sum_{i=1}^{M} \psi(o o_i^{-1})$$
%
% The choise of the model ODF $\psi$ and in particular its halfwidth has a
% great impact in the resulting ODF. If no halfwidth was speciefied the
% default halfwidth of 10 degree is selected.


%% Automatic halfwidth selection
%
% MTEX includes an automatic halfwidth selection algorithm which is called
% by the command <EBSD.calcKernel.html calcKernel>. A neccesary condition
% that this algorithm works is that the ebsd data are spatialy independend,
% as it is the case for very rough EBSD meassurements, i.e. only one
% measurement per grain. 

% try to compute an optimal kernel
psi = calcKernel(ebsd('Fe'))

%%
% The above example the EBSD measurements are spatial dependend and the
% resulting halfwidth is to small. To avoid this problem we have to perfrom
% grain reconstruction first and then to estimate the halfwidth from the
% grains.

% grains reconstruction
[grains ebsd] = calcGrains(ebsd);

% correct for to small grains
grains = grains(grainSize(grains)>5);

% compute optimal halfwidth from grains
psi = calcKernel(grains('Fe'))

% compute the ODF with the kernel psi
odf = calcODF(ebsd('Fe'),'kernel',psi)


%%
% Once an ODF is estimated all the functionallity MTEX offers for 
% <ODFCalculations.html ODF analysis> and <ODFPlot.html ODF visualisation> is available. 

plotpdf(odf,[Miller(1,0,0),Miller(1,1,0),Miller(1,1,1)],'antipodal','silent','position',[10 10 600 200])


%% Effect of halfwidth selection
%
% As mentioned above a propper halfwidth selection is crucial for ODF
% estimation. The following simple numerical experiment illustrates the
% dependency between the kernel halfwidth and the estimation error.
%
% Lets start with a model ODF and simulate some EBSD data.

ebsd = calcEBSD(SantaFe,10000)

%%
% Next we define a list of kernel halfwidth ,

hw = [1*degree, 2*degree, 4*degree, 8*degree, 16*degree, 32*degree];

%%
% estimate for each halfwidth an ODF and compare it to the original ODF.

for i = 1:length(hw)
  
  odf = calcODF(ebsd,'halfwidth',hw(i),'silent');
  e(i) = calcError(SantaFe, odf);
  
end

%%
% After visualizing the estimation error with observe that the estimation
% error is large if the halfwidth is chosen to small or to large. In this
% specific example the optimal halfwidth seems to be about 4 degree

plot(hw/degree,e)
xlabel('halfwidth in degree')
ylabel('esimation error')
