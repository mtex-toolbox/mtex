TrueEBSD
========

- new class transformation
- transform EBSD / grain2d 
- integrate it better into MTEX


Grain Reconstruction
--------------------
* boundary segment ordering
-----
gB.segments = [1 2 3 4 NaN  4 5 6 NaN 3 2 NaN 10 11 12 13 NaN 34 15 23].'
gB.F
 
gB.segments = [1 2 3 4 -1 -1  4 5 6 -2 -1 3 2 -2 -inf 10 11 12 13 -inf].'
or
gB.segments = [1 2 3 4 NaN  4 5 6 NaN 3 2 -2 NaN 10 11 12 13 NaN 34 15 23].'

* grain boundary smoothing                                 (Vivian)
 - make use of the band contrast

* ebsd = smooth(ebsd)
 - fills pixels with ebsd.orientation == nan

EBSD3d / Grain3d 
----------------
* some shape metrics, fitEllipse                            (done)
* curvature, convex hull
* grainBoundaryCharacter
* characteristicShape
* grain2d/display errors on grains coming out of grain3d.slice - line 63
  calls length(grains.innerBoundary) and the empty innerBoundary has an
  empty phaseId, so phaseList/size indexes phaseId(:,1) out of bounds. This
  breaks doc/EBSD3Analysis/Grains3D.m at both of its slice calls.
* grain3d.orientFaces does not detect cavities, i.e. a grain that completely
  encloses another one. The enclosing surface would have to be oriented
  inwards, instead each closed surface patch is oriented outwards. The case
  is detected and warned about, see tests/check_orientFaces.m.
* the property table in doc/EBSD3Analysis/Grains3DProperties.m already
  advertises four methods that do not exist on grain3d - grain2d has all
  four. The doc links are left dangling on purpose, as a reminder:
  - grain3d.equivalentSurface   (perimeter of a circle with the same area)
  - grain3d.shapeFactor         (perimeter / equivalent perimeter)
  - grain3d.hasHole
  - grain3d.isInclusion

Major
-----
* twinning class -> which properties?                      (almost done - Phillip)
 - doc/CrystalOrientations/DefinitionAsCoordinateTransform.m:71 already lists
   "twinning systems" alongside slipSystem / dislocationSystem and links to a
   twinningSystem class that does not exist yet; the link is left dangling on
   purpose, as a reminder
* discover orientation relationships
 - find matching planes and directions
* improve EBSD h5 interface !!!
* other interfaces, no more checking for format
* gridify EBSD by default
* displacement fields
* add Sachs Model with hardening rules (parallel lsqnonneg)
* Taylor Model with hardening rules
* variant selection in transformation texture
* stereographic methods                                    (in progress)
* boundary density
* better parameters for parent grain reconstruction

Minor
-----
* KAM - provide default filter masks which respect grid resolution 
* axis/angle distribution normalization
* better visualize OR in pole figures
* faster EBSD/smooth (not per grain)
* texture strength index from EBSD data
* packet c2c misorientations

Docu
-----
* weighted Burgers vector
* transformation textures
* calcCluster / calcComponents / max using the phrase "hikers"
* Magnetic anisotropy should use tensors
* SHExtractor

Fixes
-----
* plotSection(mdf,'axisAngle') SEGFAULTS - hard crash, not a MATLAB error.
  Needs both (a) differing left/right symmetry, i.e. a cross phase
  misorientation, and (b) bandwidth >= 32. Reproduced on R2024b:
     ebsd = mtexdata('forsterite'); grains = calcGrains(ebsd);
     mdf = calcDensity(grains.boundary('Fo','En').misorientation,'halfwidth',5*degree);
     mdf.bandwidth = 25;  plotSection(mdf,'axisAngle')   % fine
     mdf.bandwidth = 32;  plotSection(mdf,'axisAngle')   % segmentation violation
  Same phase (Fo->Fo, CS==SS) is fine at bandwidth 25, 32 and 48, so it is the
  combination that matters. Found 2026-07-28 while merging the MDF doc pages;
  the page now plots the axis angle sections of a same phase MDF instead.
* histogram(grains.longAxis) should respect plottingConvention  !!!
* Miller/line 
* SO3FunRBF/rotate -> ask Thom for data 





Grain Reconstruction
--------------------


3D-EBSD and 3d-Grains
-------------------
- visualization
- boundary smoothing
- cubit
- slice, nearest neighbors 

Twinning Class
-------------

- twinning class by Phillip (deformation twin)
- parent twin reconstruction


Docu
----
* inner product of ODF to multiple reference ODFs
* different hexagonal convention put on homepage, care about low symmetry
*

Statistical Testing
--------------------

- between two EBSD set, EBSD <-> ODf
- check whether an EBSD set is sufficiently representative for an ODF


Minor
-----
* subRegions of ODF space
* error analysis of ODF from XRD
* Eshelby inclusion, micromechanics,
* pseudosymmetry correction using OR
* streamline, example from Björn
* GND computation should solve the fitting only approximately
* gB.V
* Yield Locus 
* check you can use everywhere "options" instead of 'options' -> underway
* overlay grain map with active slip system
* plot(ebsd,ebsd.orientation,'ipfDirection',xvector)
* ipfKEy.inversePoleFigureDirection should be outOfplane ???
* colorkey in specimen coordinates should also respect plotting convention ->
  do this by colorKey(what2color) takes the required information from the
  object to color
* circle(ori,radius) should work in pole figures and ODF sections

* option to compute KAM per distance and on rings -> document noise level estimation
* ebsd/smooth should work on gridded data and return gridded data, the
  distinction what to fill and what not to fill should be made according to
  grainId
* findByLocation should use insidepoly
* SchmidFaktor(sS, sigma) should warn if not same reference system


Future
-------
- Mathew Bolan: fit SO3VectorField
- Erik - student ODF compactification
* paper with Vivian about grain reconstruction
* try tranformation texture with convolution
* paper with Dan about improved ODF reconstruction
* KAM, noise estimation, noise floor Ulrich Faul
* GND sample from Ulrich Faul
* make better advertisement


Fixes
-----
* calcComponents give strange results or even crashes on specifying the option
  "angle"
* maybe S1Fun should store a normal direction and a zero direction
* EBSD3.xy2ind, EBSDsquare/gradientX,
EBSDsquare/gradientY,EBSDsquare/gridBoundary, EBSDsquare/interp 

ebsdtest = mtexdata('forsterite')
grains = ebsdtest.calcGrains
plot(grains(grains.isBoundary))
nextAxis
ebsdtest = ebsdtest.gridify
grains = ebsdtest.calcGrains
plot(grains(grains.isBoundary))



* in geometry talk -> lattice directions , lattice normals -> Kikkuchi patter,
  picture from Nolze

------
* sigma colored pole figure
* fix Markersize in sigma sections
* SO3Fun/eval with falscher Symmetry
* mat Kikkushi hochladen
* stable h5 interface
* pseudoSym correction
* optimal transport
* texture heterogenity /estimate local ODF
* boundary density 
* EBSD simulation
* orientation <-> property
* calcGBND for traces
* calcGrains for variantId + parentGrainId
* 


Documentation - empty chapters
------------------------------
These pages are wired into a .toc and therefore publish as a visibly empty
page. Each is a title and nothing else; the sidebar entry is the reminder.
Found by the 2026-07-28 doc audit, see docs/doc-audit-plan.md item 5.

* CrystalOrientations/SpecimenSymmetry            (done 2026-07-28)
* CrystalOrientations/OrientationExport           (done 2026-07-28)
* GeneralConcepts/Properties
* Grains/GrainExport                              (carries a "please help to fill" marker)
* Misorientations/AngleDistributionFunction
* Misorientations/AxisDistributionFunction
* Misorientations/Twinning
* Plasticity/SachsModel
* Plasticity/SlipTransmission                     (note: Plasticity/SlipTransmition.m,
                                                   misspelled, has 52 lines of real
                                                   content and is in no toc - see item 6)
* Plasticity/TextureEvolution
* Plotting/PlottingExport
* PoleFigureAnalysis/PoleFigureExport
* Rotations/RotationExport
* Rotations/RotationImport
* SphericalFunctions/S2FunRadon
* Tutorials/ImportFromVPSC
* Plasticity/TwinningTutorial                     (in no toc, kept as a placeholder)
