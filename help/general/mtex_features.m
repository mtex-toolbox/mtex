%% MTEX Feature Overview 
%
% MTEX is a MATLAB toolbox containing the following features
%
%% Analyze and Visualize Crystallographic Geometries
%
% In MTEX you can define arbitrary crystal and specimen symmetries with
% arbitrary geometries using the class <symmetry_index.html
% symmetry>. Working now with <Miller_index.html Miller indece> all aspects
% of crystal geometry as <Miller_angle.html angle> or <Miller_symeq.html
% crystallographically equivalent directions> can be computed and
% visualized.
%
%
%% Calculate with Model ODFs
%
% In MTEX it is very simple to define model ODF as
% <uniformODF.html uniform ODFs> or <fibreODF.hml fibre ODFs> or any
% superposition of them. In particular the MTEX toolbox allready contains
% some popular standard ODF as the <santafee.html Santafee> and the
% <mix2.html mix2> sample ODFs.
%
%
%% Import, Analyze and Visualize Diffraction Data
%
% Up to now MTEX allready supports a wide range of <interfaces_index.html
% pole figure formats>. However, it is also very simple to use one of the
% generic methods to import data from an unsupported format. Once the data
% are imported you there are various <PoleFigure_index.html methods> to
% analyze and modify them.
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
%% Calculate Texture Characteristics 
%
% MTEX offers a wide range of texture characteristics like
% <ODF_entropy.html entropy>, <ODF_textureindex.html texture index>, or
% <ODF_volume.html volume portion> to be computed for any model ODF or
% any recoverd ODF. You can also calculate the Fourier coefficients useing
% the command <ODF_fourier.html fourier>.
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
% eps, tiff, bmp.
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