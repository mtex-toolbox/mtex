%% MTEX Changelog
%
%
%% MTEX 0.4 - 07.04.2008
%
% *Speed Improvments*
%
% * ODF reconstruction and PDF calculation is about *10 times faster* now (thanks
% to the new NFFT 4.0 library)
% * ODF plotting and the
% calculation of [[ODF_volume.html,volume fractions]], the
% [[ODF_textureindex.html,texture index]], the [[ODF_entropy.html,entropy]] 
% and [[ODF_calcfourier.html,Fourier coefficients]] is about *100 times
% faster*
%
% *New Support of EBSD Data Analysis*
%
% * [[interfacesEBSD_index.html,Import]] EBSD data from arbitrary data formats.
% * New class [[EBSD_index.html,EBSD]] to store and manipulate with EBSD
% data. 
% * [[EBSD_plotpdf.html,Plot pole figures]] and inverse pole figures from
% EBSD data.
% * [[EBSD_calcODF.html,Recover]] ODFs from EBSD data via kernel density
% estimation.
% * [[EBSD_calcODF.html,Estimate]] Fourier coefficients from EBSD data.
% * [[ODF_simulateEBSD.html,Simulate]] EBSD data from ODFs.
% * [[EBSD_export.html,Export]] EBSD data.
%
% *New Functions*
%
% * [[ODF_fibrevolume.html,fibrevolume]] calculates the
% volume fraction within a fibre.
% * [[ODF_plotFourier.html,plotFourier]] plots the Fourier
% coefficients of an ODF.
% * [[setcolorrange.html,setcolorrange]] and the plotting
% option *colorrange* allow for consistent color coding for arbitrary
% plots.
% * A *colorbar* can be added to any plots.
% * [[mat2quat.html,mat2quat]] and [[quaternion_quat2mat.html,quat2mat]] convert rotation matrices to quaternions and vice
% versa.
%
% *Incompatible Changes With Previous Releases*
%
% * New, more flexibel syntax for the generation of
% [[S2Grid_index.html,S2Grids]]
% * Slightly changed syntax of [[unimodalODF.html,unimodalODF]] and
% [[fibreODF.html,fibreODF]]. 
% * Default plotting options are set to {}, i.e. 'reduced' has to add
% manualy if desired
% * Crystal symmetry *triclinic* is not called *tricline* anymore.
%
%% MTEX 0.3 - 22.10.2007
%
% * new function [[ODF_fourier.html,fourier]] to calculate the
% Fouriercoefficents of an arbitrary ODF
% * new option |ghost correction| in function 
% [[PoleFigure_calcODF.html,calcODF]]
% * new option |zero range| in function 
% [[PoleFigure_calcODF.html,calcODF]]
% * new function [[loadEBSD]] to import EBSD data
% * simplified syntax for the import of diffraction data
% * new import wizard for pole figure data
% * support of triclinic crystal [[symmetry_index.html,symmetry]] 
% with arbitrary angles between the axes
% * default plotting options may now be specified in startup_mtex
% * new plot option _3d_ for a three dimensional spherical plot of pole
% figures
% * contour levels may be specified explicitely in all plot functions
% [[ODF_plotodf.html,plotodf]],[[ODF_plotpdf.html,plotpdf]] and [[ODF_plotipdf.html,plotipdf]]
% * new plot option _logarithmic_ 
% * many bugfixes
%
%% MTEX 0.2 - 01.07.2007
%
% * new functions [[ODF_textureindex.html,textureindex]], [[ODF_entropy.html,entropy]], [[ODF_volume.html,volume]]
% * creatly improved help 
% * improved installation
% * new options for plotting routines for specific ODF sections
% * many bugfixes
%
%% MTEX 0.1 - 01.04.2007
%
% * initial release
%
