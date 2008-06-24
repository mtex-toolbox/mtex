%% MTEX Changelog
%
%
%% MTEX 0.5 - 06/2008
%
% *MTEX binaries for Windows, Linux, and Max OSX*
%
% * MTEX ships now with binaries for Windows, Linux, and Max OSX. This makes
% in unnecessary to install any additional library and to compile the
% toolbox. (thanks to F. Bachmann and C. Randau )
%
% *New Interfaces*
%
% * new PoleFigure interface for xrdml data (thanks to F. Bachmann)
%
% *Improved Plotting*
%
% * plot EBSD data and continious ODFs into one plot
% * Miller indeces and specimen directions can now be plotted directly into
% pole figures or inverse pole figures.
% * new plotting option north, south for spherical plots 
% * improved colorbar handling
% * spherical grids
% * more spherical projections
%
% *New ODF Class*
%
% * The function <FourierODF.html FourierODF> provides an easy way to define ODFs via
% their Fourier coefficient. In particular MTEX allows now to calculate with
% such an ODF in the same manner as with any other ODF. In particular pole
% figure data or EBSD data can be simulated.
%
% *Incompatible Changes With Previous Releases*
%
% * The flag *hemishpere* in <S2Grid_S2Grid.html S2Grid> has been replaced
% by *north*, *south*, and *reduced* making it more consistent with the
% plotting routine.
%
% *Improved Documentation*
%
% MTEX comes now with over 500 help pages explaining the mathematical concepts, 
% the philisophy behing MTEX and the syntax and usage of all 300 functions
% available in MTEX. Furthermore, you find numerous examples and tutorials on
% ODF estimation, data import, calculation of texture characteristics, ODF and 
% pole figure plotting, etc.
%
% *Bug Fixes*
%
% * Fixed zero range method
% * Fixed automatic ghost correction
% * Fixed some loadPoleFigure
% * Many other bug fixes.
% 
%
%% MTEX 0.4 - 04/2008
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
%
%% MTEX 0.3 - 10/2007
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
% * default plotting options may now be specified in mtex_settings.m
% * new plot option _3d_ for a three dimensional spherical plot of pole
% figures
% * contour levels may be specified explicitely in all plot functions
% [[ODF_plotodf.html,plotodf]],[[ODF_plotpdf.html,plotpdf]] and [[ODF_plotipdf.html,plotipdf]]
% * new plot option _logarithmic_ 
% * many bugfixes
%
%
%% MTEX 0.2 - 07/2007
%
% * new functions [[ODF_textureindex.html,textureindex]], [[ODF_entropy.html,entropy]], [[ODF_volume.html,volume]]
% * creatly improved help 
% * improved installation
% * new options for plotting routines for specific ODF sections
% * many bugfixes
%
%
%% MTEX 0.1 - 03/2007
%
% * initial release
%
