%% Tensors
%
%%
% A material property is anisotropic when its response depends on direction.
% Heat conduction, elastic stiffness, and refractive index are often
% anisotropic in a crystal, while temperature and density are scalars.
%
% A tensor relates physical quantities whose components may carry directions.
% Its *rank* is the number of indices needed to name one component.
% In three dimensions, a rank $r$ tensor has $3^r$ components before physical
% and crystal symmetries are applied.
% An isotropic property may still be a tensor; isotropy constrains its
% components rather than changing its rank.
%
% Stress and strain are rank two tensors.
% The elastic stiffness that relates them has rank four and therefore starts
% with $3^4=81$ components.
% Read <VectorDefinition.html Vectors> first if components and bases are new.
%
% The example below uses the room-pressure stiffness of San Carlos olivine
% measured by <https://doi.org/10.1029/97JB00682 Abramson et al. (1997)>.
% It plots the Young's modulus of a rod cut along every crystal direction.

plottingConvention.default('y↑→x');

cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],...
  'mineral','Olivine');
C = stiffnessTensor.load(...
  fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa'),cs);

E = C.YoungsModulus;
plot(E,'complete','upper');
mtexColorbar('title','Young''s modulus in GPa');

youngsModulusRange = [min(E),max(E)]

%%
% The printed range is 164.6 to 286.9 GPa.
% In the plot, the red lobes at [100] are the stiffest directions.
% The pale lobes near [010] are the softest, despite their light colour.
%
% Neumann's principle requires every symmetry operation of the crystal point
% group to be a symmetry operation of the physical property.
% The repeated pattern here reflects the three perpendicular mirror planes of
% orthorhombic olivine.
% Stress symmetry, strain symmetry, and elastic energy first reduce the 81
% stiffness components to at most 21 independent coefficients.
% Crystal symmetry reduces these further to nine for an orthorhombic crystal
% and three for a cubic crystal.

%% A tensor is meaningful only with its frame
%
% A reference frame is the coordinate system in which data are expressed.
% It is distinct from the symmetry attached to that frame and from the
% plotting convention that lays the frame out on screen.
% The components of |C| above are expressed in its attached crystal frame.
%
% An active rotation moves a physical property relative to the specimen.
% A frame change instead re-expresses the same physical object in a different
% reference frame and leaves the object itself untouched.
% MTEX provides <tensor.rotate.html |rotate|> for the first operation and
% <tensor.transformReferenceFrame.html |transformReferenceFrame|> for the
% second.
%
% This distinction is especially important for low-symmetry crystals.
% Two sources may use different Cartesian alignments for the same lattice and
% publish different component tables for the same property.
% <CrystalReferenceSystem.html Crystal Reference System> develops this choice.
% Units and compact-matrix conventions must also accompany imported values;
% <TensorImport.html Tensor Import> shows how to audit them.

%% From one crystal to a polycrystal
%
% A specimen contains crystals in different orientations.
% An orientation distribution function (ODF) describes their texture as a
% continuous material-volume density over crystal orientations.
% MTEX uses those orientations to express each single-crystal tensor in the
% specimen frame before averaging.
%
% The effective response also depends on how stress and strain are shared.
% The Voigt estimate assumes uniform strain and averages stiffnesses.
% The Reuss estimate assumes uniform stress and averages compliances before
% inverting the result.
% Under linear elasticity they give upper and lower energy bounds, while the
% Hill estimate is their arithmetic mean.
%
% These estimates do not determine the exact response of a real aggregate.
% Their separation can reflect single-crystal anisotropy, phase stiffness
% contrast, and phase proportions.
% Grain shape, spatial arrangement, porosity, and grain-boundary mechanics are
% absent from both estimates.
% <TensorAverage.html Tensor Averages> develops the assumptions and equations.

%% Where to start
%
% <TensorDefinition.html Definition> introduces tensor rank, component
% symmetries, typed tensor classes, and crystal frames.
% <TensorImport.html Import> reads published coefficients together with their
% unit, frame, and compact-matrix convention.
%
% <TensorArithmetics.html Arithmetics> separates active rotation from a frame
% change and develops the contractions that apply a tensor.
% <TensorVisualisation.html Plotting> develops directional functions and
% specialized tensor plots.
% <TensorAverage.html Averages> combines crystal properties with orientations
% or an ODF.
%
% The worked <PiezoElectricity.html Piezoelectricity> page uses a rank three
% quartz tensor labelled in pC/N.
% <BirefringenceDemo.html Birefringence> uses a rank two refractive-index
% tensor.
% <MagneticAnisotropy.html Magnetic Anisotropy> instead evaluates a quartic
% anisotropy law directly and does not instantiate a tensor.

%% Next
%
% <Elasticity.html Elasticity> continues from stiffness to moduli and wave
% speeds.
% <Plasticity.html Plasticity> covers deformation past the elastic limit.
% <ODFTutorial.html the ODF tutorial> constructs the orientation distribution
% used for aggregate averages.
% The crystal frames tensors use are introduced in
% <CrystalGeometry.html Crystal Geometry>.

%% Further reading
%
% * R.E. Newnham, <https://doi.org/10.1093/oso/9780198520757.001.0001
% Properties of Materials: Anisotropy, Symmetry, Structure>, Oxford University
% Press, 2005, connects tensor rank, symmetry, and crystal properties.
% * A. Authier, editor, <https://doi.org/10.1107/97809553602060000113
% International Tables for Crystallography, Volume D: Physical Properties of
% Crystals>, 2nd ed., IUCr, 2014, develops symmetry constraints on physical
% tensors.
% * D. Mainprice, R. Hielscher, and H. Schaeben,
% <https://doi.org/10.1144/SP360.10 Calculating anisotropic physical properties
% from texture data using the MTEX open-source package>, _Geological Society,
% London, Special Publications_ 360 (2011), 175-192.
% * R. Hill, <https://doi.org/10.1088/0370-1298/65/5/307 The Elastic Behaviour
% of a Crystalline Aggregate>, _Proceedings of the Physical Society A_ 65
% (1952), 349-354, establishes the Voigt and Reuss bounds and discusses their
% mean.
% * <https://www.iso.org/standard/64973.html ISO 80000-2:2019>, _Quantities and
% units - Part 2: Mathematics_, specifies mathematical tensor notation.

%#ok<*NOPTS>
