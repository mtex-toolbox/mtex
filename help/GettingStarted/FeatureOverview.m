%% Feature Overview 
% Gives an overview over the central features of the MTEX toolbox.
%
%% Contents
%
%% Analyze and Visualize Crystallographic Geometries
%
% In MTEX you can define arbitrary crystal and specimen symmetries with
% arbitrary geometries using the class <symmetry_index.html
% symmetry>. <Miller_index.html Miller indice> may be <Miller_plot.html
% plotted> in various spherical projections, the <Miller_angle.html
% angle> between two Miller indece can be computed or all
% <Miller_symeq.html crystallographically equivalent directions> can be
% computed. Orientations can be specified in terms of different Euler angle
% conventions, in terms of Rodrigues parameters, matrices or axis - angle
% parametrization. Orientations can be applied to Miller indeces, ODFs,
% pole figure data, and EBSD data to peform rotations. Have also a look 
% at the <CrystalGeometry.html Crystal Geometry help page>.
%
%
%% Calculate with Model ODFs
%
% In MTEX it is very simple to define a model ODF as a
% <uniformODF.html uniform ODFs>, a <unimodalODF.html unimodal ODFs>, a
% <fibreODF.hml fibre ODFs>, a <BinghamODF.html Bingham ODF>,
% or any superposition of these components. Furthermore, the MTEX toolbox
% allready contains some popular standard ODF as the <SantaFe.html SantaFe>
% and the <mix2.html mix2> sample ODFs. How to work best with model ODFs in
% MTEX can be found <ODFAnalysis.html here>.
%
%
%% Import, Analyze and Visualize Diffraction Data
%
% Up to now MTEX allready supports a wide range of <interfacesPoleFigure_index.html
% pole figure formats>. Furthermore, there is a
% <interface_generic.html generic interface> that allows to import pole
% figure data that are stored in ASCII files in the theta - rho -
% intensity notation. 
%
% It is also very simple to write your own interface utilizing the powerfull
% generic methods provided by MTEX. Once the data are imported you there are
% various <PoleFigure_index.html methods> to analyze and modify them. The
% <dubna_demo.html Dubna Demo> is a practical example demostrating how to
% apply MTEX for pole figure analysis.
%
%
%% Import, Analyze and Visualize EBSD Data
%
% MTEX provides a <ebsd_interface.html generic interface> for EBSD
% data. This interface allows to extract orientations and phase informations
% from almost arbitrary Ascii files. EBSD data may be used for
% <EBSD2odf_estimation.html reconstruction>, Fourier coefficient estimation,
% etc. In fact all methods that are available for ODFs may be applied to
% ODFs estimated from EBSD. In particular it is possible to compare ODFs
% estimated from EBSD data with those estimated from pole figure data using
% the command <ODF_calcerror.html calcerror>. Another usefull command in
% MTEX is <EBSD_simulateEBSD.html simulateEBSD> which allows to simulate
% EBSD data for a given ODF.
%
% A practical guide to EBSD data analysis with MTEX can be found
% <ebsd_demo.html here>.
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
% Fourier>. Furthermore, you can compare arbitrary ODF indepently whether
% they are model ODFs, ODFs estimated from pole figure data or estimated
% from EBSD data. The <ODF_demo.html ODF Analysis Demo> gives an overview
% over the texture characteristic that can be computed using MTEX.
%
%
%% Create Publication Ready Plots
%
% Founded on the state of the art MATLAB plotting routins MTEX allows you to
% create professional plots of <ODF_plotpdf.html pole figures>,
% <ODF_plotipdf.html inverse pole figures>, and <ODF_plotodf.html ODF sections>.
% There are also many <S2Grid_plot.html plotting options> to addapt the
% plots to the specific standards of your journal. Plots may be
% <savefigure.html saved> in any image format, e.g. as pdf, jpg, png,
% eps, tiff, bmp. This is described in more detail in the <plot_demo.html
% Plot Demo>.
%
%
%% Writting Scripts to Process Many Data Sets
%
% Using the MTEX toolbox it is easy to write little scripts that import pole
% figure data, preprocess them, recalculate an ODF, postprocess it, store it
% to a given location and finaly create several plots. Such scripts can be
% easily applied to batch process many pole figure data
% sets. <examples_index.html Examples> of those scripts are included in the
% help.
%
