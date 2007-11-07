%% ODF Estimation
%
% 
% MTEX allows to estimate ODFs from any kind of diffraction pole figures.
%  
%
%% Syntax
%
% Starting point of any ODF reconstruction is a 
% <PoleFigure_index.html PoleFigure> object which is in general created by
pf = loadPoleFigure(data_files) 
%%
% See <interfaces_index.html interfaces> for more infomations how to import
% pole figure data and to create a pole figure object. ODF estimation from
% a pole figure object is done by the function 
% <PoleFigure_calcODF.html calcODF>. The most simplest
% syntax is
odf = calcODF(pf)
%%
% You can give a lot of options to the function. You can specify the
% discretization, the functional to minimize, the number of iteration or
% regularization to be applied. Furthermore you can specify ghost 
% correction or the zero range method to be applied. 
%
%% Discretization
%
% In MTEX the ODF is approximated by a superposition of unimodal ODF. By 
% default it is constructed a equidistribution in the orientation space 
% with resolution addapted from the pole figure data. However the
% resolution of the superposition my be adjusted by hand by 
odf = calcODF(of,'resolution',7.5*degree)
%%
% The shape of the unimodal ODF can be specified by passign a specfific kernel
% object
psi = kernel('de la Vallee Pousin','halfwidth',5*degree)
%%
% to the estimation function, i.e.
odf = calcODF(pf,'kernel',psi)
%%
% which is also the default kernel. The more convinient method is directly 
% to pass the halfwidth of the ansatz function as a parameter, i.e.,
odf = calcODF(pf,'halfwidth',5*degree)
%%
%
%% Zero Range Method
%
% If the flag _zero range method_ is set the ODF is forced to be zero at
% all orientation where there is a corresponding zero in the pole figure.
% This technique is especially usfull for sharp ODF with large areas in the
% pole figure beeing zero. In this case the calculation time is greatly
% improved and much higher resolution of the ODF can be achived.
%
%% Ghost Corrections
%
% _Ghost correction_ is a technique first introduced by Matthies that
% increases the uniform portion of the estimated ODF to reduce the so
% called _ghost error_. It applies especially useful in the case of week 
% ODFs. The classical example is the <demo_santafee.html Santafee model ODF>.
%
%% Theory
% ODF estimation in MTEX is based upon the modified least squares
% estimator. The functional that is minimized is 
%
% $$f_{est} = argmin \sum_{i=1}^N \sum_{j=1}^{N_i}\frac{|\alpha_i R f(h_i,r_{ij}) - I_{ij})|^2}{I_{ij}  }$$
% 
% A precise description of the estimator and the algorithm can be foun in
% the paper _Pole Figure Inversion - The MTEX Algorithm_.
