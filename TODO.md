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

Major
-----
* twinning class -> which properties?                      (almost done - Phillip)
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

