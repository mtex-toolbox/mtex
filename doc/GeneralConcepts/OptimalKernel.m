%% Optimal Kernel Selection
%
%%
% In the section <DensityEstimation.html density estimation> we have seen
% that the correct choice of the kernel halfwidth is essential for good
% match between the true density function and the reconstructed density
% function. If the halfwidth is set to small the reconstructed density
% function is ussualy oszilating and the indiviudual sampling points are
% visible as sharp peaks. If the halfwidth is to large the resulting
% density function is usually too smooth and does not reproduce the
% features of the original density function. 
%
% Finding an optimal kernel halfwidth is a hard problem as the optimal
% kernel halfwidth depends not only on the number sampling points but also
% on the smoothness of the true but unknown density function. A very
% conserative choice of the kernel halfwidth that takes into account only
% the number of sampling points is implemented in MTEX as |'magicRule'|. In
% the |'RuleOfThumb'| considers additionaly to the number of sampling
% points also the variance of the sampling point as an estimate of the
% smoothness of the true density function. The most advanced (and default)
% method for estimating the optimal kernel halfwidth is
% <orientation.KLCV.html Kullback Leibler cross validation>. The idea of
% this method is to test different kernel halfwidth on a subset of the
% random sampling and to select the halfwidth which best reproduces the
% ommited points of the random sampling.
%
% In order to demonstrate this functionality lets start with the following
% orientation density function

cs = crystalSymmetry('32');

odf = 0.25*uniformODF(cs) + 0.25*unimodalODF(orientation.brass(cs)) + ...
  0.5*fibreODF(fibre.alpha(cs),'halfwidth',10*degree);

plot(odf,'sections',6,'silent','sigma')
mtexColorbar

%%
% and compute $10000$ random orientations using the command
% |<orientation.discreteSample.html discreteSample>|

ori = odf.discreteSample(10000)

%%
% Next we estimate the optimal <ODFShapes.html kernel function> using the
% command |<orientation.calcKernel.html calcKernel>|. 

psi  = calcKernel(ori)

%%
% This kernel can now be used for recovering the original ODF by
% <DensityEsimation.html density estimation>

odf_rec = calcDensity(ori,'kernel',psi)

% plot the reconstructed ODF
plot(odf_rec,'sections',6,'silent','sigma')

%% Exploration of the relationship between estimation error and number of single orientations
%
% In this section we want to compare the different methods for estimating
% the optimal kernel halfwidth. To this end we simulate 10, 100, ...,
% 1000000 single orientations of the model ODF |odf|, compute optimal
% kernels according to the |'magicRule'|, the |'RuleOfThumb'| and
% <orientation.KLCV.html Kullback Leibler cross validation> and then
% computed the fit between the reconstructed |odf_rec| to the original
% |odf|.

e = [];
for i = 1:6

  ori = calcOrientations(odf,10^i,'silent');
  
  psi1 = calcKernel(ori,'SamplingSize',10000,'silent');
  odf_rec = calcDensity(ori,'kernel',psi1,'silent');
  e(i,1) = calcError(odf_rec,odf,'resolution',2.5*degree);
  
  psi2 = calcKernel(ori,'method','RuleOfThumb','silent');
  odf_rec = calcDensity(ori,'kernel',psi2,'silent');
  e(i,2) = calcError(odf_rec,odf,'resolution',2.5*degree);  
  
  psi3 = calcKernel(ori,'method','magicRule','silent');
  odf_rec = calcDensity(ori,'kernel',psi3,'silent');
  e(i,3) = calcError(odf_rec,odf,'resolution',2.5*degree);  

  disp(['RuleOfThumb: ' int2str(psi2.halfwidth/degree) mtexdegchar ...
    ' KLCV: ' int2str(psi1.halfwidth/degree) mtexdegchar ...
    ' magicRule: ' int2str(psi3.halfwidth/degree) mtexdegchar ...
    ]);
  
end

%% 
% Plot the error in dependency of the number of single orientations.

close all;
loglog(10.^(1:length(e)),e,'LineWidth',2)
legend('Default','RuleOfThumb','magicRule')
xlabel('Number of orientations')
ylabel('Estimation Error')
title('Error between original fibre ODF model and simulated ebsd','FontWeight','bold')

