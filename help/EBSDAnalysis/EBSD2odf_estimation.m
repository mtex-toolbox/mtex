%% ODF Estimation from EBSD data
%
% This page describes how to use MTEX to estimate an ODF from single
% orientation measurements.
%  
%
%% Syntax
%
% Starting point of any ODF estimation from EBSD data is a 
% <EBSD_index.html EBSD> object which is in general created by
%
ebsd = loadEBSD([mtexDataPath,'/aachen_ebsd/85_829grad_07_09_06.txt'],...
  symmetry('m-3m'),symmetry('-1'),...
  'layout', [5 6 7 2], 'xy', [3 4],'Bunge',  'phase', 1);
plot(ebsd)

%%
% See [[interfacesEBSD_index.html,EBSD interfaces]] for more infomations how to import
% EBSD data and to create a EBSD object. ODF estimation from
% a EBSD object is done by the function 
% <EBSD_calcODF.html calcODF>. The most simplest
% syntax is

odf = calcODF(ebsd)

%% 
% You may want to plot some pole figures of the estimated ODF:

plotpdf(odf,[Miller(1,0,0),Miller(1,1,0),Miller(1,1,1)],'reduced','silent','position',[10 10 600 200])

%% Kernel Density Estimation
%
% There is no unique ODF determined by a set EBSD data. Indeed there is a
% many different ODFs that all could serve as a good model for the measured
% EBSD data. In MTEX an ODF ist estimated using kenel density estimation
% which can be interpreted as a generalized histogram. 
%
% Let
%
% $$ \psi : SO(3) \to R $$
%
% be a radially symmetric, unimodal model ODF. Then the kernel density
% estimate for the EBSD data
%
% $$g_1,g_2,\ldots,g_M \in SO(3)$$
%
% is given by
%
% $$f(g) = \frac{1}{M} \sum_{i=1}^{M} \psi(g g_i^{-1})$$
%
% The choise of the model ODF $\psi$ and in particular its halfwidth has a
% great impact in the resulting ODF. In MTEX these parameters can be
% specified as options to the function <EBSD_calcODF.html calcODF>.
%
% In order to change the default halfwidth of the kernel function psi the
% option *halfwidth* has to be used, e.g.

odf = calcODF(ebsd,'halfwidth',10*degree);
plotpdf(odf,[Miller(1,0,0),Miller(1,1,0),Miller(1,1,1)],'reduced','silent')

%% Estimation of Fourier Coefficients
%
% Once, a ODF has been estimated from EBSD data it is straight forward to
% calculate Fourier coefficients. E.g. by

Fourier(odf,'order',4)

%%
% However this is a biased estimator of the Fourier coefficents which
% underestimates the true Fourier coefficients by a factor that
% correspondes to the decreasing of the Fourier coeffients of the kernel
% used for ODF estimation. Hence, one obtains a *unbiased* estimator of the
% Fourier coefficients if they are calculated from an ODF estimated with
% the help fo the Direchlet kernel. I.e.

k = kernel('dirichlet',4);
odf = calcODF(EBSD,'kernel',k);
Fourier(odf,'order',4)
