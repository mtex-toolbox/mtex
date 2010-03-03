%% MTEX Changelog
%
%% Contents
%
%% MTEX 3.0 -
%
% *Crystal Geometry*
%
% This release contains a newly designed crystal geometry engine which is
% thought to be much more intuitive and flexible.
%
% * new class <rotation_index.html rotation>
% * new orientation <orientation_index.html orientation>
% *
%
% *Generel Code Refactorisation*
%
% * MTEX is now compatibel with NFFT 3.1.3
%
% *New Features*
%
% Beside all the technical changes there are also some new features
%
% * Bingham distrubted ODFs
% * Faster and more accurate EBSD simulation
%
%% MTEX 2.0 - 10/2009
%
% *Grain Analysis for EBSD Data*
%
% MTEX is now able to partition spatial EBSD data into grains. This
% allows for the computation of various grain characteristics, as well as
% the computation and visualization of the grain boundaries and
% neighborhood relationships. Main features are:
%
% * Grains statistics (area, diameter, mean orientation, ...)
% * Missorientation analysis
% * Interactive selection of grains by various criteria
% * ODF-calculations for any subset of grains
% * A large palette of plotting possibilities.
%
% *Visualization Improvements*
%
% * ODF fibre plot
% * support for different x-axis alignment - <plotx2north.html  plotx2north>,
% <plotx2east.html plotx2east>
% * plot EBSD data with respect to arbitrary properties
% * plot zero regions of ODFs and pole figures white
% * pole figure contour plots
% * color triangle for spatial EBSD plots
%
% *General Improvements*
%
% * ODF import / export
% * rotate EBSD data
% * Pole figure normalization
% * improved interfaces and import wizard
% * speed improvement of several side-functions as well as core-functions of
% @quaternions and spherical grids.
%
% *Incompatible Changes to Previous Versions*
%
% * The flags *reduced* and *axial* have been replaced by the flag <AxialDirectional.html
% antipodal>
%
%% MTEX 1.2 - 05/2009
%
% *Improved EBSD import*
%
% * import weighted EBSD (e.g. from odf modeling)
% * new HKL and Chanel interfaces (.ang and .ctf files)
% * import of multiple phases
% * import of arbitrary properties as MAD, detection error, etc.
%
% *Improved EBSD plotting*
%
% * plot EBSD data in axis angle and Rodrigues space
% * annotations in these spaces
% * plot arbitrary properties as MAD, detection error, etc.
% * better orientation colorcoding
% * superpose odf, pole figure and EBSD plots
% * better interpolation
%
% *General Improvements*
%
% * support for different crystal geometry setups
% * faster and more accurate volume computation
% * improved function modalorientation
% * improved documentation
%
% *Incompatible Changes to Previous Versions*
%
% * The flag *reduced* has been replaced by the flag <AxialDirectional.html
% axial>
%
%% MTEX 1.1 - 12/2008
%
% *Improved Import Wizzard*
%
% * Load CIF files to specify crystal geometry
% * Import EBSD data with coordinates
% * More options to specify the alignment of the specimen coordinate system
% * support for popla *.epf files, *.plf files, and *.nja files
%
%
% *Improved Pole Figure Analysis*
%
% * Background correction and defocussing
% * Outlier detection and elimination
%
% *Improved EBSD Data Support*
%
% * Spatial plot of EBSD data
% * Modify EBSD data in the same way as pole figures
%
% *Improved Plotting*
%
% * GUI to modify plots more easily
% * Annotate orientations into pole figure plots
% * Annotate orientations into ODF sections
% * Coordinate systems for ODF and pole figure plots
% * More flexible and consistent option system
% * Default plotting options like FontSize, Margin, ...
% * Speed improvements
%
% *Bug Fixes*
%
% * ModalOrientation works now much better
% * Plot (0,0) coordinate in ODF plot at upper left
% * Fixed a bug in ODF estimation from EBSD data
%
%
%% MTEX 1.0 - 06/2008
%
% *New Installer Including Binaries for Windows, Linux, and Max OSX*
%
% * MTEX ships now with an automated installer and binaries for Windows,
% Linux, and Mac OSX. This makes it in unnecessary to install any
% additional library and to compile the toolbox. (Thanks to F. Bachmann,
% C. Randau, and F. Wobbe)
%
% *New ODF Class*
%
% * The new function <FourierODF.html FourierODF> provides an easy way to define ODFs via
% their Fourier coefficients. In particular MTEX allows now to calculate with
% those ODFs in the same manner as with any other ODFs.
%
% *New Interfaces*
%
% * New PoleFigure interface for xrdml data (F. Bachmann)
%
% *Improved Plotting*
%
% * Plot EBSD data and continious ODFs into one plot
% * Miller indeces and specimen directions can now be plotted directly into
% pole figures or inverse pole figures.
% * New plotting option north, south for spherical plots
% * Improved colorbar handling
% * Spherical grids
% * More spherical projections
%
% *Incompatible Changes With Previous Releases*
%
% * The flag *hemishpere* in <S2Grid_S2Grid.html S2Grid> has been replaced
% by *north*, *south*, and *antipodal* making it more consistent with the
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
% * Fixed some loadPoleFigure issues
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
% and [[ODF_calcFourier.html,Fourier coefficients]] is about *100 times
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
% * Default plotting options are set to {}, i.e. 'antipodal' has to add
% manualy if desired
% * Crystal symmetry *triclinic* is not called *tricline* anymore.
%
%
%% MTEX 0.3 - 10/2007
%
% * new function [[ODF_Fourier.html,fourier]] to calculate the
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
