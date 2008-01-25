%% MTEX Changelog
%
%
%% MTEX 0.4
%
% * new function kernel_density_estimation to recover ODFs from EBSD data
% * speed up evaluation of recalculated ODFs by a factor up to >100
% * speed up of the functions [[ODF_textureindex.html,textureindex]],
% [[ODF_entropy.html,entropy]], [[ODF_volume.html,volume]] by the same
% factor
% * speed up reconstruction of ODFs by a factor up to 4 (due to improvments
% of the NFFT library)
% * additionaly speed up reconstruction of cubic - orthorhombic ODFs by
% factor 4 
% * smaller overall speedups
% * new, more flexibel syntax for the generation of
% [[S2Grid_index.html,S2Grids]] 
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
