%% Feature Overview 
% Gives an overview of the central features of the MTEX toolbox.
%
%% Contents
%
%% Analyze and Visualize Crystallographic Geometries
%
% In MTEX you can define arbitrary crystal and specimen symmetries with
% arbitrary geometries using the class <symmetry_index.html
% symmetry>. <Miller_index.html Miller indice> may be <Miller.plot.html
% plotted> in various spherical projections, the <vector3d.angle.html
% angle> between two Miller indices can be computed or all
% <Miller.symmetrise.html crystallographically equivalent directions> can be
% computed. Orientations can be specified in terms of different Euler angle
% conventions, in terms of Rodrigues parameters, matrices or axis - angle
% parametrization. Orientations can be applied to Miller indices, ODFs,
% pole figure data, and EBSD data to perform rotations. Have also a look 
% at the <CrystalGeometry.html Crystal Geometry help page>.
%
%
%% Calculate with Model ODFs
%
% In MTEX it is very simple to define a model ODF as a
% <uniformODF.html uniform ODFs>, a <unimodalODF.html unimodal ODFs>, a
% <fibreODF.hml fibre ODFs>, a <BinghamODF.html Bingham ODF>,
% or any superposition of these components. Furthermore, the MTEX toolbox
% already contains some popular standard ODF as the <SantaFe.html SantaFe>
% and the <mix2.html mix2> sample ODFs. How to better work model ODFs in
% MTEX can be found <ODFAnalysis.html here>.
%
%
%% Import, Analyze and Visualize Diffraction Data
%
% Up to now MTEX already supports a wide range of <ImportPoleFigureData.html
% pole figure formats>. Furthermore, there is a
% <loadPoleFigure_generic.html generic interface> that allows importing pole
% figure data that are stored in ASCII files in the theta - rho -
% intensity notation. 
%
% It is also very simple to write your own interface using the powerful
% generic methods provided by MTEX. Once the data are imported by you, there are
% many <PoleFigure_index.html methods> to analyze and modify them. The
% <dubna_demo.html Dubna Demo> is a practical example demonstrating how to
% apply MTEX for pole figure analysis.
%
%
%% Import, Analyze and Visualize EBSD Data
%
% MTEX provides a <ImportEBSDData.html generic interface> for EBSD
% data. This interface allows extracting orientations and phase information
% from almost arbitrary ASCII files. EBSD data may be used for
% <EBSD2odf.html reconstruction>, Fourier coefficient estimation,
% etc. In fact, all methods that are available for ODFs may be applied to
% ODFs estimated from EBSD. In particular, it is possible to compare ODFs
% estimated from EBSD data with those estimated from pole figure data using
% the command <ODF.calcError.html calcError>. Another useful command in
% MTEX is <ODF.calcEBSD.html calcEBSD> which allows simulating
% EBSD data for a given ODF.
%
% A practical guide to EBSD data analysis with MTEX can be found
% <ebsd_demo.html here>.
%
%
%% Recover Orientation Density Functions (ODFs)
%
% Using the method <PoleFigure.calcODF.html calcODF> MTEX allows you to
% recover an ODF from your pole figure data. This method is based on a
% discretization of the ODF space by radially symmetric function and on the
% fast spherical Fourier transform. The algorithms have proven to be very
% stable and adaptive, in particular, to very sharp textures with low symmetry.
% 
% There are also several options like _regularization_, _resolution_,
% _zero_range_method_, _ghost_correction_ that allow adopt the estimation
% method for your personal needs.
%
% A detailed description of the ODF reconstruction from pole figure data
% can be found at <PoleFigure2odf.html ODF Estimation>. The problem of
% ghost effect is discussed in greater detail in <ghost_demo.html Ghost
% Demo>.
%
% In order to recover an ODF from EBSD data, the method <EBSD.calcODF.html
% calcODF> has to be called. It computes an ODF to your EBSD data using
% <EBSD2odf.html kernel density estimation>.
%
%% Calculate Texture Characteristics 
%
% MTEX offers to compute a wide range of texture characteristics like
% <ODF.calcModes.html modal orientation>, <ODF.entropy.html entropy>,
% <ODF.textureindex.html texture index>, or <ODF.volume.html volume portion>
% to be computed for any model ODF or any recovered ODF. You can also
% calculate the Fourier coefficients using the command <ODF.Fourier.html
% Fourier>. Furthermore, you can compare arbitrary ODF independently whether
% they are model ODFs, ODFs estimated from pole figure data or estimated
% from EBSD data. The <ODF_demo.html ODF Analysis Demo> gives an overview
% over the texture characteristic that can be computed using MTEX.
%
%
%% Create Publication Ready Plots
%
% Founded on the state of the art MATLAB plotting routines, MTEX allows you to
% create professional plots of <ODF.plotPDF.html pole figures>,
% <ODF.plotIPDF.html inverse pole figures>, and <ODF.plotSection.html ODF sections>.
% There are also many <S2Grid.plot.html plotting options> to adapt the
% plots to the specific standards of the journal you want to submit your paper. Plots may be
% <savefigure.html saved> in any image format, e.g. as pdf, jpg, png,
% eps, tiff, bmp. This is described in more details in the <Plotting.html
% Plot Demo>.
%
%
%% Writing Scripts to Process Many Data Sets
%
% Using the MTEX toolbox it is easy to write little scripts that import pole
% figure data, pre-process them, recalculate an ODF, post-process it, store it
% to a given location and finally create several plots. Such scripts can be
% easily applied to batch process many pole figure data
% sets. <examples_index.html Examples> of those scripts are included in the
% help.
%
