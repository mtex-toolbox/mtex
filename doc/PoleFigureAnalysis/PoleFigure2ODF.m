%% ODF Estimation from Pole Figure Data
%
%%
% This page describes how to use MTEX to estimate an ODF from pole figure
% data. Starting point of any ODF reconstruction is a
% <PoleFigure.PoleFigure.html PoleFigure> object which can be created e.g.
% by

mtexdata dubna

%%
% See <PoleFigureImport.html Import> for more infomation how to import
% pole figure data and to create a pole figure object.

% plot pole figures
plot(pf)


%% ODF Estimation
% ODF estimation from a pole figure object is done by the function 
% <PoleFigure.calcODF.html calcODF>. The most simplest
% syntax is

odf = calcODF(pf)

%% 
% There are a lot of options to the function <PoleFigure.calcODF.html
% calcODF>. You can specify the discretization, the functional to minimize,
% the number of iteration or regularization to be applied. Furthermore, you
% can specify ghost correction or the zero range method to be applied.
% These options are discussed below.
%
%% 
% You may want to verify that the pole figures are reproduced. Here is a
% plot of the computed pole figures.

plotPDF(odf,pf.allH,'antipodal','silent','superposition',pf.c)


%% Error analysis
%
% For a more quantitative description of the reconstruction quality, one can
% use the function <PoleFigure.calcError.html calcError> to compute the
% fit between the reconstructed ODF and the measured pole figure
% intensities. The following measured are available:
%
% * RP - error
% * L1 - error
% * L2 - error

calcError(pf,odf,'RP',1)

%%
% In order to recognize bad pole figure intensities, it is often useful to
% plot difference pole figures between the normalized measured intensities
% and the recalculated ODF. This can be done by the command
% <PoleFigure.plotDiff.html PlotDiff>.

plotDiff(pf,odf)

%%
% Assuming you have driven two ODFs from different pole figure measurements
% or by ODF modeling. Then one can ask for the difference between both.
% This difference is computed by the command <ODF.calcError.html
% calcError>.

% define a unimodal ODF with the same modal orientation
odf_model = unimodalODF(calcModes(odf),'halfwidth',15*degree)

% plot the pole figures
plotPDF(odf_model,pf.allH,'antipodal','superposition',pf.c)

% compute the difference
calcError(odf_model,odf)

%% Discretization
%
% In MTEX the ODF is approximated by a superposition of up to 10,000,000
% unimodal components. By exact number and position of these  components,
% as well as its shape can be specified by the user. By default, the positions
% are chosen equispaced in the orientation space with 1.5 times the
% resolution of the pole figures and the components are de la Vallee
% Poussin shaped with the same halfwidth as the resolution of the positions.
%
% Next an example how to change the default resolution:

odf = calcODF(pf,'resolution',15*degree)
plotPDF(odf,pf.allH,'antipodal','silent','superposition',pf.c)

%%
% Beside the resolution you can use the following options to change the
% default discretization:
%
% * |'kernel'| to specify a specific kernel function
% * |'halfwidth'| to take the default kernel with a specific halfwidth
%
%% Zero Range Method
%
% If the flag |'zero_range'| is set the ODF is forced to be zero at
% all orientation where there is a corresponding zero in the pole figure.
% This technique is especially useful for sharp ODF with large areas in the
% pole figure being zero. In this case, the calculation time is greatly
% improved and much higher resolution of the ODF can be achieved.
%
% In the following example, the zero range method is applied with a
% threshold 100. For more options to control the zero range method see the
% documentation of <zeroRangeMethod.zeroRangeMethod.html zero_range> or
% <zeroRangeMethod.plot.html zeroRangeMethod.plot>.

odf = calcODF(pf,'zero_range')
plotPDF(odf,pf.allH,'antipodal','silent','superposition',pf.c)

%% Ghost Corrections
%
% <PoleFigure2ODFGhostCorrection.html Ghost correction> is a technique
% first introduced by Matthies that increases the uniform portion of the
% estimated ODF to reduce the so called _ghost error_. It applies
% especially useful in the case of week ODFs. The classical example is the
% <SantaFe.html SantaFe model ODF>. An analysis of the approximation error
% under ghost correction can be found <PoleFigureSantaFe.html here>
%
%% Theory
%
% ODF estimation in MTEX is based upon the modified least squares
% estimator. The functional that is minimized is 
%
% $$f_{est} = argmin \sum_{i=1}^N \sum_{j=1}^{N_i}\frac{|\alpha_i R f(h_i,r_{ij}) - I_{ij})|^2}{I_{ij}  }$$
% 
% A precise description of the estimator and the algorithm can be found in
% the paper _Pole Figure Inversion - The MTEX Algorithm_.

