%% ODF Estimation from EBSD data
%
%% Open in Editor
%
%% Abstract
% This page describes how to use MTEX to estimate an ODF from single
% orientation measurements.
%  
%% Contents
%
%%
% Starting point of any ODF estimation from EBSD data is a 
% <EBSD_index.html EBSD> object, which here is imported by a
% <loadaachen.html script file>

loadaachen;

%% ODF Estimation
%
% The function <EBSD_calcODF.html calcODF> implements ODF estimation from
% EBSD data in MTEX. The underlaying statistical method is called as kernel
% density estimation, which can be interpreted as a generalized histogram.
% To be more precise, let $\psi : SO(3) \to R$ be a radially symmetric,
% unimodal model ODF. Then the kernel density estimator for the individual
% orientation data $o_1,o_2,\ldots,o_M$ is defined as
%
% $$f(o) = \frac{1}{M} \sum_{i=1}^{M} \psi(o o_i^{-1})$$
%
% The choise of the model ODF $\psi$ and in particular its halfwidth has a
% great impact in the resulting ODF. MTEX offers an rule of thumb algorithm
% to automatically detect a suitable halfwidth.
%

odf = calcODF(ebsd,'phase',1)

%%
% However, it is much more recommended to specify the kernel halfwidth by
% hand according to prior knowledge on the ODF.

odf = calcODF(ebsd,'halfwidth',10*degree,'phase',1);

%%
% Once an ODF is estimated all the functionallity MTEX offers for 
% <ODFCalculations.html ODF analysis> and <ODFPlot.html ODF visualisation> is available. 

plotpdf(odf,[Miller(1,0,0),Miller(1,1,0),Miller(1,1,1)],'antipodal','silent','position',[10 10 600 200])


%% Halfwidth selection
%
% As mentioned above a propper halfwidth selection is crucial for ODF
% estimation. The following simple numerical experiment illustrates the
% dependency between the kernel halfwidth and the estimation error.
%
% Lets start with a model ODF and simulate some EBSD data.

ebsd = simulateEBSD(SantaFe,10000)

%%
% Next we define a list of kernel halfwidth ,

hw = [1*degree, 2*degree, 4*degree, 8*degree, 16*degree, 32*degree];

%%
% estimate for each halfwidth an ODF and compare it to the original ODF.

for i = 1:length(hw)
  
  odf = calcODF(ebsd,'halfwidth',hw(i),'silent');
  e(i) = calcerror(SantaFe, odf);
  
end

%%
% After visualizing the estimation error with observe that the estimation
% error is large if the halfwidth is chosen to small or to large. In this
% specific example the optimal halfwidth seems to be about 4 degree

plot(hw/degree,e)
xlabel('halfwidth in degree')
ylabel('esimation error')
