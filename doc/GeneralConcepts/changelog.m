%% MTEX release notes
%
% Releases appear newest first. Each section describes new analysis tools,
% changes that may affect existing scripts, and corrections to results.
% Historical examples use the syntax of their release. Follow the linked
% topic or function page when writing new code.
%
% |CHANGELOG.md| in the MTEX folder contains the technical details, numerical
% checks and related issues.
%
%% MTEX 7.2 10/2026
%
% *Three-dimensional EBSD*
%
% Eventually, MTEX supports the import, visualization and analysis of 3D
% EBSD volumes. <EBSD3.load.html |EBSD3.load|> reads DREAM.3D files from
% DREAM.3D 6 or DREAM3D-NX, and Xnovo GrainMapper3D files:
%
%   ebsd = EBSD3.load('SmallIN100_MeshStats.dream3d')
%
% Work with a volume much as you would with a 2D EBSD map. |ebsd(i,j,k)|
% selects a voxel, |ebsd('Quartz')| selects a phase, and |ebsd.orientations|
% gives the measured orientations. <EBSD3.plot.html |plot|> opens an
% interactive viewer. Move the slice planes with the mouse and colour the
% volume by phase, orientation or another measured property:
%
%   plot(ebsd,ebsd.orientations)
%
% <EBSD3.slice.html |slice|> extracts a section along any plane. The result
% is a 2D EBSD map that can be analysed with the usual map tools:
%
%   ebsdCut = slice(ebsd,plane3d(vector3d(1,1,1),vector3d(0,0,0)))
%   plot(ebsdCut,ebsdCut.orientations)
%
% Local misorientation calculations use neighbouring voxels along all three
% axes. <EBSD3.KAM.html |KAM|> returns the kernel average misorientation.
% <EBSD3square.curvature.html |curvature|> returns the lattice curvature
% tensor used to estimate geometrically necessary dislocation (GND) density.
% A 3D volume provides all nine tensor components; a 2D map provides six.
%
%   kam = KAM(ebsd,'threshold',5*degree);
%
% See <EBSD3Analysis.html Three-Dimensional EBSD Analysis> for the analysis
% workflow and <EBSD3Plotting.html Volume Data and Slices> for importing,
% displaying and sectioning volumes.
%
% *Grain reconstruction and boundaries in 3D*
%
% <EBSD3square.calcGrains.html |calcGrains|> reconstructs grains from a
% volume using the same syntax as for a 2D map:
%
%   [grains,ebsd] = calcGrains(ebsd,'angle',5*degree,'minPixel',10)
%
% Neighbouring voxels of the same phase are assigned to one grain when their
% misorientation is below the threshold. |'minPixel'| merges grains with fewer
% than the specified number of voxels into their neighbours.
%
% Each grain has a mean orientation, grain orientation spread |grains.GOS|,
% <grain3d.volume.html |volume|>, <grain3d.surface.html |surface|> area,
% diameter, principal axes and neighbouring grains. These sizes and shapes
% are measured in 3D and need no stereological correction. Each boundary face
% stores the two adjacent grains and their misorientation.
%
% To use grain identifiers already stored in a DREAM.3D or Xnovo file:
%
%   grains = calcGrains(ebsd,'grainId')
%
% This lets you analyse an existing segmentation and compare it with a
% reconstruction made in MTEX.
%
% Voxel boundaries have a staircase shape. This overestimates boundary area
% and restricts boundary normals to six directions.
% <grain3d.reduceBoundary.html |reduceBoundary|> coarsens the surface mesh
% and <grain3d.smoothBoundary.html |smoothBoundary|> smooths it using the
% filters available for 2D grains. Triple lines, quadruple points and the
% outer specimen surface remain fixed. Grain volumes can change by a few
% percent during smoothing:
%
%   grains = smoothBoundary(reduceBoundary(grains,2,'quadric'),taubinFilter(20))
%
% Use <grain3Boundary.calcGBND.html |calcGBND|> on the smoothed boundaries
% to compute the grain boundary plane distribution from their normals.
% <grain3Boundary.edges.html |edges|> and <grain3Boundary.nodeType.html
% |nodeType|> identify triple lines and quadruple points in the network.
%
% See <Grains3DReconstruction.html Grain Reconstruction>,
% <Grains3DSmoothing.html Boundary Smoothing>, <Grains3DBoundaries.html
% Boundary Network>, <Grains3DProperties.html Grain Size and Shape> and
% <Grains3DOperations.html Sections and Rotations>.
%
% *Inverse pole figure maps in one command*
%
% Create an inverse pole figure (IPF) map for all phases in one command.
% Each phase uses its own colour key. Grain maps use the mean grain
% orientations:
%
%   plot(ebsd,'ipfz')
%   plot(grains,'ipfDirection',vector3d.X)
%
% *Importing instrument data*
%
% <EBSDVendors.html Data From Your Instrument> lists supported file formats,
% import commands and reference-frame conventions for Bruker, EDAX, Oxford,
% Thermo Fisher and other vendors. New in this release:
%
% * Oxford |.h5oina| files containing diffraction patterns now import with
% all their map properties
% * NanoMegas ASTAR |.ang| files are recognised and read in nanometres, and
% |'scanUnit'| sets the spatial unit when importing any |.ang| file
% * |loadPoleFigure_inel| reads INEL pole figure files
% * <mtexdata.html |mtexdata|> refreshes its stored copy of a data set when the
% MTEX version or the default plotting convention has changed
%
% *Choosing the smoothing width for texture estimation*
%
% The kernel halfwidth controls smoothing when estimating an orientation
% distribution function (ODF) from EBSD data. A wide kernel blurs texture
% components; a narrow kernel can produce peaks from individual grains.
% <EBSD.calcKernel.html |calcKernel|> selects the halfwidth from the data
% while accounting for the correlation between pixels within each grain.
% Reconstruct the grains before selecting the kernel:
%
%   [grains,ebsd] = calcGrains(ebsd)
%   psi = calcKernel(ebsd('Forsterite'))
%   odf = calcDensity(ebsd('Forsterite').orientations,'kernel',psi)
%
% Two new methods are available. Unbiased cross-validation (|'UCV'|)
% estimates the halfwidth that minimizes the error of the density estimate.
% |'conservative'| favours a wider kernel to suppress uncertain features. Use
% <vector3d.calcKernel.html |calcKernel|> to select a kernel for directional
% data as well. See <OptimalKernel.html Optimal Kernel Selection>.
%
% *Comparing textures*
%
% <S2Fun.discrepancy.html |discrepancy|> measures differences between two
% ODFs, two pole density functions, two orientation sets, or an orientation
% set and an ODF. For example, use it to check how well the orientations
% supplied to a simulation represent a measured texture.
% |fibonacciSO3Grid| provides a new, evenly distributed orientation grid.
%
% *Documentation*
%
% The documentation has three parts. Start covers installation and your
% first map. Concepts explains crystal geometry, orientations and textures.
% Tasks provides workflows for analysing your data.
%
% *Changes that may affect existing scripts*
%
% Check these changes when updating an analysis:
%
% * Oxford |.ctf|, |.cpr| and |.h5oina| imports now align the map and Euler
% angle reference frames using a 180-degree rotation about y, previously z.
% This places $Z_1$ out of the specimen surface. IPF colours are unchanged,
% but pole figures are mirrored across the map's x axis. Pass
% |'EulerCorrection',rotation.byAxisAngle(zvector,180*degree)| for the
% previous alignment
% * Thermo Fisher (xTalView) imports align the map and Euler angle reference
% frames using a 180-degree rotation about y. The map's pixel x axis points
% opposite to the specimen x axis
% * generic orientation, EBSD and ODF text files are read in degrees unless
% |'radians'| is given. Previously, MTEX inferred the unit from the values
% and could interpret small angles in degrees as radians
% * <l1TVFilter.l1TVFilter.html |l1TVFilter|> uses a smoothing length:
% |l1TVFilter(L)| reduces variations with wavelength L to half their
% amplitude. The default L is four pixel spacings. A manually specified
% |alpha| is now the regularization weight. |halfQuadraticFilter| calls
% this filter
% * after <grain2d.smoothBoundary.html |smoothBoundary|> a boundary segment
% that replaces several pixel edges has |gB.ebsdId| set to 0. Use
% |'noSimplify'| and |'noRefine'| if you need the original pixel pair for
% every segment
% * the |'bandwidth'| of |kde1d| and of <calcDensity.html |calcDensity|> is
% specified in the units of the data, matching the returned bandwidth
% * an orientation applied to a tangent vector gives a plain vector in the
% specimen frame
% * the default line energy of a
% <dislocationSystem.dislocationSystem.html |dislocationSystem|> is $b^2$
% for an edge and $0.7\,b^2$ for a screw dislocation, with $b$ the length of
% the Burgers vector. Previously it was 2 and 1.
% <EBSD.calcGND.html |calcGND|> with default energies therefore returns
% different values. Set |dS.u| to keep your own weights; see
% <DislocationSystems.html Dislocation Systems>
% * MTEX needs MATLAB R2022b or newer
%
% *Corrections to analysis results and data handling*
%
% * exporting a map to |.ang| or |.ctf| and importing it again now preserves
% its orientations. Previously, hexagonal maps could rotate by 30 degrees
% * IPF colour keys use the correct fundamental sector when the lattice c*
% axis is not parallel to z
% * <EBSD.gridify.html |gridify|> retains the indexed measurement when an
% indexed and a non-indexed measurement occupy the same position
% * incomplete |.osc| scans are placed on the correct grid. Phases specified
% by an EDAX point group identifier are retained during import
% * |.ctf| files import without the Statistics and Machine Learning Toolbox
% * <EBSD.load.html |EBSD.load(fname,csList)|> again uses the supplied
% symmetry list. |'CS'| overrides the phases declared in an HDF5 file
% * <EBSD.interp.html |interp|> on a gridded map uses measured pixels only
% * |calcGrains| of a map without indexed pixels returns empty grains
% * pole figures imported with a separate specimen grid for each figure now
% use consistent normalization
% * |S2Fun.unimodal| has mean one and peaks at the specified direction.
% |S2FunBingham| uses exact normalization
% * the random orientations drawn from a fibre ODF (|SO3FunCBF|) follow the
% ODF. Previously, samples lay too close to the fibre
% * dislocation systems built from hexagonal slip systems have Burgers
% vectors of the correct length, $a$ for $\langle a\rangle$ slip. Previously
% they were a third of it, and the fitted dislocation densities three times
% too large
% * |stiffnessTensor.load| reads the density specified in the file
% * grain meshes imported from DREAM.3D use the orientations of their voxels.
% A section through a 3D grain with a hole retains the hole in a single grain
% * <grain3Boundary.calcGBND.html |calcGBND|> of a 3D boundary at a fixed
% misorientation now uses the correct angular weighting of boundary faces.
% Previously, the weighting used twice the angular distance
%
%% MTEX 7.1 09/2026
%
% *Aligning EBSD maps with SEM images using TrueEBSD*
%
% Specimen tilt and drift during scanning can distort an EBSD map relative
% to a scanning electron microscope (SEM) image of the same area. The new
% TrueEBSD workflow corrects these distortions and aligns the images on a
% common grid. Supply images in order from the most distorted to the
% undistorted reference image. Each aligned image becomes a map property:
%
%   job = trueEbsd([mapImage(ebsd.bc,ebsd), mapImage(bse,'dxy',0.05)]);
%   job.pixelSizeMatch
%   job.calcDistortion
%   job.undistort
%
% The workflow also provides tools that can be used separately:
%
% * <mapImage.mapImage.html |mapImage|> stores an image with the specimen
% coordinates of its pixels
% * <spatialTransform.html |spatialTransform|> describes a spatial
% distortion. Transforms can be combined and inverted like a
% <rotation.rotation.html |rotation|>
% * <xcfShift.html |xcfShift|> measures local image shifts by
% cross-correlating corresponding tiles
% * <EBSD.gridify.html |gridify|> accepts a
% <gridLayout.gridLayout.html |gridLayout|> to store an EBSD map in the
% same array order as the image being compared
%
% See <EBSDMapsAndImages.html Maps and Images>, <EBSDSpatialTransform.html
% Spatial Transforms> and <EBSDTrueEbsd.html TrueEBSD>. The method is by
% Tong et al., <https://arxiv.org/abs/2605.00703 arXiv 2605.00703>.
%
% *HDF5 export preserves acquisition data*
%
% HDF5 export copies the original input file and updates the modified data
% in the copy. The output retains the vendor's format, diffraction patterns
% and acquisition settings, with the MTEX results added alongside them:
%
%   ebsd = EBSD.load('myfile.h5oina')
%   ebsd = ebsd.denoise(l1TVFilter)
%   export(ebsd,'denoised.h5oina')
%
% *Updated documentation*
%
% The revised documentation explains crystallographic texture analysis
% through practical MTEX examples, with more background on the concepts
% and methods.
%
% *Plastic work in the Taylor model*
%
% <strainTensor.calcTaylor.html |calcTaylor|> returns plastic work as the
% sum of slip amounts weighted by their critical resolved shear stresses:
%
%   work = calcTaylor(eps,sS,'plasticWork')
%
% The returned Taylor factor measures total slip activity. It equals the
% plastic work only when every critical resolved shear stress is one. When
% slip systems have different strengths, compare their plastic work.
% <calcLankford.html |calcLankford|> now minimizes plastic work when choosing
% the contraction path and reports Rbar and deltaR separately. See
% <Plasticity.html Plasticity>.
%
% *Three-dimensional EBSD*
%
% Import measured volumes into an |EBSD3| object and analyse them with
% commands familiar from 2D EBSD. DREAM.3D and Xnovo GrainMapper3D files
% are supported, including their stored grain identifiers:
%
%   ebsd = EBSD3.load('SmallIN100_MeshStats.dream3d')
%   [grains,ebsd] = calcGrains(ebsd,'angle',5*degree)
%   grainsStored = calcGrains(ebsd,'grainId')
%
% <EBSD3square.calcGrains.html |calcGrains|> uses the same misorientation
% criteria as in 2D, including |'minPixel'|. It returns a
% <grain3d.grain3d.html |grain3d|> object with a closed triangulated boundary
% surface. Each face stores the adjacent voxel pair and its misorientation.
% The |'grainId'| option groups voxels with the same stored grain identifier
% in both 2D and 3D. Use it to compare a vendor's segmentation with a
% reconstruction made in MTEX.
%
% Voxel boundaries have a staircase shape. <grain3d.reduceBoundary.html
% |reduceBoundary|> coarsens the mesh and <grain3d.smoothBoundary.html
% |smoothBoundary|> smooths it using the filters available for 2D grains.
% Quadruple points, triple lines and the outer specimen surface remain fixed:
%
%   grains = smoothBoundary(reduceBoundary(grains,2,'quadric'),taubinFilter(20))
%
% <grain3Boundary.edges.html |edges|> and <grain3Boundary.nodeType.html
% |nodeType|> identify triple lines and quadruple points in the boundary
% network. <grain3Boundary.calcGBND.html |calcGBND|> computes the grain
% boundary plane distribution.
%
% Display a volume with <EBSD3.plot.html |plot|> and extract a section with
% <EBSD3.slice.html |slice|>. The section is a 2D EBSD map viewed along the
% normal to the cutting plane:
%
%   ebsd = mtexdata('xnovo')
%   plot(slice(ebsd,plane3d(vector3d(1,1,1),vector3d(0,0,0))))
%
% See <EBSD3Analysis.html Three-Dimensional EBSD Analysis> for the chapter,
% and <Grains3DReconstruction.html Grain Reconstruction>,
% <Grains3DSmoothing.html Smoothing>, <Grains3DBoundaries.html Boundary
% Network> and <EBSD3Plotting.html Volume Data and Slices> for the pages.
%
% *Total variation denoising with a smoothing length*
%
% The half-quadratic filter is now called <l1TVFilter.l1TVFilter.html
% |l1TVFilter|>. |halfQuadraticFilter| remains available and reports the
% name change. Set the smoothing length with |l1TVFilter(L)|: variations
% with wavelength L are reduced to half their amplitude. The default is
% four pixel spacings. MTEX derives |alpha| from this length and the grid.
%
% The smoothing length has the same meaning for coarse and fine maps,
% square and hexagonal grids, and the Python and Julia ports. If you set
% |alpha| manually, it now specifies the regularization weight. To reproduce
% an old value, multiply it by 1.25 for a square grid or 0.83 for a hexagonal
% grid. The default regularization weight is 2.5 times smaller than before,
% so the default smooths less. The stopping tolerance is 0.001 degree.
%
% The former total variation algorithm (cyclic proximal point) remains as
% |F.method = 'proximal'| and minimizes the same objective. Both algorithms
% operate on quaternion arrays and are several times faster.
%
% *Corrections to analysis results and data handling*
%
% * pole densities calculated from a fibre ODF now account for both crystal
% and specimen symmetry. Previously, a
% <SO3FunCBF.SO3FunCBF.html |SO3FunCBF|> with crystal symmetry 321 and
% specimen symmetry 222 produced densities seven times too large
% * <equispacedSO3Grid.html |equispacedSO3Grid|> now accounts for specimen
% symmetry when setting the number of orientations. Previously, it returned
% only a quarter of the requested points for 222 or mmm specimen symmetry,
% and an eighth for a 432/432 misorientation grid. Generating the full set
% requires correspondingly more computation
% * <SO3FunRBF.SO3FunRBF.html |SO3FunRBF|> assigns the correct weight to each
% symmetry-equivalent centre. Previously, all but the first centre received
% another centre's weight
% * the |delta| of a <Gaussian.html |Gaussian|> is the width of
% $\exp(-(x-m)^2/\delta^2)$; the standard deviation is $\delta/\sqrt{2}$
% * non-indexed pixels can now be given a colour with
% |ebsd('notIndexed').color = 'blue'|. Previously, this returned an error
% * |slice| now uses the specified cutting plane. Previously, it always cut
% through the origin. Sections outside the xy plane are displayed face on
% * the <quaternion.angle.html |angle|> of a rotation and its
% <quaternion.log.html |log|> now resolve very small rotations. Previously,
% angles below about 2e-6 degree lost precision, and a 1e-9 degree rotation
% was reported as zero
% * Siemens D5000 pole figure files retain separate neighbouring counts
% when a five-digit count fills its field. Seifert |.nja| imports now include
% the first measurement of each file
% * <embedding.double.html |double|> of an <embedding.embedding.html
% |embedding|> returns coordinates in an orthonormal basis determined by
% the symmetry group. The number of coordinates is unchanged for all Laue
% classes except |mmm|, which now uses 10 instead of 15.
% <embedding.embedding.html |embedding(ori)|> for large orientation lists
% is about twice as fast for cubic and four times as fast for hexagonal symmetry
%
%% MTEX 7.0 08/2026
%
% This is the first release developed with AI assistance and implements
% many long-standing ideas.
%
% *Grain reconstruction*
%
% Grain reconstruction has been rewritten to improve results, speed and
% control over the segmentation. The general syntax is now
%
%   [grains, ebsd] = calcGrains(ebsd,'angle',10*degree,'minPixel',5,'alpha',3.1)
%
% Three parameters tune the reconstruction:
%
% * |'angle'| sets the misorientation threshold between neighbouring pixels
% * |'minPixel'| sets the minimum number of pixels in a grain
% * |'alpha'| sets the closing width, which controls whether small or thin
% |notIndexed| regions are absorbed into surrounding grains
%
% <GrainReconstruction.html Grain Reconstruction> explains the three controls,
% and <GrainReconstructionAdvanced.html Advanced Grain Reconstruction> covers
% the underlying choices. For highly deformed materials, the
% <GrainReconstructionMCL.html fast multiscale clustering method> has also
% been improved.
%
% A method to <EBSDPseudoSymmetry.html clean up pseudosymmetries in EBSD maps>
% is now also available:
%
%   [ebsd,grains] = cleanUpPseudoSym(ebsd,grains,mori,'threshold',1.5)
%
% Grain boundary smoothing has also been improved. Use
%
%   grains = smoothBoundary(grains,5)
%
% The <grain2d.smoothBoundary.html |smoothBoundary|> command offers several
% smoothing methods. See <GrainSmoothing.html Grain Smoothing> and
% <GrainSmoothingAdvanced.html Advanced Grain Smoothing>.
%
% *EBSD import and reference frames*
%
% The EBSD import wizard can now browse data files and adjust reference-frame
% alignment while displaying IPF maps and pole figures. The import conventions
% were revised for formats from Bruker, EDAX, Oxford, EMSphinx and
% Thermo Fisher. The default plotting convention changed to |y↓→x|, the
% convention currently used by these vendors. It can be changed with
%
%   plottingConvention.default('y↑→x');
%
% Multiple data sets per file are now supported, including additional scans
% stored in the same file.
%
% *Imported EBSD maps retain their grid*
%
% <EBSD.load.html |EBSD.load|> now returns an @EBSDsquare or an @EBSDhex when
% measurements lie on a regular square or hexagonal grid. Previously, it
% returned a list that had to be converted with <EBSD.gridify.html |gridify|>.
% Most imported maps are now stored as matrices, and |ebsd(i,j)| selects a
% scan position.
%
% Grid storage changes the order of the measurements. The first matrix
% dimension follows y, whereas |.ctf| and |.ang| files list x positions
% fastest. Therefore, |ebsd(k)| generally no longer corresponds to line k
% in the file. Original identifiers remain in |ebsd.oldId|. See
% <EBSDGrid.html Square and Hex Grids>.
%
% *Faster EBSD and grain map plotting*
%
% Plotting EBSD and grain maps is now orders of magnitude faster. Multiple
% rendering methods support hexagonal and strongly deformed pixel layouts.
% The scale bar now includes a small diagram of the map's reference frame.
%
% *Approximating data, sampling textures and finding clusters*
%
% * the new classes @S2FunMLS and @SO3FunMLS approximate scattered data on the
% sphere and in orientation space by moving least squares
% * <SO3Fun.optimalSample.html |optimalSample|> (formerly |compactify|)
% selects orientations or directions that represent a given distribution
% more evenly than random samples. A second output gives optimized weights,
% allowing the same accuracy with considerably fewer points. The new
% optimization method is roughly ten times faster in orientation space and
% three times faster on the sphere at a given accuracy. The earlier
% gradient descent method remains available as
% |optimalSample(f,n,'method','steepestDescent')|
% * <orientation.calcCluster.html |calcCluster|> supports the
% <https://github.com/nla-group/classix CLASSIX> algorithm. It is much faster
% than hierarchical clustering and does not require a specified number of
% clusters. The planned 7.0 default was CLASSIX for orientations as well as
% directions. The current implementation uses ODF component analysis for
% orientations; select CLASSIX with |'method','classix'|. Directions use
% CLASSIX by default. See
% <ClusterDemo.html Clustering directions and orientations>.
% * <PoleFigure.calcODFIterative.html |calcODFIterative|> reconstructs an ODF
% from pole figure data by adjusting the kernel width iteratively. This
% improves robustness for irregularly sampled data
%
%   sF   = S2FunMLS(nodes,values,'degree',3)
%   ori  = optimalSample(odf,10000)
%   [ori,c] = optimalSample(odf,500)   % optimize the weights, too
%   [c,center] = calcCluster(ori)
%   odf  = calcODFIterative(pf,'halfwidth',5*degree)
%
% *Rotation representations and functions with several outputs*
%
% <RotationRepresentations.html Rotation Representations> compares Rodrigues,
% homochoric and cubochoric vectors. <RotationTangentSpace.html The Tangent
% Space> explains the left and right representations of tangent vectors,
% which describe local changes in rotation. A @SO3TangentVector now stores
% its reference rotation, so you can switch representations without passing
% the orientation separately:
%
%   t = odf.grad(ori); right(t)   % t knows ori, no second argument needed
%
% Functions previously called multivariate are now called
% <SO3FunVectorValued.html vector valued>. They return several values for
% each orientation, and arrays of these functions behave like MATLAB arrays.
%
%% MTEX 6.1 10/2025
%
% MTEX 6.1 improves speed and fixes bugs, with a focus on the compiled MEX
% functions. At startup, MTEX checks that these files are installed and
% downloads missing files from GitHub. If the download fails, for example
% because of antivirus software, MTEX tries to compile them from source.
% The relevant commands are
%
% * |check_mex| checks all MEX files
% * |mex_install| recompiles all MEX files. On Windows, install the free
% MinGW add-on compiler within MATLAB first.
%
% Changes to script syntax:
%
% * |grains.grainSize| has been renamed to |grains.numPixel|
% * the @plottingConvention is now stored in |grains.how2plot| and
% |ebsd.how2plot|. See
% <https://mtex-toolbox.github.io/AxesAlignment.html Axes Alignment>.
% * |how2plot.makeDefault| makes a plotting convention the default for all
% new data.
%
%% MTEX 6.0 10/2024
% MTEX 6.0 adds 3D grain analysis and allows 2D EBSD and grain maps to be
% positioned in three-dimensional space.
%
% *Three-dimensional grain networks*
%
% Import 3D grain networks from <https://neper.info/index.html Neper> or
% <https://dream3d.bluequartz.net DREAM.3D> and analyse their sizes, shapes
% and spatial relationships using tools similar to those for 2D grains.
% See <Grains3DOperations.html 3D grain operations> and
% <Grains3DProperties.html 3D grain properties>.
%
% *Planar EBSD and grain maps in 3D space*
%
% The 2D classes @EBSD, @grain2d and @grainBoundary are no longer restricted
% to the xy plane. For example, maps can represent three faces of a cube.
% The following properties have changed:
%
% * |ebsd.pos| stores the positions of EBSD measurements as
% @vector3d
% * grain vertices |grains.V|, centroids |grains.centroid| and long axes
% |grains.longAxis| are now of type @vector3d
% * |ebsd.N| and |grains.N| give the normal to the map plane
% * maps with different normal directions cannot be merged into one variable
%
% *Plotting maps and pole figures in 3D*
%
% * Plotting of EBSD and grain maps is now possible in 3d
% * The alignment of x, y and z on the screen is now controlled by an
% object of type @plottingConvention. The code
%
%   how2plot = plottingConvention
%   how2plot.outOfScreen = ebsd.N
%   how2plot.east = yvector
%   plot(ebsd, how2plot)
%
% plots an EBSD map with its normal pointing out of the screen and the
% y-vector pointing east.
% * A default plotting convention can be stored directly in the EBSD or
% grain variable via
%
%   ebsd.plottingConvention = how2plot
%
% * The plotting convention can also be passed to any spherical plot. This
% allows e.g. to plot pole figures with an arbitrary direction pointing out
% of the screen.
%
% * |'upper'| and |'lower'| now refer to hemispheres relative to the
% out-of-screen direction
%
% *Neper interface*
%
% Neper is an open source package for generating and meshing 3D
% polycrystals. Call it from MTEX to simulate microstructures, generate
% sections through a volume and import those sections into MTEX. See
% <NeperInterface.html NeperInterface>.
%
% *Other changes*
%
% * new option |'minPixel'| for the command <EBSD.calcGrains.html
% |calcGrains|>, which lets you set a minimum grain size
% * <ipfSections.html |ipfSections|> are a novel way of representing
% orientation space
% * |grains(id).V| now returns only the vertices of the respective grain
% * |dot(vF1,vF2)| computes the inner product between two spherical vector
% fields.
% * the option |'FaceColor'| now lets you <CrystalShapes.html colorize
% crystal shapes according to their orientation>
% * <mtexFigure.drawNow.html |drawNow(gcm,'antiAliased')|> generates anti-aliased images
% * <EBSD.transform2PolarRefernceFrame.html
% |transform2PolarReferenceFrame|> transforms ebsd data into a polar
% reference frame
% * support for area detectors in ODF reconstruction from pole figure data
% * when computing parent EBSD data using
% <parentGrainReconstructor.calcParentEBSD.html |calcParentEBSD|> the
% parent orientation will now be constant within the parent grains. In
% order to retain a fixed orientation relationship (OR) with varying parent
% orientations, use the new option |'exactOR'|.
% * new interface to SHT files
% * new function <stripStar.html |stripStar|>
%

%% MTEX 5.11.0 3/2024
%
% MTEX 5.11 is the last release before MTEX 6.0. It improves grain
% reconstruction from 2D EBSD data.
%
% *Faster grain reconstruction*
%
% Using <https://github.com/JCash/voronoi jc_voronoi> for tessellation,
% together with additional speedups, makes grain reconstruction more than
% 10 times faster than before. The method used for
% Voronoi tessellation is now specified in |mtex_settings| by the option
% |'VoronoiMethod'|. You may want to set this option to |'qhull'| if you
% experience problems with the |'jcvoronoi'| engine.
%
% *Grain reconstruction around non-indexed regions*
%
% With MTEX 5.11 MTEX uses <https://en.wikipedia.org/wiki/Alpha_shape alpha
% shapes> to determine grain shapes in the presence of large |notIndexed|
% regions. A single |'alpha'| parameter controls these alpha shapes. It sets
% the extent to which indexed regions may grow into |notIndexed| regions. See
% <GrainReconstruction.html grain reconstruction> for an illustration of
% the new method.
%
% *Vector fields for modelling texture evolution*
%
% <SO3FunVectorField.html Vector Fields in Orientation Space> now includes
% functions to compute
% <SO3VectorField.div.html the divergence |div(vF)|>,
% <SO3VectorField.curl.html the curl |curl(vF)|> and the
% <SO3VectorFieldHarmonic.antiderivative.html antiderivative> of a vector
% field |vF|. Use these tools to model texture evolution by solving the
% continuity equation, as demonstrated for <SingleSlipModel.html the single
% slip model>. The new command <doEulerStep.html |doEulerStep|> updates an
% ODF or a list of orientations using a vector field that describes their
% rotation, for example from the Taylor model.
%
% *Lankford Parameter*
%
% <orientation.orientation.html |calcLankford|> computes the Lankford
% parameter, or R-value. See <Lankford.html Lankford parameter analysis>.
%
% *Transformation ODF*
%
% <orientation.variants.html |variants(p2c,odfParent)|> now accepts a parent
% ODF as its second input and returns the child ODF, assuming equal
% frequencies for all variants. See <TransformationTexture.html
% Transformation Texture>.
%
% *Inner Planes in Crystal Shapes*
%
% Using the commands <crystalShape.plotInnerFace.html |plotInnerFace|>,
% <crystalShape.plot.html |plot(cS,sS)|> and <vector3d.arrow3d.html
% |arrow3d|> it is now possible to plot internal lattice planes, directions
% or slip systems into the crystal shape. This is explained in more detail
% at <CrystalShapes.html Crystal Shapes>.
%
% *Other improvements and bug fixes*
%
% * new command <SO3Fun.transformReferenceFrame.html
% |transformReferenceFrame(odf,csNew)|>, which switches between
% different setups of the same symmetry, i.e. between 121 and 112.
% * improved h5 interface
% * new function <SO3Fun.cor.html |cor(odf1,odf2)|> to compute the
% correlation between two ODFs.
% * new function <vector3d.lineIntersect.html |lineIntersect|> to compute
% the intersection between a line and a plane.
% * new class <S1FunHarmonics.html |S1Fun|> to represent directional
% properties in the plane.
% * new function <S2Fun.volume.html |volume(S2F,center,radii)|> to compute
% the volume of a spherical function within a ball.
% * replaces |CLim| by <setColorRange.html |setColorRange|>
% * <parentGrainReconstructor.calcParentEBSD.html |calcParentEBSD|>
% computes also the variant and packet ids
% * many bug fixes
%
%% MTEX 5.10.1 9/2023
%
% This is mainly a bug fix release.
%
%% MTEX 5.10.0 5/2023
%
% *Weighted Burgers Vector*
%
% With the function <EBSD.weightedBurgersVec.html |weightedBurgersVec(ebsd)|>
% you can compute the weighted Burgers vector using either the integral or
% the differential approach.
%
% *Bain Group Determination*
%
% The function <calcVariantId.html |calcVariantId|> now returns an id for
% the variant, the packet and the Bain group. The usage of this function is
% demonstrated <MartensiteVariants.html here>.
%
% *Other improvements and bug fixes*
%
% * New option |'max'| to <orientation.angle.html |angle(mori)|> to compute
% the largest misorientation angle. Helpful for identifying twinning.
% * Added checks for symmetry and positive definiteness when defining
% stress, strain and elasticity tensors.
% * Add morphological filter <EBSD.EBSD.html |erode(ebsd)|> as a simple
% method for data cleaning in EBSD maps.
% * Pseudosymmetries like 532 are now natively supported using the syntax
% |crystalSymmetry('532')|
% * |symmetrise(t,'iso')| return the isotropic portion of a tensor
% * <tensor.symmetricDecomposition.html |symmetricDecomposition|> computes
% the symmetric decomposition of a tensor
% * normalize the Taylor factor according to the strain
% * display boundary length as default output
% * better import of h5 files
% * many more fixes and speed improvements
%
%% MTEX 5.9.0 2/2023
%
% *Habit Plane Detection*
%
% MTEX 5.9 includes powerful functions for the determination of predominant
% habit planes and habit plane distributions. For a fully transformed
% microstructure, they are described in
% <https://doi.org/10.1016/j.actamat.2023.119035 Habit plane determination
% from reconstructed parent phase orientation maps>. Those functions include
%
% * new function <grain2d.calcTraces.html |calcTraces(grains)|> and
% <EBSD.calcTraces.html |calcTraces(ebsd)|> to compute habit plane traces
% from families of grains or EBSD data.
% * new function <grainBoundary.calcGBND.html |calcGBND(traces,ori)|> to
% compute the grain boundary normal distribution from a list of habit plane
% traces and the corresponding grain orientations.
% * new function <grainBoundary.characteristicShape.html
% |characteristicShape(gB)|> to compute the characteristic shape from lists
% of grain boundaries
%
% *Orientation-dependent properties*
%
% The orientation distribution function (ODF) describes the distribution of
% crystal orientations in a material, in multiples of a random distribution
% (mrd). Other material properties also depend on orientation. For example,
% the Taylor factor varies with crystal orientation for a given applied
% strain. MTEX now supports these general orientation-dependent functions
% through @SO3Fun, with operations similar to those for spherical functions
% @S2Fun. You can
%
% * add, subtract, multiply and divide with them
% * compare them
% * detect global and local extrema
% * visualize them in 3d and 2d sections
% * compute gradients
%
% ODF operations are also significantly faster. See
% <SO3FunConcept.html Orientation-dependent functions> for details.
%
%
%% MTEX 5.8.2 11/2022
%
% This is mainly a bug fix release. New functionalities include
%
% * <fibre.fit.html |fibre.fit(ori)|> and <fibre.fit.html |fibre.fit(odf)|>
% robustly finds fibers in data sets of individual orientations and ODFs.
% * <fibre.angle.html |angle(f1,f2)|> computes the angle between two
% <OrientationFibre.html fibers>.
% * <S2FunHarmonic.calcSymAxis.html |calcSymAxis(pf)|> finds rotational
% symmetries in <ODFPoleFigure.html pole figures> or arbitrary
% <S2FunConcept.html spherical functions>.
%
%% MTEX 5.8.0 01/2022
%
% MTEX 5.8 improves further on parent grain reconstruction by implementing
% the novel <https://arxiv.org/abs/2201.02103 variant graph algorithm>
% which is faster and more accurate than the previous grain graph algorithm.
%
% *Improved parent grain reconstruction*
%
% Along with the new reconstruction algorithm the following new features
% have been implemented:
%
% * manual interactive parent orientation selection using
% <parentGrainReconstructor.selectInteractive.html |selectInteractive(job)|>
% * new option |'reconsiderAll'| in
% <parentGrainReconstructor.calcGBVotes.html |calcGBVotes(job)| to recheck
% all assignments of parent orientations.
% * new option |'bestFit'| in
% <parentGrainReconstructor.calcGBVotes.html |calcGBVotes(job)| to consider
% only the best fitting neighbor
% * |job.votes| is now a table which contains the parentId votes and the
% probabilities for all grains
%
% *Misc Changes*
%
% * new option |'region'| for <EBSD.plot.html |plot(ebsd)|> to plot only a
% rectangular subregion of the map
%
%% MTEX 5.7.0 05/2021
%
% MTEX 5.7 improves on parent grain reconstruction. Changes include:
%
% *Improved parent grain reconstruction*
%
% * The ordering of the variants is stored within the OR misorientation |p2c|
% as |p2c.variantMap|. In particular the variants in |p2c.variants| are
% ordered by default according to the Morito convention. Check the ordering
% with |round2Miller(p2c.variants)|
% * The command |job.calcGBVotes| and |job.calcTPVotes| compute votes
% associated with probabilities that are stored in |job.votes| and can
% easily be analyzed.
% * The options |'noP2C'| and |'noC2C'| have been replaced by |'p2c'| and
% |'c2c'|.
% * New option |job.useBoundaryMisorienation| which makes the parent grain
% reconstructor to use the misorientations along the grain boundaries
% instead of the misorientations between the grain mean orientations.
% * added ShojiNishiyama orientation relationship.
%
% *Other Changes*
%
% * The command |findByOrientation| accepts a fiber as input.
% * The antipodal |axisAngleColorKey| allows for option |'antipodal'|.
%
%
%% MTEX 5.6.1 03/2021
%
% This is mainly a bug fix release.
%
%% MTEX 5.6.0 01/2021
%
% MTEX 5.6 introduces
% the class <parentGrainReconstructor.parentGrainReconstructor.html
% |parentGrainReconstructor|> to simplify parent grain reconstruction.
% It tracks the correspondence between measured child grains and
% reconstructed parent grains. The following functions recover parent
% orientations and refine the reconstruction. They can be applied repeatedly
% and in any order:
%
% * <parentGrainReconstructor.calcParent2Child.html |calcParent2Child|>
% optimizes the parent-to-child orientation relationship
% * <parentGrainReconstructor.calcGBVotes.html |calcGBVotes|> computes votes
% from child/child and parent/child grain boundaries
% * <parentGrainReconstructor.calcTPVotes.html |calcTPVotes|> computes votes
% from child/child/child triple points
% * <parentGrainReconstructor.calcParentFromVote.html |job.calcParentFromVote|>
% recovers parent orientations from votes
% * <parentGrainReconstructor.calcParentFromGraph.html |job.calcParentFromGraph|>
% recovers parent orientations from graph clusters
% * <parentGrainReconstructor.mergeSimilar.html |job.mergeSimilar|> merges
% similar parent grains
% * <parentGrainReconstructor.mergeInclusions.html |job.mergeInclusions|>
% merges inclusions
% * <parentGrainReconstructor.revert.html |job.revert|> undoes parent grain
% reconstructions
%
% The usage of this new class is demonstrated in <TiBetaReconstruction.html
% Beta Titanium Reconstruction> and <MaParentGrainReconstruction.html
% Parent Martensite Reconstruction>.
%
% *Compatibility fixes*
%
% MTEX 5.6 fixes several incompatibilities with MATLAB versions earlier
% than 2019b.
%
%% MTEX 5.5.0 11/2020
%
% *Orientation Embedding*
%
% Orientation embeddings represent each set of symmetry-equivalent
% orientations by a unique tensor. The distance between these tensors is
% close to the misorientation angle, without the boundary effects of
% Rodrigues vectors. This allows methods for multivariate data to be applied
% to orientations. See <OrientationEmbeddings.html orientation embeddings>
% and the paper
%
% * R. Hielscher, L. Lippert, _Isometric Embeddings of Quotients of the
% Rotation Group Modulo Finite Symmetries_,
% <https://arxiv.org/abs/2007.09664 arXiv:2007.09664>, 2020.
%
% *Low Angle Boundaries*
%
% <EBSD.calcGrains.html |calcGrains|> now accepts separate thresholds for
% grain boundaries and internal low-angle boundaries:
%
%   grains = calcGrains(ebsd,'threshold',[10*degree 1*degree])
%
% This reconstructs grains using a 10-degree threshold and records internal
% boundaries above 1 degree in |grains.innerBoundary|. Use
% <grain2d.subBoundaryLength.html |subBoundaryLength|> and
% <grain2d.subBoundarySize.html |subBoundarySize|> to estimate the amount of
% internal boundary per grain. See <SubGrainBoundaries.html Subgrain
% Boundaries> for the analysis workflow.
%
% *New Functionalities*
%
% * For single phase EBSD maps you can access the orientations now more
% easily by |ebsd.orientations| instead of |ebsd('indexed').orientations|.
% Orientations corresponding to |notIndexed| pixels will be returned as NaN
% and thus automatically ignored during any further computation.
% * <grain2d.isBoundary.html |grains.isBoundary|> identifies grains touching
% the map boundary
% * <grain2d.isInclusion.html |grains.isInclusion|> identifies inclusions
% * <grain2d.merge.html |merge(grains,'inclusions')|> merges inclusions
% into their hosts
% * <grain2d.merge.html |merge(grains,'threshold',delta)|> merges grains
% with a certain misorientation angle
% * interpolation of EBSD maps at arbitrary coordinates by the command
% <EBSD.interp.html |interp|> works now for hexagonal grids as well. In
% particular this lets you remap EBSD data from hexagonal to square grids
% and vice versa. Have a look at the chapter <EBSDInter.html Interpolation>
% for more details.
% * <EBSD.EBSD.html |calcMis2Mean|> computes the misorientation to
% a grain reference orientation, i.e., the <EBSDGROD.html grain reference
% orientation deviation (GROD)>.
% * KAM computation has been sped up significantly for hexagonal and
% square grids. Make sure to use the command |ebsd = ebsd.gridify| before
% the KAM computation.
% * new option |'edgeAlpha'| to control the transparency of grain
% boundaries, e.g. in dependency of the misorientation angle.
% * more easily add new / change phases in an EBSD map by one of the
% following commands
%
%   ebsd(ind).orientations = orientation.byEuler(0,0,0,CSNew)
%   ebsd(ind).CS = CSNew
%
% * new option to plot arrows in spherical plots by
%
%   plot([vector3d.Z, vector3d.Z + 0.5 * vector3d.rand],'arrow')
%
% * <EBSD.export.html |export(ebsd,fileName)|> exports EBSD data to |.ang|,
% |.ctf|, |.crc| and |.hdf5| files, thanks to Azdiar Gazder
% * new function <rotation.fit.html |rot = fit(l,r)|> to compute the
% rotations that best rotates all the vectors |l| onto the vectors |r|
%
% * <orientation.load.html |orientation.load|> and <vector3d.load.html
% |vector3d.load|> now import additional properties.
%
% *Important Bug Fixes*
%
% * <SO3Fun.volume.html |volume(odf)|> gave wrong results in the presence of
% specimen symmetry and for centers close to the boundary of the
% fundamental region.
%
% * <slipSystem.symmetrise.html |slipSystem.symmetrise|> gave
% an incorrect number of slip systems due to a rounding error
%
%% MTEX 5.4.0 7/2020
%
% *Parent Grain Reconstruction*
%
% MTEX now includes functions for variant analysis and reconstruction of
% parent grain structures. Examples include
% <TiBetaReconstruction.html beta phase reconstruction in Titanium> and
% <MaParentGrainReconstruction.html Martensite reconstruction from
% Austenite grains>. The reconstruction uses the
% following new commands
%
% * <calcParent.html |calcParent|> computes the best fitting parent
% orientations from child orientations
% * <parentGrainReconstructor.calcVariants.html |calcChildVariants|> separates child variants
% into packets
% * <calcParent2Child.html |calcParent2Child|> computes best fitting parent
% to child orientation relationship from child to child misorientations
% * <orientation.variants.html |variants|> computes all parent or child variants
%
% *New Functionalities*
%
% * new function <EBSD.interp.html |ebsd.interp|> to interpolate EBSD maps
% at arbitrary x,y coordinates, <EBSDInter.html example>
% * <grain2d.smoothBoundary.html |smoothBoundary(grains)|> keeps now triple points and outer
% boundary fixed by default
% * the field |grains.triplePoints.angles| returns the angles between the
% boundaries at the triple points
% * new option |'removeQuadruplePoints'| to
% <EBSD.calcGrains.html |calcGrains|>
% * harmonic approximation of spherical functions respecting symmetry
% * |export(ebsd,'fileName.ang')| exports to .ang files
% * <grain2d.neighbors.html |neighbours(grains)|> now returns a list of
% pairs of neighboring grains
% * <grain2d.numNeighbors.html |grains.numNeighbours|> returns the number
% of neighboring grains
% * <grainBoundary.selectByGrainId.html |selectByGrainId|> selects
% boundary segments by pairs of grains
% * new helper function <majorityVote.html |majorityVote|>
% * new option |'noAntipodal'| for many commands like |symmetrise|,
% |unique|, |dot|, |angle|
% * new predefined orientation relationship |orientation.Burgers|
%
%% MTEX 5.3.1 6/2020
%
% *New Functions*
%
% * <EBSD.interp.html interp> to interpolate EBSD maps
% * grain properties <grain2d.longAxis.html longAxis>, <grain2d.shortAxis.html shortAxis>
% * <BoundaryCurvature.html grain boundary curvature>
%
% *Bug Fixes*
%
% * loading ang files
% * importing ODFs
% * inverse pole figures misses orientations
% * <grain2d.hull.html convex hull> of grains has now correct boundaries
%
% * Other Changes*
%
% * <vector3d.mean.html vector3d/mean> now returns not normalized vectors
% * new flag |noAntipodal| to suppress antipodal symmetry in calculations
%
%% MTEX 5.3.0 4/2020
%
% MTEX 5.3 speeds up several functions through internal changes. Most
% analysis scripts are unaffected. The @symmetry class is now a handle
% class and no longer derives from @rotation. Scripts that count symmetry
% operations should replace |length(cs)| by |numSym(cs)|.
%
% *Much Better and Faster Halfquadratic Filter*
%
% Denoising of EBSD data using the
% <https://mtex-toolbox.github.io/EBSDDenoising.html
% |halfQuadraticFilter|> is now about 10 times faster, handles outliers
% better and works directly on hexagonal grids.
%
% *New Functions*
%
% * <stiffnessTensor.stiffnessTensor.html |plotWaveVelocities|>
% illustrates anisotropy of seismic waves
% * <EBSD.grainMean.html |grainMean|> grain averages of arbitrary properties
% * shape functions <grain2d.grain2d.html |surfor|>, <grain2d.paror.html
% |paror|>, <grain2d.caliper.html |caliper|>
% * <Miller.multiplicity.html |multiplicity|> for Miller, orientation and
% fiber
%
%% MTEX 5.2.3 11/2019
%
% * replaced |calcODF(ori)| by
% <rotation.calcDensity.html |calcDensity(ori)|>
% * bug fix in ODF reconstruction from XRD data
% * bug fix in EBSD export to ctf
% * bug fix in grain reconstruction
% * some more minor bug fixes
%
%% MTEX 5.2.0 10/2019
%
% *New Documentation*
%
% The new MTEX website provides expanded online documentation with
%
% * a sidebar for quick navigation
% * a search field
% * a complete function reference to all MTEX functions and classes
% * UML diagrams illustrating the hierarchy of the classes
% * much more content
%
% Contributions can include spelling corrections, explanations of theory
% and worked examples. See <Contribute2Doc.html how to contribute to the
% documentation>.
%
% *More Colors*
%
% All plotting commands in MTEX support now much more colors. By default
% all the color names of the CSS palette can be chosen, e.g., aqua,
% orange, gold, goldenrod, etc. To see a full list of supported colors do
%
%  colornames_view
%
% The following function have been included to handle colors more
% efficiently
%
% * <str2rgb.html |str2rgb|> convert color str to RGB color
% * <ind2color.html |ind2color|> convert index to distinct RGB colors,
% good for loops
%
% *Improved Import Wizard*
%
% The EBSD import wizard lets you realign data interactively and check the
% result against pole figures.
%
% *Speed Improvements*
%
% * much faster visualization of the large EBSD maps if <EBSD.gridify.html
% |gridify|> is used
% * faster Fourier transforms on the sphere and the orientation space
% * support for <MOSEK
% https://docs.mosek.com/9.0/toolbox/install-interface.html> as faster
% replacement for linprog from the Optimization Toolbox
%
% *Support for hexagonal EBSD grids*
%
% The function <EBSD.gridify.html |gridify|> now works also for EBSD data
% measured on a hexagonal grid. As a consequence denoising and GND
% computation for those data is also on the way.
%
%
% *Plastic Deformations*
%
% MTEX 5.2 introduces tensor classes for modelling plastic deformation:
%
% * <velocityGradientTensor.velocityGradientTensor.html Velocity Gradient Tensors>
% * <strainRateTensor.strainRateTensor.html strain rate tensor>
% * <deformationGradientTensor.deformationGradientTensor.html deformation gradient tensor>
% * <spinTensor.spinTensor.html spin tensor>
%
% The relationships between those tensors are explained in the section
% <SchmidFactor.html plastic deformations>.
%
%
% *Spherical Bingham Distribution*
%
% Native support for spherical <S2FunBingham.S2FunBingham.html Bingham distributions>,
% including the ability to <S2FunBingham.fit.html fit> them to directional
% distributions.
%
% *Tensors*
%
% * Improved methods for the visualization of elastic properties, see
% <ExSeismicVelocitySingleCrystalDemo2d.html Seismic demo>
% * several new functions like <tensor.trace.html |trace|>,
% <tensor.svd.html |svd|>, <tensor.det.html |det|>, <tensor.colon.html
% double dot product |:|>
% * the function <tensor.mean.html |mean|> computes now Voigt, Reuss, Hill
% and geometric means
%
% *Improved Figure Layout*
%
% * fix layout
% * plot at fixed positions
%
% *Misc Changes*
%
% * export EBSD data to |.ctf|, thanks to Frank Niessen
% * compute the volume of a crystal shape
% * label crystal faces in crystal shapes
% * new function <quaternion.std.html |std|> for computing the standard
% deviation of orientations
% * new function <calcKearnsFactor.html |calcKearnsFactor|>
% * |grainBoundary.ebsdId| is now the id and not the index of the EBSD data
% * index EBSD data and grains by id using |{}| brackets
%
%   ebsd{id}
%   grains{id}
%
% * new options to scatter
%
%   scatter(v,'numbered')               % plot vectors with numbers
%   scatter(v,'MarkerFaceColor','none') % plot vectors with colored empty marks
%
%% MTEX 5.1.0 04/2018
%
% *Dislocation systems*
%
% MTEX 5.1 introduces a class for lists of edge or screw dislocation
% systems. Define them using Burgers vectors and line directions:
%
%   cs = crystalSymmetry('432')
%   b = Miller(1,1,0,cs,'uvw')
%   l = Miller(1,-1,-2,cs,'uvw')
%   dS = dislocationSystem(b,l)
%
% Alternatively, define them from a family of slip systems:
%
%   sS = slipSystem.fcc(cs)
%   dS = dislocationSystem(sS)
%
% Or use a predefined family of dominant dislocation systems:
%
%   dS = dislocationSystem.fcc(cs)
%
% More information how to calculate with dislocation systems can be found
% <dislocationSystem.dislocationSystem.html here>.
%
% *Geometrically necessary dislocations*
%
% Use dislocation systems to estimate geometrically necessary dislocation
% (GND) density from EBSD data. The <GND.html GND> example demonstrates
% the workflow:
%
% # define the dominant <dislocationSystem.dislocationSystem.html
% dislocation systems>
% # transform the dislocation systems into specimen coordinates for each
% pixel of the EBSD map
% # compute the <curvatureTensor.curvatureTensor.html curvature tensor> for
% each pixel in the EBSD map
% # <curvatureTensor.fitDislocationSystems.html fit the dislocation
% systems> to the curvature tensors.
% # compute the total energy in each pixel
%
% *Tensor arithmetics*
%
% <dyad.html |dyad|>, <tensor.trace.html |trace|>, <tensor.det.html
% |det|>, <tensor.mean.html |mean|>, <tensor.diag.html
% |diag|>, <tensor.tensor.html |eye|>, <tensor.sym.html |sym|>
%
% *Birefringence*
%
% MTEX 5.1 adds methods for analysing and simulating optically anisotropic
% materials, including optical axes, birefringence and spectral transmission.
% The new features are
% demonstrated in <BirefringenceDemo.html BirefringenceDemo>.
%
% *Color Keys*
%
% In MTEX 5.1 the color keys used for coloring EBSD have been a bit
% reorganised.
%
% * separate classes for directional color keys. So far these classes are
% <HSVDirectionKey.html |HSVDirectionKey|>, <HKLDirectionKey.html
% |HKLDirectionKey|>, <TSLDirectionKey.html |TSLDirectionKey|>. This has
% become necessary as some orientation color keys depend directional color
% keys with different symmetry.
%
% * new color key <axisAngleColorKey.html |axisAngleColorKey|> that
% implements the coloring described in K. Thomsen, K. Mehnert, P. W. Trimby
% and A. Gholinia: Quaternion-based disorientation coloring of orientation
% maps, Ultramicroscopy, 2017. In central idea is to colorise the
% misorientation axis with respect to the specimen reference frame.
%
% * The existing color keys have been renamed for better consistency. The
% new names are <BungeColorKey.html |BungeColorKey|>, <ipfHSVKey.html
% |ipfHSVKey|>, <ipfHKLKey.html |ipfHKLKey|>, <ipfTSLKey.html |ipfTSLKey|>,
% <ipfSpotKey.html |ipfSpotKey|>, <spotColorKey.html |spotColorKey|>,
% <PatalaColorKey.PatalaColorKey.html |PatalaColorKey|>
%
% *Spherical functions*
%
% * new function <S2Fun.discreteSample.html |discreteSample|> to compute
% random samples from spherical density functions
% * new option to <S2FunHarmonic.symmetrise.html |symmetrise|> to
% symmetrise a spherical function with respect to an axis
%
% *Misc*
%
% * new function <grain2d.fitEllipse.html |fitEllipse|> to assign ellipses
% to grains
% * the functions <tensor.symmetrise.html |symmetrise(tensor)|> and
% <S2FunHarmonic.symmetrise.html |symmetrise(S2F)|> do support
% symmetrisation with respect to a certain axis.
% * the function <quaternion.export.html |export(ori)|> exports
% arbitrary additional properties together with the Euler angles, e.g. the
% half axes and orientation of the grain ellipses
% * the function <loadOrientation_generic.html |loadOrientation_generic|>
% imports arbitrary additional properties together with the
% orientations, e.g., weights
% * new option |logarithmic|
% * new function <SO3Fun.grad.html |grad|> to compute the gradient of an ODF
% at a certain orientation
% * explicitly set the number of rows and columns in a MTEXFigure plot
% * EBSD hdf5 interface works now for Bruker data as well
%
%% MTEX 5.0.0 03/2018
%
% *Compiled functions replace external executables*
%
% Many MTEX calculations use the non-equispaced fast Fourier transform
% (<https://www-user.tu-chemnitz.de/~potts/nfft/ NFFT>). MTEX 5.0 replaces
% external executables, which often caused problems on Mac systems, with
% two compiled MEX functions from the NFFT package. This improves
%
% * compatibility with Mac systems, without disabling System Integrity
% Protection (SIP)
% * increased performance, e.g., due to multi core support
% * better maintainability, as all MTEX code is now MATLAB code
% * the pole figure to ODF inversion algorithm is now entirely implemented
% in MATLAB, making it simple to tweak or add more sophisticated
% inversion algorithms
%
% *Spherical functions*
%
% Many material properties depend on direction, including pole densities,
% wave velocities and distributions of misorientation axes or boundary
% normals. Previously, MTEX calculated these properties only at a supplied
% list of directions. For example,
%
%   pfi = calcPDF(odf,Miller(1,0,0,odf.CS),r)
%
% returns pole figure intensities |pfi| for the ODF |odf| at specimen
% directions |r|. In MTEX 5.0, omit |r| or pass an empty list |[]| to
% obtain a function instead:
%
%   pdf = calcPDF(odf,Miller(1,0,0,odf.CS))
%
% The result is a <S2FunHarmonic.S2FunHarmonic.html spherical function>
% |pdf|, called a pole density function. Evaluate it at any list of specimen
% directions |r| using <S2FunHarmonic.eval.html eval>:
%
%   pfi = pdf.eval(r)
%
% You can also calculate with, plot and analyse spherical functions:
%
%   % compute with spherical functions as with ordinary numbers
%   pdf3 = 5 * pdf1 + 3 * pdf2
%   pdf = max(pdf,0) % replace of negative entries by 0
%   pdf = abs(pdf) % take the absolute value
%   sum(pdf) % the integral of the pole figure
%   sum(pdf.^2) % the integral of the pole figure squares - also called pole figure index
%
%   % plotting
%   plot(pdf)
%   plot3(pdf) % plot in 3d
%
%   % detect maximum value
%   [value,pos] = max(pdf)
%
%   % compute the eigen values and eigen vectors
%   [e,v] = eig(pdf)
%
% For a complete list of functions read <S2FunHarmonic.S2FunHarmonic.html here>.
%
% *Symmetry aware spherical functions*
%
% Many directional properties obey crystal or specimen symmetry.
% <S2FunHarmonic.S2FunHarmonic.html S2FunHarmonic> now has a
% <S2FunHarmonicSym.S2FunHarmonicSym.html S2FunHarmonicSym> variant that
% respects these symmetries.
%
% *Multivariate spherical functions, vector fields and spherical axis fields*
%
% Combine scalar spherical functions to return several values for each
% direction:
%
%   S2Fmulti = [S2F1,S2F2,S2F3]
%
% This function returns three values per direction.
%
% Interpreting the values of |S2Fmulti| as $x$, $y$ and $z$ coordinates gives
% a vector field: one 3D vector for each direction. A common example is the
% gradient of a spherical function:
%
%   g = S2F1.grad
%
% The resulting variable |g| is of type <S2VectorField.S2VectorField.html
% S2VectorField>. A complete list of functions available for vector fields
% can be found  <S2VectorField.S2VectorField.html here>.
%
% Another example for vector fields are polarisation directions |pp|,
% |ps1|, |ps2| as computed by
%
%   [vp,vs1,vs2,pp,ps1,ps2] = velocity(C)
%
% Polarisation directions are antipodal: |d| and |-d| describe the same
% axis. MTEX represents fields with this property as
% <S2AxisFieldHarmonic.S2AxisFieldHarmonic.html AxisField> objects.
%
% *Scalar tensor properties are returned as spherical functions*
%
% Direction-dependent tensor properties now return spherical functions or
% vector fields. Examples include wave velocities, Young's modulus, shear
% modulus and Poisson's ratio. Plot these properties directly:
%
%   plot(C.YoungsModulus)
%
% This makes the old syntax
%
%   plot(C,'plotType','YoungsModulus')
%
% obsolete. It is not supported anymore.
%
% *Crystal shapes*
%
% MTEX 5.0 introduces a new class <crystalShape.crystalShape.html crystalShape>.
% This class lets you plot three-dimensional representations of crystals on
% top of EBSD maps, pole figures and ODF sections. The syntax is as follows
%
%   % define the crystal symmetry
%   cs = loadCIF('quartz');
%
%   % define the faces of the crystal
%   m = Miller({1,0,-1,0},cs);  % hexagonal prism
%   r = Miller({1,0,-1,1},cs);  % positive rhomboedron, usually bigger then z
%   z = Miller({0,1,-1,1},cs);  % negative rhomboedron
%   s2 = Miller({1,1,-2,1},cs); % right tridiagonal bipyramid
%   x2 = Miller({5,1,-6,1},cs); % right positive Trapezohedron
%   N = [m,r,z,s2,x2];
%
%   % define the crystal shape
%   habitus = 1.2; % determines the overall shape
%   extension = [1,1.2,1]; % determines the extension of the crystal in x,y,z direction
%   cS = crystalShape(N,habitus,extension);
%
%   plot(cS)
%   plot(x,y,cS)
%   plot(grains,cS)
%   plot(ebsd,cS)
%   plotPDF(ori,ori*cS)
%
% *ODF component analysis*
%
% MTEX 5.0 allows for decomposing ODF into components using the command
% <SO3Fun.calcComponents.html calcComponents>. In its simplest form
%
%   [mods,weights] = calcComponents(odf)
%
% returns a list of modal orientations |mods| and a list of weights which
% sum up to one. A more advanced call is
%
%   [modes, weights,centerId] = calcComponents(odf,'seed',oriList)
%
% which returns in centerId also for each orientation from |oriList| to
% which component it belongs.
%
% *Clustering of orientations*
%
% The ODF component analysis is used as the new default algorithm in
% <orientation.calcCluster.html calcCluster> for orientations. The idea is
% to compute an ODF out of the orientations and call
% <SO3Fun.calcComponents.html calcComponents> with
%
%   [center,~,centerId] = calcComponents(odf,'seed',ori)
%
% |center| gives the cluster centres and |centerId| assigns each orientation
% to a cluster. The kernel halfwidth used to estimate the ODF controls the
% clustering. Set it with
%
%   [c,center] = calcCluster(ori,'halfwidth',2.5*degree)
%
% *New tensor classes*
%
% With MTEX 5.0 we start introducing specific tensor classes. So far we
% included the following classes
%
% * <stiffnessTensor.stiffnessTensor.html stiffnessTensor>
% * <complianceTensor.complianceTensor.html complianceTensor>
% * <strainTensor.strainTensor.html strainTensor>
% * <stressTensor.stressTensor.html stressTensor>
% * <ChristoffelTensor.ChristoffelTensor.html ChristoffelTensor>
%
% These classes provide tensor-specific operations. For example, inverting
% a compliance tensor returns a stiffness tensor, and vice versa. Further
% tensor classes are planned. Define a stiffness tensor with
%
%   C = stiffnessTensor(M,cs)
%
% instead of the deprecated syntax
%
%   C = tensor(M,cs,'name','elastic stiffness','unit','GPA')
%
% *Improved spherical plotting*
%
% MTEX 5.0 can display both hemispheres in pole figures, inverse pole
% figures and ODF sections. It checks whether the hemispheres are
% symmetry-equivalent and displays both when needed. Control the display
% with |upper|, |lower| and |complete|.
%
% As a consequence the behaviour of MTEX figures have changed slightly. By
% default MTEX now always plots into the last axis. In order to annotate
% orientations or directions to all axes in a figure use the new option
% |add2all|.
%
%  plotIPDF(SantaFe,[xvector,yvector+zvector])
%  [~,ori] = max(SantaFe)
%  plot(ori,'add2all')
%
% We also introduced two new functions <S2Fun.plotSection.html plotSection>
% and <S2Fun.quiverSection.html quiverSection> to visualize spherical
% functions restricted to a plane. As an example one can now plot the
% slowness surfaces of wave velocities in the plane perpendicular to Y
% with
%
%   plotSection(1./vp,vector3d.Y)
%
% see <AnisotropicTheory.html here> for more information.
%
% *Other new functions*
%
% * <SO3Fun.grad.html odf.grad> computes the gradient of an ODF at some
% orientation
% * <grain2d.hist.html grain2d.hist> can now plot histogram of arbitrary
% properties
% * <SO3Fun.fibreVolume.html  |fibreVolume|> works also for specimen symmetry
% * change the length of the scale bar in EBSD plots
%
%% MTEX 4.5.2 11/2017
%
% This is mainly a bug fix release
%
% * some more functions get tab completion for input arguments
% * the option 'MarkerSize' can also be a vector to allow for varying Markersize
% * new option 'noSymmetry' for plotPDF and plotSection
%
% *Orientation relationships*
%
% * new functions for computing variants and parent orientations for a
% given orientation relationship
% * new predefined orientation relationship
%
%   gT = GreningerTrojano(csAlpha,csGamma)
%   ori_children = ori_parent * inv(gT.variants)
%   ori_parents = ori_child * gT.parents
%
%
%% MTEX 4.5.1 08/2017
%
% This is mainly a bug fix release
%
% * some functions get tab completion for input arguments
% * allow different colormaps in one figure
% * updated interfaces
% * added Levi Civita permutation tensor
% * improved round2Miller
% * grains.boundary('phase2','phase1') rearranges the misorientation to be
% from phase2 to phase 1
%
%% MTEX 4.5 03/2017
%
% *3d orientation plots*
%
% MTEX 4.5 supports plotting of orientations, fibres, and ODFs in 3d in
% various projections like
%
% * Bunge Euler angles
% * Rodrigues Frank space
% * axis angles space
%
% *Misorientations*
%
% * MTEX introduces <orientation.round2Miller.html round2Miller> which
% finds pairs of low-index plane normals and crystal directions aligned
% by a given misorientation |mori|
%
% * MTEX includes now some of the important misorientation
% relationships like
%
%   orientation.Bain(cs)
%   orientation.KurdjumovSachs(cs)
%   orientation.NishiyamaWassermann(cs)
%   orientation.Pitch(cs)
%
% *Grain Reconstruction*
%
% New option for EBSD maps with non-convex outlines:
%
%   calcGrains(ebsd,'boundary','tight')
%
% *Grain boundary indexing*
% The command
%   gB('phase1','phase2').misorientation
% now always returns a misorientation from phase1 to phase2
%
% *Tensors*
%
% New functions <tensor.diag.html diag>, <tensor.trace.html trace>,
%
% *EBSD*
%
% Rotating, flipping of EBSD data is now done with respect to the center of
% the map. Previously all these operations where done relatively to the
% point (0,0). Use
%
%   rotate(ebsd,180*degree,'center',[0,0])
%
% to get back the behavior of previous versions.
%
% *Colorbar*
%
% |MTEXColorbar| allows now to have a title next to it. Use
%
%   mtexColorbar('Title','this is a title')
%
% *Bug Fix*
% This release contains several important bug fixes compare to MTEX 4.4.
%
%% MTEX 4.4   01/2017
%
% *Slip Systems*
%
% MTEX 4.4 introduces support for <SlipSystems.html slip systems>. Slip
% systems are defined by a plane normal and a slip direction
%
%   sSFCC = slipSystem(Miller(0,1,-1,cs,'uvw'),Miller(1,1,1,cs,'hkl'));
%
% Slip systems are instrumental for computing the following properties
%
% * <slipSystem.SchmidFactor.html Schmid factor>
% * <TaylorModel.html Taylor factor>
% * <SlipTransmission.html Strain transmission through grain boundaries>
%
% *Fibres*
%
% MTEX 4.4 adds support for fibres in orientation space. As an
% example the alpha fibre in cubic materials can be defined in the
% following ways
%
% * as a predefined fibre
%
%   cs = crystalSymmetry('m-3m')
%   f  = fibre.alpha(cs)
%
% * by a pair of directions
%
%   f = fibre(Miller(1,0,0,cs),vector3d.X)
%
% * by two orientations
%
%   ori1 = orientation('Miller',[0 0 1],[1 1 0],cs);
%   ori2 = orientation('Miller',[1 1 1],[1 1 0],cs);
%
%   f = fibre(ori1,ori2)
%
% * by a list of orientations
%
%   f = fibre.fit([ori1,ori2,mean(ori1,ori2)])
%
% All commands that took a pair of directions to specify a fibre, e.g.,
% <fibreODF.html fibreODF>, <SO3Fun.fibreVolume.html fibreVolume>,
% <SO3Fun.plotFibre.html plotFibre> have been rewritten to accept a fibre as a
% single input argument. I.e. a fibre ODF is now defined by
%
%   odf = fibreODF(fibre.alpha(cs))
%
% Up to now the following functions are implemented for fibres
%
% * plot to Rodrigues space, Euler space, pole figures, inverse pole
% figures
%
%    oR = fundamentalRegion(cs,cs)
%    f = fibre(oR.V(1),oR.V(2))
%    plot(oR)
%    hold on
%    plot(fibre,'color','r','linewidth',2)
%    hold off
%
% * compute the angle between orientation and fibre
%
%   angle(f,ori)
%
% *Ignore Symmetry*
%
% Many functions support now the flag |noSymmetry|. Among them are |angle|,
% |axis|, |dot|, |cunion|.
%
% *Clustering of orientations*
%
% The new command <orientation.calcCluster.html |calcCluster|> clusters a
% given set of orientations into a specified number of clusters.
%
%   % generate orientation clustered around 5 centers
%   cs = crystalSymmetry('m-3m');
%   center = orientation.rand(5,cs);
%   odf = unimodalODF(center,'halfwidth',5*degree)
%   ori = odf.calcOrientations(3000);
%
%   % find the clusters and its centers
%   [c,centerRec] = cluster(ori,'numCluster',5);
%
%   % visualize result
%   oR = fundamentalRegion(cs);
%   plot(oR)
%
%   hold on
%   plot(ori.project2FundamentalRegion,c)
%   caxis([1,5])
%   plot(center.project2FundamentalRegion,'MarkerSize',10,'MarkerFaceColor','k','MarkerEdgeColor','k')
%   plot(centerRec.project2FundamentalRegion,'MarkerSize',10,'MarkerFaceColor','r','MarkerEdgeColor','k')
%   hold off
%
%% MTEX 4.3.2 07/2016
%
% *Alignment of Miller plots*
%
% You can now specify the alignment of the crystal a-axis or b-axis in
% Miller plots by
%
%   plota2north, plota2east, plota2south, plota2west
%   plotb2north, plotb2east, plotb2south, plotb2west
%
% This can also be specified in <matlab:edit mtex_settings.m
% mtex_settings>.
%
%% MTEX 4.3 - 03/2016
%
% *Alignment of Miller plots*
%
% Starting with MTEX 4.3 plots with respect to the crystal coordinate
% system, i.e., inverse pole figure plots, misorientation axis plot, ipf
% keys, are always aligned such that the b-axis points towards east. This
% follows the convention given in the International Table of
% Crystallography. The alignment can be adjusted using the
% option |xAxisAlignment|
%
%   plot(Miller(1,0,0,cs),'xAxisAlignment',30*degree)
%
% *Plotting vector fields at grain centers or grain boundaries*
%
% There are three new commands
%
% * <EBSD.quiver.html quiver(ebsd,dir)>
% * <grain2d.quiver.html quiver(grains,dir)>
% * <grainBoundary.quiver.html quiver(grains.boundary,dir)>
%
% that allow visualizing directions for EBSD data, grains and at grain
% boundaries. The input argument |dir| should be a list of |vector3d| and
% may represent e.g. slip directions, polarization direction, etc.
%
% *EBSD data in raster format*
%
% Until MTEX 4.2 EBSD data have been always considered as a one-dimensional
% list of data, i.e., the often present structure of a regular grid was
% completely ignored. Starting with MTEX 4.3 EBSD data can be converted in
% a regular grid by
%
%   ebsd = ebsd.gridify
%
% Missing data are represented as NaN in the regular representation.
% Gridified EBSD data may be addressed analogously like matrixes, i.e.,
%
%   ebsd(100,200)
%
% will give pixel 100 in the y-direction and 200 in the x-direction. Analogously.
%
%   ebsd(50:100,:)
%
% will give the stripe if pixels with y coordinate between 50 and 100.
%
% *Orientation gradients and GND*
%
% Gridified EBSD data allows also to compute orientation gradients by
%
%   ebsd.gradientX
%   ebsd.gradientY
%
% as well as an estimate of the geometrically necessary dislocation
% density (GND) using the command <EBSD.calcGND.html calcGND>
%
%   ebsd.calcGND
%
% *Auxiliary new functionality*
%
% * grain2d.calcParis - Percentile Average Relative Indented Surface
% * tensor.diag
% * <EBSD.reduce.html reduce> works now also for EBSD data on Hex grids
%
%% MTEX 4.2 - 11/2015
%
% MTEX 4.2 introduces basic functionality for triple-point analysis in grain
% maps.
%
% *Triple points*
%
% Triple points are automatically computed during grain reconstruction and
% can be accessed by
%
%   grains.triplePoints
%   grains.boundary.triplePoints
%
% More details on how to work with triple points can be found
% <TriplePoints.html here>.
%
% *large EBSD data sets*
%
% Large EBSD maps can require substantial memory and take time to plot.
% <EBSD.reduce.html reduce> keeps every n-th pixel along each grid direction:
%
%   ebsd_small = reduce(ebsd,2)
%
% This keeps 25 percent of the original measurements. Use the smaller map
% to explore the data and develop an analysis script, then run the final
% analysis on the full data set where possible.
%
% *New option to ignore symmetry*
%
% When computing the angle between crystal directions, the misorientation
% angle between orientations and the misorientation axis symmetry can be
% ignored with the flag |noSymmetry|
%
%   angle(Miller(1,0,0,cs),Miller(0,1,0,cs),'noSymmetry')
%   angle(mori,'noSymmetry')
%   axis(mori,'noSymmetry')
%
% *Axis distributions in specimen coordinates*
%
% In order to plot axis distributions in specimen coordinates, you can now
% do
%
%   [ori1,ori2] = calcMisorientation(ebsd('phaseName'))
%   plotAxisDistribution(ori1,ori2,'contourf')
%
% or
%
%   ori = ebsd(grains.boundary('indexed').ebsdId).orientations
%   plotAxisDistribution(ori(:,1),ori(:,2),'contourf')
%
% *New option to work around a MATLAB OpenGL bug*
%
% In <matlab:edit mtex_settings.m mtex_settings> there is a new option that
% may help to work around the MATLAB OpenGL bug. Switching it off may give
% nicer graphics.
%
%   setMTEXpref('openglBug',true)
%
% *CSL misorientations*
%
% The function <CSL.html CSL> requires now as a mandatory argument the
% crystal symmetry of the phase, i.e.
%
%   CSL(3,crystalSymmetry('m-3m'))
%
% *Grain boundaries*
%
% Grain boundaries segments have a new option |midPoint| which may be used
% for attaching a vector displaying the misorientation axis or some other
% direction.
%
% *More ODF sections*
%
% * phi1
% * Phi
% * gamma
% * omega
%
% Along with the old syntax, there is now a new syntax that allows for more
% fine control of the ODF sections.
%
%   oS = phi2Sections(odf.CS,odf.SS)
%   oS.phi2 = [ 10*degree, 30*degree, 90*degree ];
%
%   plot(odf,oS)
%
% *Ordering of crystal symmetries*
%
% One can now check whether a crystal symmetry |cs1| is a subgroup of
% crystal symmetry |cs2| by
%
%   cs1 <= cs2
%
% Further, the largest proper subgroup of some crystal symmetry |cs| is now
% accessible by
%
%  cs.properSubGroup
%
%% MTEX 4.1 - 09/2015
%
% MTEX 4.1 extends misorientation analysis to arbitrary combinations of
% crystal symmetries and introduces filters for smoothing EBSD data.
%
% *Smoothing of EBSD Data*
%
% Noise in EBSD orientations affects local misorientation measures such as
% KAM and estimates of GND density. Smooth the orientations with
%
%   ebsd = smooth(ebsd)
%
% This applies the default spline filter. See <EBSDDenoising.html EBSD
% denoising> for a discussion of the available filters. To use another filter:
%
%   F = medianFilter
%   F.numNeighbours = 2 % this way options for the filter can be set
%   ebsd = smooth(ebsd,F)
%
% The command |smooth| can also be used to fill |notIndexed| measurement
% points. This behavior is enabled by the option |fill|
%
%   ebsd = smooth(ebsd,F,'fill')
%
% *Support for antipodal symmetry for misorientations*
%
% For a boundary between grains of the same phase, exchanging the two grains
% changes |mori| to |inv(mori)| but describes the same boundary. MTEX 4.1
% supports this antipodal symmetry for misorientations and misorientation
% distribution functions.
%
%   mori = inv(ori1) * ori2;
%   mori.antipodal = true;
%
%   mdf = calcMDF(odf1,odf2,'antipodal')
%
% Antipodal symmetry affects the asymmetric region in orientation space as
% described below, as well as the distance between misorientations. Boundary
% misorientations between the same phase have set the flag |antipodal| by
% default.
%
% *Asymmetric regions in orientation space*
%
% MTEX 4.1 has now full support of asymmetric regions in orientation space.
% For any combination of crystal symmetries they can be defined by
%
%   oR = fundamentalRegion(cs1,cs2)
%
% and visualized by
%
%   plot(oR)
%
% One can check, whether an orientation is within the fundamental region by
%
%   oR.checkInside(ori)
%
% similarly as for a sphericalRegion. The fundamental region with antipodal
% symmetry is defined by.
%
%   oR = fundamentalRegion(cs1,cs2,'antipodal')
%
% For a fixed rotational angle |omega|, the intersection of the fundamental
% region with the sphere with radius omega gives the fundamental sector for
% the corresponding rotational axes. The axis sector can be computed by
%
%   sR = oR.axisSector(omega)
%
% *Axis and angle distributions*
%
% |plotAxisDistribution| and |plotAngleDistribution| now use the fundamental
% region and work for any combination of crystal symmetries.
%
% The following syntax is obsolete
%
%   plotAxisDistribution(grains.boundary('phase1','phase2'))
%   plotAngleDistribution(grains.boundary('phase1','phase2'))
%   plotAngleDistribution(ebsd)
%
% As replacement use the more verbose syntax
%
%   plotAxisDistribution(grains.boundary('phase1','phase2').misorientation)
%   plotAngleDistribution(grains.boundary('phase1','phase2').misorientation)
%
%   mori = calcMisorientation(ebsd('phase1'),ebsd('phase2'))
%   plotAngleDistribution(mori)
%   plotAxisDistribution(mori)
%
% *Rotational axis in specimen coordinates*
%
% It is now possible to compute the misorientation axis between two
% orientations in the specimen reference frame. This is done by
%
%   axis(ori1,ori2)
%
% To do so with random misorientations from an EBSD data set do
%
%   [ori1,ori2] = calcMisorientation(ebsd('phase1'),ebsd('phase2'))
%   plot(axis(ori1,ori2))
%
% *Axis angle plots*
%
% (Mis)Orientation, ODFs, and MDFs can now be plotted in axis angles
% sections. Those plots respect the fundamental sector depending on the
% misorientation angle and for all combinations of crystal symmetries. The
% angle sections are scaled such that they represent the corresponding
% volume in orientation space. This can be switch off as described below
%
%   plotSection(mori,'axisAngle',55*degree)
%   plotSection(mdf,'axisAngle',(15:10:55)*degree)
%   plotSection(mdf,'axisAngle',(15:10:55)*degree,'volumeScaling',false)
%   plotSection(mdf,'axisAngle',(15:10:55)*degree,'antipodal')
%
% *Replace plotODF by a plotSection*
%
% In most cases, you can replace |plotODF| by |plot|. For
% misorientations, the default plot is |scattered|.
%
% *More default settings for EBSD maps and pole figure plots*
%
% * new MTEXpref to show/hide the micronbar in EBSD maps. The default is
% set in |mtex_settings.m| to |on|. The following command switches them
% off.
%
%   setMTEXpref('showMicronBar','off')
%
% * new MTEXpref to show/hide the coordinates in EBSD maps. The default is
% set in |mtex_settings.m| to |off|. The following command switches them
% on.
%
%   setMTEXpref('showCoordinates','off')
%
% * new MTEXpref to display coordinates in pole figure plot. The default is
% set in |mtex_settings.m| to display the directions |X| and |Y|. The
% following command switches it to |RD| and |ND|.
%
%   pfAnnotations = @(varargin) text([vector3d.X,vector3d.Y],{'RD','ND'},...
%    'BackgroundColor','w','tag','axesLabels',varargin{:});
%   setMTEXpref('pfAnnotations',pfAnnotations);
%
% *Other improvements since MTEX 4.0.0*
%
% During the minor revisions of MTEX also several minor improvements have
% been added which are summarized below
%
% * check for inclusions in grains: the following command returns a list of
% true/false depending whether a grain in |grainList| is an inclusion in
% |hostGrain|
%
%   hostGrain.checkInside(grainList)
%
% * allow syntax
%
%   plot(odf,pf.h,'superposition',pf.c)
%
% * show or hide the scale bar with the MTEX menu or with
%
%   [~,mP] = plot(ebsd)
%   mP.micronBar.visible = 'off'
%
% * place labels above or below a marker with
%
%   plot(xvector,'label','RD','textAboveMarker')
%
% * new EBSD interface to ACOM Nanomegas *.ang files
%
% * plots relative to the crystal frame are now always aligned
% such that x points to the east and y points to north
%
% * misorientation axis with respect to crystal and specimen reference
% frame
%
%   a = axis(o1,o2)  % misorientation axis in the specimen frame
%
%   a = axis(inv(o2)*o1)  % misorientation axis in the crystal frame
%
% * new function |intersect| to compute intersections between grain
% boundary segments an a line
%
%   [x,y] = grains.boundary.intersect(xy1,xy2);
%
% * option for plotting angle distributions in percent
%
%   plotAngleDsitribution(mori,'percent')
%
% * reintroduced min/max in pole figure like plot
%
%   plot(pf,'minmax')
%
% * 3d plots of pole figures can now be simultaneously rotated
% * you can now restrict an EBSD data set to a line to plot profiles
%
%   ebsd_prof = ebsd.spatialProfile(ebsd,some_line)
%
% * additional syntax to define a list if Miller indices
%
%   h = Miller({1,0,0},{1,1,1},{2,3,4},CS,'uvw')
%
% * interface to Bruker phl files
% * new properties for grainBoundary |gB|
%
%   gB.segmentLength % length of the corresponding connected segment
%   gB.isTwinning(mori,threshold) % check boundary for twinning
%
% * for a crystal symmetry |cs| you can access a, b ,c and reciprocal axes
% by
%
%   cs.Aaxis
%   cs.AaxisRec
%
% * compute KAM with misorientation angle threshold or grain boundary threshold
%
%
%% MTEX 4.0.0 - 10/2014
%
% MTEX 4 rewrites the internal class system for compatibility with newer
% MATLAB releases. MTEX 3.5 does not work with MATLAB versions later than
% R2014a. The new syntax is more consistent, but scripts written for MTEX
% 3.5 need changes. Two general rules apply:
%
% *Use dot indexing instead of getting and setting methods*
%
% The syntax
%
%   h = get(m,'h')
%   m = set(m,'h',h+1)
%
% is obsolete. |set| and |get| methods are no longer supported by any MTEX
% class. Instead use dot indexing
%
%   h = m.h
%   m.h = h + 1
%
% Note, that this syntax can be nested, i.e., one can write
%
%   ebsd('Forsterite').orientations.angle
%
% to get the rotational angle of all Forsterite orientations, or,
%
%   cs.axes(1).x
%
% to get the x coordinate of the a-axis. TAB completion now lists the
% available properties and methods of a class.
%
% *Use camelCaseCommands instead of under_score_commands*
%
% Formerly, MTEX used different naming conventions for functions. Starting
% with MTEX 4.0 all function names consisting of several words, have the
% first word spelled with lowercase letters and the consecutive words
% starting with a capital letter. Most notable changes are
%  * |plotPDF|
%  * |plotIPDF|
%  * |plotODF|
%  * |calcError|
%
% *Grain boundaries are now directly accessible*
%
% MTEX 4.0 introduces a variable type called |grainBoundary|. It represents
% arbitrary grain boundaries and supports operations analogous to those for
% grains. The following lines give some examples. Much more is possible.
%
%   % select boundary from specific grains
%   grains.boundary
%
%   % select boundary by phase transition
%   gB = grains.boundary('Forsterite','Enstatite')
%
%   % select boundary by misorientation angle
%   gB(gB.misorientation.angle>100*degree)
%
%   % compute misorientation angle distribution for specific grain boundaries
%   plotAngleDistribution(gB)
%
% *Plotting EBSD, grain, grainBoundary data has different syntax*
%
% The syntax of the plot commands has made more consistent throughout MTEX.
% It is now
%
%   plot(obj,data)
%
% where obj is the object to be plotted, i.e., EBSD data, grains,
% grain boundaries, spherical vectors, pole figures, etc., and the data are
% either pure numbers or RGB values describing the color. Examples are
%
%   % plot MAD values of EBSD data
%   plot(ebsd,ebsd.mad)
%
%   % colorize grains according to area
%   plot(grains,grains.area)
%
%   % colorize grain boundary according to misorientation angle
%   gB = grains.boundary('Forsterite','Enstatite')
%   plot(gB,gB.misorientation.angle)
%
% Colorization according to phase or phase transition is the new default
% when calling |plot| without data argument, i.e., the following results in
% a phase plot
%
%   plot(ebsd)
%
% In order to colorize ebsd data according to orientations, one has first to
% define an orientationMapping by
%
%   oM = ipdfHSVOrientationMapping(ebsd('Forsterite'))
%
% Then one can use the command |oM.orientation2color| to compute RGB values
% for the orientations
%
%   plot(ebsd('Forsterite'),oM.orientation2color(ebsd('Forsterite').orientations))
%
% The orientation mapping can be visualized by
%
%   plot(oM)
%
% *EBSD data are always spatially indexed*
%
% Starting with MTEX 4.0 EBSD data always have to have x and y coordinates.
% EBSD data without spatial coordinates are imported simply as orientations.
% As a consequence, all orientation related functionalities of EBSD data
% have been moved to |orientations|, i.e., you can not do anymore
%
%   plotpdf(ebsd('Fo'),Miller(1,0,0,CS))
%   calcODF(ebsd('Fo'))
%   volume((ebsd('Fo'))
%
% But instead you have to explicitly state that you operate on the
% orientations, i.e.
%
%   plotpdf(ebsd('Fo').orientations,Miller(1,0,0,ebsd('Fo').CS))
%   calcODF(ebsd('Fo').orientations)
%   volume((ebsd('Fo').orientations)
%
% The same functions can be applied to grain mean orientations
% |grains.meanOrientation|, misorientations relative to the grain mean
% |ebsd.mis2mean|, or boundary misorientations
% |grains.boundary.misorientation|.
%
% *Different syntax for reconstructing grains from EBSD data*
%
% In MTEX 3.5 the command
%
%   grains = calcGrains(ebsd)
%
% duplicates the ebsd data into the grain variable allowing to access the
% EBSD data belonging to a specific grain by
%
%   get(grains(1),'EBSD')
%
% In MTEX 4.0 the command |calcGrains| returns as an additional output the
% list of grainIds that is associated with the EBSD data. When storing
% these grainIds directly inside the EBSD data, i.e., by
%
%   [grains,ebsd.grainId] calcGrains(ebsd)
%
% one can access the EBSD data belonging to a specific grain by the command
%
%   ebsd(grains(1))
%
% *MTEX 4.0 distinguishes between crystal and specimen symmetry*
%
% In MTEX 4.0 two new variable types |specimenSymmetry| and
% |crystalSymmetry| have been introduced to distinguish clearly between
% these two types of symmetry. Calling
%
%   cs = symmetry('m-3m')
%   ss = symmetry('triclinic')
%
% is not allowed anymore! Please use instead
%
%   cs = crystalSymmetry('m-3m','mineral','phaseName')
%   ss = specimenSymmetry('triclinic')
%
% *Pole figure indexing is now analogously to EBSD data*
%
% You can now index pole figure data by conditions in the same manner as
% EBSD data. E.g. the condition
%
%   condition = pf.r.theta < 80 * degree
%
% is an index to all pole figure data with a polar angle smaller than 80
% degree. To restrict the pole figure variable |pf| to the data write
%
%   pf_restricted = pf(condition)
%
% In the same manner, we can also remove all negative intensities
%
%   condition = pf.intensities < 0
%   pf(condition) = []
%
% In order to address individual pole figures within a array of pole
% figures |pf| use the syntax
%
%   pf('111')
%
% or
%
%   pf(Miller(1,1,1,cs))
%
% The old syntax
%
%   pf(1)
%
% for accessing the first pole figure will not work anymore as it now refers to
% the first pole figure measurement. The direct replacement for the above
% command is
%
%   pf({1})
%
% *MTEX 4.0 supports all 32 point groups*
%
% In MTEX 4.0 it is for the first time possible to calculate with
% reflections and inversions. As a consequence, all 32 point groups are
% supported. This is particularly important when working with
% piezoelectric tensors and symmetries like 4mm. Moreover, MTEX
% distinguishes between the point groups 112, 121, 112 up to -3m1 and -31m.
%
% Care should be taken, when using non-Laue groups for pole figure or EBSD
% data.
%
% *Support for three-digit notation for Miller indices of trigonal
% symmetries*
%
% MTEX 4.0 understands now uvw and UVTW notation for trigonal symmetries.
% The following two commands define the same crystallographic direction,
% namely the a1-axis
%
%   Miller(1,0,0,crystalSymmetry('-3m'),'uvw')
%
%   Miller(2,-1,-1,0,crystalSymmetry('-3m'),'UVTW')
%
% *Improved graphics*
%
% MTEX can now display colorbars next to pole figure, tensor or ODF plots
% and offers much more powerful options to customize the plots with titles,
% legends, etc.
%
% *Functionality that has been (temporarily) removed*
%
% This can be seen as a todo list.
%
% * 3d EBSD data handling + 3d grains
% * some grain functions like aspectRatio, equivalent diameter
% * logarithmic scaling of plots
% * 3d plot of ODFs
% * some of the orientation color maps
% * fibreVolume in the presence of specimen symmetry
% * Dirichlet kernel
% * patala colorcoding for some symmetry groups
% * v.x = 0
% * misorientation analysis is not yet complete
% * some colormaps, e.g. blue2red switched
% * histogram of volume fractions of CSL boundaries
% * remove id from EBSD?
% * changing the phase of a grain should change phases in the boundary
% * KAM and GOSS may be improved
% * write import wizard for orientations, vectors, tensors.
%
%% MTEX 3.5.0 - 12/2013
%
% *Misorientation colorcoding*
%
% * Patala colormap for misorientations
% * publication:  S. Patala, J. K. Mason, and C. A. Schuh, Improved
% representations of misorientation information for grain boundary,
% science, and engineering, Prog. Mater. Sci., vol. 57, no. 8, pp. 1383-1425, 2012.
% * implementation: Oliver Johnson
% * syntax:
%
%   plotBoundary(grains('Fo'),'property','misorientation','colorcoding','patala')
%
% *Fast multiscale clustering (FMC) method for grain reconstruction*
%
% * grain reconstruction algorithm for highly deformed materials without
% sharp grain boundaries
% * publication: C. McMahon, B. Soe, A. Loeb, A. Vemulkar, M. Ferry,
% L. Bassman, Boundary identification in EBSD data with a generalization of
% fast multiscale clustering, Ultramicroscopy, 2013, 133:16-25.
% * implementation: Andrew Loeb
% * syntax:
%
%   grains = calcGrains(ebsd,'FMC')
%
% *Misc changes*
%
% * one can now access the grain id by
%
%   get(grains,'id')
%
% * the flags |'north'| and |'south'| are obsolete and have been replaced
% by |'upper'| and |'lower'|
% * you can specify the outer boundary for grain reconstruction in
% non-convex EBSD data set by the option |'boundary'|
%
%   poly = [ [x1,y1];[x2,y2];[xn,yn];[x1,y1] ]
%   grains = calcGrains(ebsd,'boundary',poly)
%
% * you can select a polygon interactively with the mouse using the command
%
%   poly = selectPolygon
%
% *Bug fixes*
%
% * .osc, .rw1 interfaces improved
% * .ang, .ctf interfaces give a warning if called without one of the
% options |convertSpatial2EulerReferenceFrame| or
% |convertEuler2SpatialReferenceFrame|
% * fixed: entropy should never be imaginary
% * removed function |SO3Grid/union|
% * improved MTEX startup
% * many other bug fixes
% * MTEX-3.5.0 should be compatible with MATLAB 2008a
%
%% MTEX 3.4.2 - 06/2013
%
% *bugfix release*
%
% * fixed some inverse pole figure color codings
% * option south is working again in pole figure plots
% * geometric mean in tensor averaging, thanks to Julian Mecklenburgh
% * improved support of osc EBSD format
% * tensor symmetry check error can be turned of and has a more detailed
% error message
% * improved syntax for Miller
%   Miller(x,y,z,'xyz',CS)
%   Miller('polar',theta,rho,CS)
% * ensure same marker size in EBSD pole figure plots
% * allow plotting Schmid factor for grains and EBSD data
% * annotate Miller indices in axis-distribution plots
% * improved figure export
% * allow for negative phase indices in EBSD data
% * bug fix: https://code.google.com/p/mtex/issues/detail?id=115
% * improved ODF fibre plot
%
%% MTEX 3.4.1 - 04/2013
%
% *bugfix release*
%
% * much improved graphics export to png and jpg files
% * improved import wizard
% * Miller(2,0,0) is now different from Miller(1,0,0)
% * new EBSD interfaces h5, Bruker, Dream3d
% * various speedups
% * fix: startup error http://code.google.com/p/mtex/issues/detail?id=99
% * fix: Rigaku csv interface
%
%% MTEX 3.4.0 - 03/2013
%
% *New plotting engine*
%
% MTEX 3.4 features a completely rewritten plotting engine. New features
% include
%
% * The alignment of the axes in the plot is now described by the options
% |xAxisDirection| which can be |north|, |west|, |south|, or |east|, and
% |zAxisDirection| which can be |outOfPlane| or |intoPlane|. Accordingly,
% there are now the commands
%
%   plotzOutOfPlane, plotzIntoPlane
%
% * The alignment of the axes can be changed interactively using the new
% MTEX menu which is located in the menubar of each figure.
% * northern and southern hemisphere are now separate axes that can be
% stacked arbitrarily and are marked as north and south.
% * Arbitrary plots can be combined in one figure. The syntax is
%
%   ax = subplot(2,2,1)
%   plot(ax,xvector)
%
% * One can now arbitrarily switch between scatter, contour and smooth
% plots for any data. E.g. instead of a scatter plot the following command
% generates now a filled contour plot
%
%   plotpdf(ebsd,Miller(1,0,0),'contourf')
%
% * obsolete options: |fliplr|, |flipud|, |gray|,
%
% *Colormap handling*
%
% * User defined colormap can now be stored in the folder |colormaps|, e.g.
% as |red2blueColorMap.m| and can set interactively from the MTEX menu or
% by the command
%
%   mtexColorMap red2blue
%
% *ODF*
%
% * The default ODF plot is now phi2 sections with plain projection and (0,0)
% being at the top left corner. This can be changed interactively in the
% new MTEX menu.
% * The computation of more than one maximum is back. Use the command
%
%   [modes, values] = calcModes(odf,n)
%
% *EBSD data*
%
% * MTEX now recognizes the inconsistent reference frames used in CTF and HKL
% EBSD files for Euler angles and spatial coordinates. The user can convert
% either the spatial coordinates or the Euler angles so that the two become
% consistent. The import wizard or the following commands perform the change:
%
%   % convert spatial coordinates to the Euler-angle reference frame
%   loadEBSD('filename','convertSpatial2EulerReferenceFrame')
%
%   % convert Euler angles to the spatial reference frame
%   loadEBSD('filename','convertEuler2SpatialReferenceFrame')
%
% * It is now possible to store a color within the variable describing a
%  certain mineral. This makes phase plots of EBSD data and grains more
%  consistent and customizable.
%
%   CS = symmetry('cubic','mineral','Mg','color','red')
%
% * A better rule of thumb for the kernel width when computing an ODF from
% individual orientations via kernel density estimation.
% * inpolygon can be called as
%
%   inpolygon(ebsd,[xmin ymin xmax ymax])
%
% *Tensors*
%
% * new command to compute the Schmid tensor
%
%   R = SchmidTensor(m,n)
%
% * new command to compute Schmid factor and active slip system
%
%   [tauMax,mActive,nActive,tau,ind] = calcShearStress(stressTensor,m,n,'symmetrise')
%
% * it is now possible to define a tensor only by its relevant entries.
% Missing entries are filled such that the symmetry properties are
% satisfied.
%
% * faster, more stable tensor implementation
% * new syntax in tensor indexing to be compatible with other MTEX classes.
% For a 4 rank tensor |C|, we have now
%
%   % extract entry 1,1,1,1 in tensor notation
%   C{1,1,1,1}
%
%   % extract entry 1,1 in Voigt notation
%   C{1,1}
%
% * For a list of tensors |C| we have
%
%   % extract the first tensor
%   C(1)
%
% *Import / Export*
%
% * command to export orientations
%
%   export(ori,'fname')
%
% * command to import vector3d
%
%   v = loadVector3d('fname','ColumnNames',{'x','y','z'})
%   v = loadVector3d('fname','ColumnNames',{'latitude','longitude'})
%
% * new interface for DRex
% * new interface for Rigaku
% * new interface for Saclay
%
% *General*
%
% * improved installation / uninstallation
% * new setting system
%
%   setpref('mtex','propertyName','propertyValue')
%
% has been replaced by
%
%   setMTEXpref('propertyName','propertyValue')
%
%
%% MTEX 3.3.2 - 01/2013
%
% *bugfix release*
%
% * fix: better startup when using different MTEX versions
% * fix: backport of the tensor fixes from MTEX 3.4
% * fix: show normal colorbar in ebsd plot if scalar property is plotted
% * fix: http://code.google.com/p/mtex/issues/detail?id=82
% * fix: http://code.google.com/p/mtex/issues/detail?id=76
% * fix: http://code.google.com/p/mtex/issues/detail?id=48
% * fix: http://code.google.com/p/mtex/issues/detail?id=71
% * fix: http://code.google.com/p/mtex/issues/detail?id=70
% * fix: http://code.google.com/p/mtex/issues/detail?id=69
% * fix: http://code.google.com/p/mtex/issues/detail?id=65
% * fix: http://code.google.com/p/mtex/issues/detail?id=68
%
%% MTEX 3.3.1 - 07/2012
%
% *bugfix release*
%
% * fix: single/double convention get sometimes wrong with tensors
% * fix: tensor checks did not respect rounding errors
% * fix: ignorePhase default is now none
% * fix: calcAngleDistribution works with ODF option
% * fix: respect rounding errors when importing pole figures and ODFs
%
%% MTEX 3.3.0 - 06/2012
%
% *Grains: change of internal representation*
%
% Reimplementation of the whole *grain* part:
%
% * The classes @grain, @polygon, @polyeder do not exist any longer. The
% functionality of the classes is mainly replaced by the classes @GrainSet,
% |Grain2d| and |Grain3d|
% * The class @GrainSet explicitly stores @EBSD. To access @EBSD data
% within a single grain or a set of grains use
%
%   get(grains,'EBSD')
%
% * the grain selector tool for spatial grain plots was removed,
% nevertheless, grains still can be <SelectingGrains.html selected
% spatially>.
% * scripts using the old grain engine may not work properly, for more
% details of the functionalities and functioning of the @GrainSet please
% see the documentation.
% * new functionalities: merge grains with certain boundary.
%
% *EBSD*
%
% The behavior of |'ignorePhase'| changed. In this release, the degenerate
% phase was called |'not indexed'|; the current name is |notIndexed|. Such data
% are now <EBSDImport.html imported by default>. If the crystal symmetry of an
% @EBSD phase is set to a string value, it is treated as |notIndexed|. For
% example, this marks the first phase with the historical name:
%
%   CS = {'not indexed',...
%         symmetry('cubic','mineral','Fe'),...
%         symmetry('cubic','mineral','Mg')};
%
% By default, |calcGrains| also uses the |notIndexed| phase.
%
% * create customized orientation colormaps
%
% *Other*
%
% * the command |set_mtex_option| is obsolete. Use the MATLAB command
% |setMTEXpref(...)| instead. Additionally, one can now see all options
% by the command |getpref('mtex')|
%
%% MTEX 3.2.3 - 03/2012
%
% *bugfix release*
%
% * allow zooming for multiplot objects again; change the z-order of axes
% * symmetries allows now options a | | x additional to x | | a
% * fix http://code.google.com/p/mtex/issues/detail?id=35
% * fix http://code.google.com/p/mtex/issues/detail?id=38
% * fix http://code.google.com/p/mtex/issues/detail?id=28
% * fix export odf
%
%% MTEX 3.2.1 - 11/2011
%
% *New Features*
%
% * Import and Export to VPSC
% * export EBSD data with all properties
% * improved ODF calculation from pole figures by using quadrature weights
% for the pole figure grid
% * implemented spherical Voronoi decomposition and computation of
% spherical quadrature weights
% * plot odf-space in omega-sections, the i.e. generalization of sigma-sections
%
% *Bug Fixes*
%
% * S2Grid behaves more like vector3d
% * vector3d/eq takes antipodal symmetry into account
% * Euler angle conversion was sometimes wrong
% * tensors multiplication was sometimes wrong
% * rank 3 tensors get options 'doubleConvention' and 'singleConvention'
% for the conversion into the Voigt matrix representation
% * documentation fixes
% * Miller('[100]') gives not the correct result
% * import wizard now generates correct CS definition
% * import filter for uxd files should now work more reliable
%
%% MTEX 3.2 - 05/2011
%
% *3d EBSD Analysis*
%
% This release for the first time supports 3d EBSD data. In particular,
% MTEX is now able to
%
% * import 3d EBSD data from stacked files
% * visualize 3d EBSD data by plotting interactive slices through the
% specimen
% * 3d grain detection
% * the topology of 3d grains, i.e. boundaries, neighboring grains, etc.
%
% *Misorientation Analysis*
%
% * computation of the uncorrelated misorientation distribution (MDF) for
% one or two ODFs
% * computation of the theoretical angle distribution of an ODF or MDF
% * computation of the misorientation to mean for EBSD data
%
% *New Syntax for EBSD and grain variables*
%
% Select subsets of EBSD or grain data by phase, region, or another grain
% or EBSD variable. For example, select the Fe phase from a two-phase map
% containing Fe and Mg with
%
%  ebsd('Fe')
%
% The same works with grains and also with more than one phase. Please have
% a look into the documentation for information how to index ebsd and grain
% variables.
%
% The following syntax is now deprecated:
%
%  calcODF(ebsd,'phase',2)
%
% It should be replaced by
%
%  calcODF(ebsd('Fe'))
%
%
% *Other Enhancements*
%
% * better import and export of pole figures, odfs and EBSD data
% * automatic centering of a specimen with respect to its specimen symmetry
% * download and import tensors from http://www.materialproperties.org/
% * new interfaces for Rigaku, Siemens, Bruker and many other X-ray devices
% and formats
% * support for rank-three tensors, including piezoelectric tensors
% * improved documentation
% * many bug fixes
%
%% MTEX 3.1 - 03/2011
%
% *Tensor analysis*
%
% MTEX now supports tensor analysis, including
%
% * import of tensors via the import wizard
% * basic tensor operations: multiplication, rotation, inversion
% * advanced visualization
% * computation of averaged tensors from EBSD data and ODFs
% * computation of elastic properties: Young's modulus, linear
% compressibility, the Christoffel tensor and elastic wave velocities
%
% *Other Enhancements*
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
% This release contains a completely redesigned crystal geometry engine
% which is thought to be much more intuitive and flexible. In particular,
% it introduces two new classes <rotation.rotation.html rotation> and
% <orientation.orientation.html orientation> which make it much easier to
% work with crystal orientations. Resulting features are
%
% * no more need for quaternions
% * support for Bunge, Roe, Matthies, Kocks, and Canova Euler angle
% convention
% * a simple definition of fibres
% * simply check whether two orientations are symmetrically equivalent
%
% *Other Enhancements*
%
% * automatic kernel selection in ODF estimation from EBSD data
% * support for Bingham model ODFs
% * estimation of Bingham parameters from EBSD data
% * faster and more accurate EBSD simulation
% * faster grain reconstruction
% * improved documentation
% * improved output
% * MTEX is now compatible with NFFT 3.1.3
%
%
%% MTEX 2.0 - 10/2009
%
% *Grain Analysis for EBSD Data*
%
% MTEX now reconstructs grains from spatial EBSD data. You can calculate
% grain properties and analyse grain boundaries and neighbouring grains.
% Features include:
%
% * Grains statistics (area, diameter, mean orientation, ...)
% * Misorientation analysis
% * Interactive selection of grains by various criteria
% * ODF-calculations for any subset of grains
% * A large palette of plotting possibilities.
%
% *Visualization Improvements*
%
% * ODF fibre plot
% * support for different x-axis alignment - <plotx2north.html
% plotx2north>, <plotx2east.html plotx2east>
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
% * speed improvement of several side-functions as well as core-functions
% of @quaternions and spherical grids.
%
% *Incompatible Changes to Previous Versions*
%
% * The flags *reduced* and *axial* have been replaced by the flag
% <VectorsAxes.html antipodal>
%
%% MTEX 1.2 - 05/2009
%
% *Improved EBSD import*
%
% * import-weighted EBSD (e.g. from odf modeling)
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
% * The flag *reduced* has been replaced by the flag <VectorsAxes.html
% axial>
%
%% MTEX 1.1 - 12/2008
%
% *Improved Import Wizard*
%
% * Load CIF files to specify crystal geometry
% * Import EBSD data with coordinates
% * More options to specify the alignment of the specimen reference frame
% * support for popla *.epf files, *.plf files, and *.nja files
%
%
% *Improved Pole Figure Analysis*
%
% * Background correction and defocusing
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
% * Reference frames for ODF and pole figure plots
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
% *New installer with binaries for Windows, Linux and Mac OS X*
%
% * MTEX now includes an automated installer and binaries for Windows,
% Linux and Mac OS X. You no longer need to install additional libraries
% or compile the toolbox. Thanks to F. Bachmann, C. Randau and F. Wobbe
%
% *New ODF Class*
%
% * The new function <FourierODF.html |FourierODF|> provides an easy way to
% define ODFs via their Fourier coefficients. In particular, MTEX allows now
% to calculate with those ODFs in the same manner as with any other ODFs.
%
% *New Interfaces*
%
% * New PoleFigure interface for xrdml data (F. Bachmann)
%
% *Improved Plotting*
%
% * Plot EBSD data and continuous ODFs into one plot
% * Miller indices and specimen directions can now be plotted directly into
% pole figures or inverse pole figures.
% * New plotting option north, south for spherical plots
% * Improved colorbar handling
% * Spherical grids
% * More spherical projections
%
% *Incompatible Changes With Previous Releases*
%
% * The flag *hemisphere* in <S2Grid.S2Grid.html S2Grid> has been replaced
% by *north*, *south*, and *antipodal* making it more consistent with the
% plotting routine.
%
% *Improved Documentation*
%
% MTEX comes now with over 500 help pages explaining the mathematical
% concepts, the philosophy behind MTEX and the syntax and usage of all 300
% functions available in MTEX. Furthermore, you find numerous examples and
% tutorials on ODF estimation, data import, calculation of texture
% characteristics, ODF and pole figure plotting, etc.
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
% *Speed Improvements*
%
% * ODF reconstruction and PDF calculation are about *10 times faster* now
% (thanks to the new NFFT 4.0 library)
% * ODF plotting and the calculation of <SO3Fun.volume.html volume
% fractions>, the <ODFCharacteristics.html texture index>, the
% <SO3Fun.entropy.html |entropy|> and <SO3Fun.calcFourier.html Fourier
% coefficients> is about *100 times faster*
%
% *New Support of EBSD Data Analysis*
%
% * Import EBSD data from arbitrary data formats.
% * New class <EBSD.EBSD.html EBSD> to store and manipulate with EBSD
% data.
% * Plot pole figures and inverse pole figures from EBSD data.
% * Recover ODFs from EBSD data via kernel density
% estimation.
% * Estimate Fourier coefficients from EBSD data.
% * Simulate EBSD data from ODFs.
% * Export EBSD data.
%
% *New Functions*
%
% * |fibreVolume| calculates the
% volume fraction within a fibre.
% * |plotSpektra| plots the Fourier coefficients of an ODF.
% * |setcolorrange| and the plotting option *colorrange* allow for
% consistent color coding for arbitrary plots.
% * A *colorbar* can be added to any plots.
% * |mat2quat| and |quat2mat| convert rotation matrices to quaternions and
% vice versa.
%
% *Incompatible Changes With Previous Releases*
%
% * New, more flexible syntax for the generation of S2Grids
% * Slightly changed the syntax of |unimodalODF| and |fibreODF|.
% * Default plotting options are set to {}, i.e. 'antipodal' has to add
% manually if desired
% * Crystal symmetry *triclinic* is not called *tricline* anymore.
%
%
%% MTEX 0.3 - 10/2007
%
% * new function |fourier| to calculate the
% Fourier coefficients of an arbitrary ODF
% * new option |ghost correction| in function
% <PoleFigure.calcODF.html calcODF>
% * new option |zero range| in function <PoleFigure.calcODF.html calcODF>
% * new function <EBSD.load.html loadEBSD> to import EBSD data
% * simplified syntax for the import of diffraction data
% * new import wizard for pole figure data
% * support of triclinic crystal <symmetry.symmetry.html symmetry> with
% arbitrary angles between the axes
% * default plotting options may now be specified in mtex_settings.m
% * new plot option _3d_ for a three-dimensional spherical plot of pole
% figures
% * contour levels may be specified explicitly in all plot functions
% plotodf, plotpdf and plotipdf
% * new plot option _logarithmic_
% * many bugfixes
%
%
%% MTEX 0.2 - 07/2007
%
% * new functions <ODFCharacteristics.html texture index>, <SO3Fun.entropy.html
% entropy>, <SO3Fun.volume.html volume>
% * greatly improved help
% * improved installation
% * new options for plotting routines for specific ODF sections
% * many bugfixes
%
%
%% MTEX 0.1 - 03/2007
%
% * initial release
%

%% References
% * MTEX maintainers,
% <https://github.com/mtex-toolbox/mtex/blob/develop/CHANGELOG.md CHANGELOG.md>,
% records issue-level changes, measurements and fixes behind these release
% notes.

%% Next
% <Contribute2Doc.html Contributing to the documentation> explains how to
% propose a correction, add an example and preview the published result.
