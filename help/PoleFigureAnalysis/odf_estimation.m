%% ODF Estimation
%
%% Open in Editor
%
%% Abstract
% This page describes how to use MTEX to estimate an ODF from pole figure
% data.
%
%% Contents
%
%% Syntax
%
% Starting point of any ODF reconstruction is a 
% <PoleFigure_index.html PoleFigure> object which can be load e.g. by

pf = loadPoleFigure([mtexDataPath,'/BearTex/Test_2.XPa']);
plot(pf,'silent','position',[100 100 900 350])


%%
% See <interfacesPoleFigure_index.html interfaces> for more infomations how to import
% pole figure data and to create a pole figure object. ODF estimation from
% a pole figure object is done by the function 
% <PoleFigure_calcODF.html calcODF>. The most simplest
% syntax is

odf = calcODF(pf)

%% 
% You may want to verify that the pole figures are reproduced. Here is a
% plot of the computed pole figures.

plotpdf(odf,get(pf,'Miller'),'antipodal','silent')

%%
% You can give a lot of options to the function. You can specify the
% discretization, the functional to minimize, the number of iteration or
% regularization to be applied. Furthermore you can specify ghost 
% correction or the zero range method to be applied. 
%
%% Discretization
%
% In MTEX the ODF is approximated by a superposition of up to 10,000,000
% unimodal components. By exact number and position of these  components,
% as well as its shape can be specified by the user. By default the positions
% are chosen equispaced in the orientation space with 1.5 times the
% resolution of the pole figures and the components are de la Vallee
% Poussin shaped with the same halfwidth as the resoltion of the positions.
%
% Next an example how to change the default resolution:

odf = calcODF(pf,'resolution',15*degree)
plotpdf(odf,get(pf,'Miller'),'antipodal','silent')

%%
% Beside the resolution you can use the following options to change the
% default discretization:
%
% * *kernel* to specify a specific kernel function
% * *halfwidth* to take the default kernel with a specific halfwidth
%
%% Zero Range Method
%
% If the flag *zero_range* is set the ODF is forced to be zero at
% all orientation where there is a corresponding zero in the pole figure.
% This technique is especially usfull for sharp ODF with large areas in the
% pole figure beeing zero. In this case the calculation time is greatly
% improved and much higher resolution of the ODF can be achived.
%
% In the following example the zero range method is applied with a the
% treshhold 100. For more options to control the zero range method see the
% documentation of <PoleFigure_zero_range.html zero_range> or <plot_zero_range.html
% plot_zero_range>.

odf = calcODF(pf,'zero_range','zr_bg',100)
plotpdf(odf,get(pf,'Miller'),'antipodal','silent')

%% Ghost Corrections
%
% _Ghost correction_ is a technique first introduced by Matthies that
% increases the uniform portion of the estimated ODF to reduce the so
% called _ghost error_. It applies especially useful in the case of week 
% ODFs. The classical example is the <santafee_demo.html Santafee model
% ODF>. An analysis of the approximation error under ghost correction can
% be found <PoleFigureSimulation.html here>
%
%% Theory
%
% ODF estimation in MTEX is based upon the modified least squares
% estimator. The functional that is minimized is 
%
% $$f_{est} = argmin \sum_{i=1}^N \sum_{j=1}^{N_i}\frac{|\alpha_i R f(h_i,r_{ij}) - I_{ij})|^2}{I_{ij}  }$$
% 
% A precise description of the estimator and the algorithm can be foun in
% the paper _Pole Figure Inversion - The MTEX Algorithm_.
