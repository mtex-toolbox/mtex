%% MTEX Changelog
%
%% Contents
%
%% MTEX 3.1 - 03/2011
%
% *Tensor Arithmetics*
% This release introduces tensor analysis into MTEX, this includes
%
% * import of tensors via the import wizard
% * basic tensor operations: multiplication, rotation, inversion
% * advanced visualization
% * computation of avaraged tensors from EBSD data and ODFs
% * computation of standard elasticity tensors like: Youngs modulus,
% linear compressibility, Cristoffel tensor, elastic wave velocities
%
% *Other Enhangments*
%
% * support for different crystal reference frame conventions
% * automatic conversion between different reference frames
% * definition of crystal directions in direct and reciprocal space 
% * more predefines orientations: Cube, CubeND22, CubeND45, CubeRD, Goss,
% Copper, SR, Brass, PLage, QLage, ...
% * improved EBSD and grain plots 
% * new and improved interfaces
% * many bug fixes
% 
%
%% MTEX 3.0 - 10/2010
%
% *Crystal Geometry*
%
% This release contains a completely redesigned crystal geometry engine which is
% thought to be much more intuitive and flexible. In particular, it
% introduces two new classes <rotation_index.html rotation> and
% <orientation_index.html orientation> which make it much more easier to
% work with crystal orientations. Resulting features are
%
% * no more need for quaternions
% * support for Bunge, Roe, Matthies, Kocks, and Canova Euler angle
% convention
% * simple definition of fibres
% * simple check whether two orientations are symmetrically equivalent
%
% *Other Enhangments*
%
% * automatic kernel selection in ODF estimation from EBSD data
% * support for Bingham model ODFs
% * esimation of Bingham parameters from EBSD data 
% * faster and more accurate EBSD simulation
% * faster grain reconstruction
% * improved documentation
% * impoved output
% * MTEX is now compatibel with NFFT 3.1.3
%
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
% * The flag *hemishpere* in <S2Grid.S2Grid.html S2Grid> has been replaced
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
% calculation of [[ODF.volume.html,volume fractions]], the
% [[ODF.textureindex.html,texture index]], the [[ODF.entropy.html,entropy]]
% and [[ODF.calcFourier.html,Fourier coefficients]] is about *100 times
% faster*
%
% *New Support of EBSD Data Analysis*
%
% * [[ImportEBSDData.html,Import]] EBSD data from arbitrary data formats.
% * New class [[EBSD_index.html,EBSD]] to store and manipulate with EBSD
% data.
% * [[EBSD.plotpdf.html,Plot pole figures]] and inverse pole figures from
% EBSD data.
% * [[EBSD.calcODF.html,Recover]] ODFs from EBSD data via kernel density
% estimation.
% * [[EBSD.calcODF.html,Estimate]] Fourier coefficients from EBSD data.
% * [[ODF.simulateEBSD.html,Simulate]] EBSD data from ODFs.
% * [[EBSD.export.html,Export]] EBSD data.
%
% *New Functions*
%
% * [[ODF.fibrevolume.html,fibrevolume]] calculates the
% volume fraction within a fibre.
% * [[ODF.plotFourier.html,plotFourier]] plots the Fourier
% coefficients of an ODF.
% * [[setcolorrange.html,setcolorrange]] and the plotting
% option *colorrange* allow for consistent color coding for arbitrary
% plots.
% * A *colorbar* can be added to any plots.
% * [[mat2quat.html,mat2quat]] and [[quaternion.quat2mat.html,quat2mat]] convert rotation matrices to quaternions and vice
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
% * new function [[ODF.Fourier.html,fourier]] to calculate the
% Fouriercoefficents of an arbitrary ODF
% * new option |ghost correction| in function
% [[PoleFigure.calcODF.html,calcODF]]
% * new option |zero range| in function
% [[PoleFigure.calcODF.html,calcODF]]
% * new function [[loadEBSD]] to import EBSD data
% * simplified syntax for the import of diffraction data
% * new import wizard for pole figure data
% * support of triclinic crystal [[symmetry_index.html,symmetry]]
% with arbitrary angles between the axes
% * default plotting options may now be specified in mtex_settings.m
% * new plot option _3d_ for a three dimensional spherical plot of pole
% figures
% * contour levels may be specified explicitely in all plot functions
% [[ODF.plotodf.html,plotodf]],[[ODF.plotpdf.html,plotpdf]] and [[ODF.plotipdf.html,plotipdf]]
% * new plot option _logarithmic_
% * many bugfixes
%
%
%% MTEX 0.2 - 07/2007
%
% * new functions [[ODF.textureindex.html,textureindex]], [[ODF.entropy.html,entropy]], [[ODF.volume.html,volume]]
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
