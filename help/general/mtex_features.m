%% MTEX Feature Overview 
%
% MTEX is a MATLAB toolbox that provides powerfull tools for the
% following common tasks in *texture analysis*.
%
%% Analyze and Visualize Crystallographic Geometries
%
% In MTEX you can define arbitrary crystal and specimen symmetries with
% arbitrary geometries using the class <symmetry_index.html
% symmetry>. Working now with <Miller_index.html Miller indece> all aspects
% of crystal geometry as <Miller_angle.html angle> or <Miller_symeq.html
% crystallographically equivalent directions> can be computed and
% visualized. Have also a look at the example <geometry_demo.html Geometry
% Demo>.
%
%
%% Calculate with Model ODFs
%
% In MTEX it is very simple to define model ODF as
% <uniformODF.html uniform ODFs> or <fibreODF.hml fibre ODFs> or any
% superposition of them. In particular the MTEX toolbox allready contains
% some popular standard ODF as the <santafee.html Santafee> and the
% <mix2.html mix2> sample ODFs. How to work best with model ODFs in MTEX is
% explained in the <modelODF_demo.html Model ODF Demo>.
%
%
%% Import, Analyze and Visualize Diffraction Data
%
% Up to now MTEX allready supports a wide range of <interfaces_index.html
% pole figure formats>. However, it is also very simple to use one of the
% generic methods to import data from an unsupported format. Once the data
% are imported you there are various <PoleFigure_index.html methods> to
% analyze and modify them. The <dubna_demo.html Dubna Demo> is a practical
% example demostrating how to apply MTEX for pole figure analysis.
%
%
%% Import, Analyze and Visualize EBSD Data
%
% MTEX provides a <ebsd_interface.html generic interface> for EBSD
% data. This data allows to extract orientations and phase informations from
% almost arbitrary Ascii files. EBSD data may be used for
% <EBSD2odf_estimation.html reconstruction>, Fourier coefficient
% estimation, etc. In fact all methods that are available for ODFs may be
% applied to ODFs estimated from EBSD. In particular it is possible to
% compare ODFs estimated from EBSD data with those estimated from pole
% figure data using the command <ODF_calcerror.html calcerror>. Another
% usefull command in MTEX is <EBSD_simulateEBSD.html simulateEBSD> which
% allows to simulate EBSD data for a given ODF.
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
%% Calculate Texture Characteristics 
%
% MTEX offers to compute a wide range of texture characteristics like
% <ODF_entropy.html entropy>, <ODF_textureindex.html texture index>, or
% <ODF_volume.html volume portion> to be computed for any model ODF or any
% recoverd ODF. You can also calculate the Fourier coefficients useing the
% command <ODF_fourier.html fourier>. Furthermore, you can compare arbitrary
% ODF indepently whether they are model ODFs, ODFs estimated from pole
% figure data or estimated from EBSD data. The <ODF_demo.html ODF Analysis
% Demo> gives an overview over the texture characteristic that can be
% computed using MTEX.
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
% Using the MTEX toolbox it is easy to write little scripts that import
% pole figure data, preprocess them, recalculate an ODF, postprocess it,
% store it to a given location and finaly create several plots. Such
% scripts can now be applied to batch process many pole figure data
% sets. <examples_index.html Examples> of those scripts are included in the help.
%
