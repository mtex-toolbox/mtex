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
% <EBSD_index.html EBSD> object, which here is imported by a [[loadaachen.html,script file]]

loadaachen;

%% Kernel Density Estimation from EBSD Data
%
% There is no unique ODF determined by a set EBSD data. Indeed there is a
% many different ODFs that all could serve as a good model for the measured
% EBSD data. In MTEX an ODF ist estimated using kenel density estimation
% which can be interpreted as a generalized histogram. 
%
% Let $\psi : SO(3) \to R$ be a radially symmetric, unimodal model ODF. 
% Then the kernel density estimate for the EBSD data $g_1,g_2,\ldots,g_M
% \in SO(3)$ is given by
%
% $$f(g) = \frac{1}{M} \sum_{i=1}^{M} \psi(g g_i^{-1})$$
%
% The choise of the model ODF $\psi$ and in particular its halfwidth has a
% great impact in the resulting ODF. In MTEX these parameters can be
% specified as options to the function <EBSD_calcODF.html calcODF>.
%

odf = calcODF(ebsd,'phase',1)

%%
% In order to change the default halfwidth of the kernel function $\psi$ the
% option *halfwidth* has to be used, e.g.

odf = calcODF(ebsd,'halfwidth',10*degree,'phase',1);

%%
% You may want to [[ODFPlot.html, plot]] some pole figures of the estimated ODF:

plotpdf(odf,[Miller(1,0,0),Miller(1,1,0),Miller(1,1,1)],'antipodal','silent','position',[10 10 600 200])


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
odf_b = calcODF(ebsd,'kernel',k,'phase',1);
Fourier(odf_b,'order',4)

%% Kernel Density Estimation from Grains
% EBSD data has often spatially dependend orientations, because one grain
% is measuered several times. By modelling grains

[grains ebsd] = segment2d(ebsd);

%%
% we can omit these fact. As above the command
% [[grain_calcODF.html,calcODF]] performes a kernel density estimation

odf_grains = calcODF(grains,'halfwidth',10*degree,'phase',1)

%%
% we are able to quantify what changed, by comparing the ODFs

close all;
plotDiff(odf_grains,odf,'sections',9)

%%
% however weighting after volume portion by optioning with *weight* results

odf_grains = calcODF(grains,'weight',area(grains),'halfwidth',10*degree,'phase',1)

close all;
plotDiff(odf_grains,odf,'sections',9)

%%
% Since we have for each grain individual orientation measurements we can
% estimate for every grain an ODF by overloading the corresponding EBSD
% object, the resulting ODFs are stored as a grain property

grains = calcODF(grains,ebsd,'exact');

%%
% The property can be accessed using the *get* command with

get(grains,'ODF');

%%
% However, one might calculate the [[ODF_textureindex.html,textureindex]] or
% other texture property, this can be done by a helper function
% [[grain_grainfun.html, grainfun]], which allows to apply a
% [[matlab:doc function_handle, function_handle]] on each ODF, or generally
% single grain. Since this may take a while, we restrict the grainset some
% of the largest grains

grain_selection = grains( grainsize(grains) > 600 );
tindex = grainfun(@textureindex, grain_selection, 'ODF')


