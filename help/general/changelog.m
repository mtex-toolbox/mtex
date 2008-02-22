%% MTEX Changelog
%
%
%% MTEX 0.4
%
% * speed improvement about factor 10 in ODF reconstruction and PDF 
% calculation (thanks to the new NFFT 4.0 library)
% * spped improvement about factor 100 in ODF plotting and the
% calculation of [[ODF_volume.html,volume fractions]], the
% [[ODF_textureindex.html,texture index]], the [[ODF_entropy.html,entropy]] 
% and [[ODF_calcfourier.html,Fourier coefficients]]
% * new class [[EBSD_index.html,EBSD]] to work with EBSD data. 
% * new functions to [[interfacesEBSD_index.html,import]], 
% [[EBSD_plotpdf.html,plot]], analyse, manipulate and 
% [[EBSD_export.html,save]] EBSD data.
% * new function [[EBSD_calcODF.html,calcODF]] to recover ODFs from EBSD 
% data via kernel density estimation.
% * new function [[ODF_fibrevolume.html,fibrevolume]] to calculate the
% volume fraction within a fibre
% * new function [[ODF_plotFourier.html,plotFourier]] to plot the Fourier
% coefficients of an ODF
% * new, more flexibel syntax for the generation of
% [[S2Grid_index.html,S2Grids]] 
% * slightly changed syntax of [[unimodalODF.html,unimodalODF]] and
% [[fibreODF.html,fibreODF]]
% * default plotting options are set to {}, i.e. 'reduced' has to add
% manualy if desired
% * some bug fixes
%
%% MTEX 0.3
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
%% MTEX 0.2
%
% * new functions [[ODF_textureindex.html,textureindex]], [[ODF_entropy.html,entropy]], [[ODF_volume.html,volume]]
% * creatly improved help 
% * improved installation
% * new options for plotting routines for specific ODF sections
% * many bugfixes
%
%% MTEX 0.1
%
% * initial release
%
