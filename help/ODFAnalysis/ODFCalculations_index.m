%% MTEX - ODF Calculations
%
%% Abstract
% ODF calculations are at the heart of MTEX. The philosophy of MTEX is to
% treat all the ODFs the same way, indepentently whether they where
% constructed model ODFs, ODF estimated from pole figure data, or ODF
% estimated from EBSD data. In particular, you can compare, combine and modify
% all ODFs in the same manner.
%
%
%% Contents
%
%% Calculate with Model ODFs
%
% In MTEX it is very simple to define a model ODF as a
% <uniformODF.html uniform ODFs>, a <unimodalODF.html unimodal ODFs>, a
% <fibreODF.hml fibre ODFs>, or any superposition of these
% components. Actually you can calculate with ODFs by adding, subtracting
% and scalling components. Furthermore, the MTEX toolbox allready contains  
% some popular standard ODF as the <santafee.html Santafee> and the
% <mix2.html mix2> sample ODFs. How to work best with model ODFs in MTEX
% can be found <modelODFs_demo.html here> and <ODF_index.html here>.
%
%
%% Recover Orientation Density Functions (ODFs)
%
% Using the method <PoleFigure_calcODF.html calcODF> MTEX allows you to
% recover an ODF from your pole figure data. The method used is based on a
% discretization of the ODF space by radially symmetric function and on the
% fast spherical Fourier transform. The algorithms has proven to be very
% stable and adaptive inparticular to very sharp textures with low symmetry.
% 
% There are also several options like _regularization_, _resolution_,
% _zero_range_method_, _ghost_correction_ that allow addopt the estimation
% method for your presonal needs.
%
% A detailed description of the ODF reconstruction from pole figure data
% can be found at <odf_estimation.html ODF Estimation>. The problem of
% ghost effect is discussed in greater detail in <ghost_demo.html Ghost
% Demo>.
%
% In order to recover an ODF from EBSD data the method <EBSD_calcODF.html
% calcODF> has to be called. It computes a ODF to your EBSD data using
% <EBSD2odf_estimation.html kernel density estimation>.
%
%% Calculate Texture Characteristics 
%
% MTEX offers to compute a wide range of texture characteristics like
% <ODF_modalorientation.html modal orientation>, <ODF_entropy.html entropy>,
% <ODF_textureindex.html texture index>, or <ODF_volume.html volume portion>
% to be computed for any model ODF or any recoverd ODF. You can also
% calculate the Fourier coefficients useing the command <ODF_Fourier.html
% fourier>. Furthermore, you can compare arbitrary ODF indepently whether
% they are model ODFs, ODFs estimated from pole figure data or estimated
% from EBSD data. The <ODF_demo.html ODF Analysis Demo> gives an overview
% over the texture characteristic that can be computed using MTEX.
%
% [[ODF_entropy.html,entropy]], its [[ODF_textureindex.html,textureindex]]
% or the [[ODF_volume.html,volume]] ratio corresponging to a specific
% orientation. Additional functions are 
% [[ODF_hist.html,hist]],
% [[ODF_mean.html,mean]],
% [[ODF_modalorientation.html,modalorientation]],

%
%% Simulate Pole Figures or EBSD Data
%
% In order to analys the relyability of the ODF estimation it is usefull to
% start with a given ODF and simulate pole figure or EBSD data, estimate an
% ODF from these data and to compare the estimated ODF with the original
% one. This allows one to find best parameters for ODF estimation as well
% as for the experimental design. This approach is discused in more detail
% at <PoleFigureSimulation_demo.html PoleFigureSimulation> and
% <EBSDSimulation_demo.html EBSDSimulation>.
