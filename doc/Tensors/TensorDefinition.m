%% Defining Tensorial Properties
%
% A material property is anisotropic when its response depends on direction.
% A tensor stores that directional dependence and relates physical quantities.
% For example, elastic stiffness relates strain to stress.
%
% The *rank* of a tensor is the number of indices needed to name one
% component. In three dimensions, a rank $r$ tensor has $3^r$ components
% before physical and crystal symmetries are applied.
% Rank is therefore not the size of a matrix.
%
% MTEX represents every rank with <tensor.tensor.html |tensor|>.
% Physically specific subclasses add units, conventions, and operations.
% Read <VectorDefinition.html Vectors> first if vector components are new.
% <CrystalReferenceSystem.html Crystal Reference System> explains how a
% crystal lattice is attached to Cartesian axes.

plottingConvention.default('y↑→x');

%% Scalars: rank zero
%
% A scalar has no directional index.
% Temperature and density are examples.
% The displayed object confirms that MTEX stores one coefficient at rank zero.

M = 5;
T0 = tensor(M,'rank',0)

%% Vectors: rank one
%
% A vector has one component for each axis of its reference frame.
% The column below contains the components along x, y, and z.

T1 = tensor([1;2;3],'rank',1)

%%
% Rank one tensors and @vector3d objects can be converted into each other.
% The output below is a |vector3d| rather than a |tensor|.

T1x = tensor(vector3d.X);
v = vector3d(T1x)

%% Matrices: rank two
%
% A rank two tensor has two indices and is represented by a $3\times3$
% component matrix. For the stress tensor, one index selects a traction
% component and the other identifies the normal to the plane on which it acts.
%
% $$
% \sigma_{ij} =
% \left[\begin{array}{ccc}
% \sigma_{11} & \sigma_{12} & \sigma_{13} \\
% \sigma_{21} & \sigma_{22} & \sigma_{23} \\
% \sigma_{31} & \sigma_{32} & \sigma_{33}
% \end{array}\right].
% $$
%
% A diagonal rank two tensor has no coupling between different axes.

T2diagonal = tensor(diag([1,2,3]),'rank',2);

%%
% Off-diagonal entries describe coupling between different axes.
% The display reports both the rank and all nine components.

M = [1     0.75  0.5;...
     0.75  1     0.25;...
     0.5   0.25  1];

T2 = tensor(M,'rank',2)

%% Piezoelectricity: rank three
%
% The direct piezoelectric effect relates a rank two stress to a rank one
% electric displacement through a rank three tensor $d$:
%
% $$ D_i = d_{ijk}\,\sigma_{jk}. $$
%
% A general rank three tensor has $3^3=27$ components.
% Since stress is symmetric, $d_{ijk}=d_{ikj}$ and the last two indices can
% be stored as six columns rather than a $3\times3\times3$ array.
%
% The following coefficients are a compact right-handed $\alpha$-quartz example.
% |'DoubleConvention'| says that columns 4 to 6 contain twice the corresponding
% off-diagonal tensor components.

M = [-1.9222  1.9222    0   -0.1423     0         0;...
          0        0     0       0     0.1423    3.8444;...
          0        0     0       0       0         0];

csQuartz = crystalSymmetry('32',[4.916 4.916 5.4054],...
  'X||a','Z||c','mineral','Quartz');

d = tensor(M,csQuartz,'rank',3,'DoubleConvention',...
  'name','piezoelectric strain','unit','pC/N')

%% Elastic stiffness: rank four
%
% Linear elasticity relates the symmetric strain tensor $\varepsilon$ to
% the symmetric stress tensor $\sigma$ through the stiffness tensor $C$.
% The inverse relation uses the compliance tensor $S$:
%
% $$ \sigma_{ij}=C_{ijkl}\,\varepsilon_{kl}, \qquad
%    \varepsilon_{ij}=S_{ijkl}\,\sigma_{kl}. $$
%
% Four indices give $3^4=81$ components before symmetry is considered.
% Symmetric stress and strain reduce the component matrix to $6\times6$.
% An elastic strain-energy function reduces the independent coefficients to
% 21 for triclinic symmetry, and crystal symmetry can reduce them further.
% A cubic stiffness has only $C_{11}$, $C_{12}$, and $C_{44}$ independent.

M = [320   50  50   0   0   0;...
      50  320  50   0   0   0;...
      50   50 320   0   0   0;...
       0    0   0  64   0   0;...
       0    0   0   0  64   0;...
       0    0   0   0   0  64];

csCubic = crystalSymmetry('m-3m');
C = stiffnessTensor(M,csCubic)

%% A tensor needs a reference frame
%
% A reference frame is the coordinate system in which data are expressed.
% It is distinct from symmetry and from the plotting convention that lays the
% frame out on screen.
%
% The crystal symmetries supplied to |d| and |C| also carry crystal frames.
% For |d|, the alignment options state which Cartesian axes the published
% quartz coefficients use.
% Crystal symmetry states the point group under which a property is invariant.
% It is attached to a reference frame but is not the frame itself.
%
% Units and compact-matrix conventions are equally part of the data.
% A plausible component matrix in the wrong frame or convention still gives a
% plausible but physically wrong result.

%% Seeing the cubic symmetry
%
% <stiffnessTensor.YoungsModulus.html |YoungsModulus|> evaluates the tensile
% stiffness of a rod cut along every crystal direction.

E = C.YoungsModulus;
plot(E,'complete','upper');
mtexColorbar('title','Young''s modulus in GPa');

youngsModulusRange = [min(E),max(E)]

%%
% The printed range is 166.6 to 306.5 GPa for this illustrative tensor.
% The plot is stiffest along the cube axes and softest along the body diagonals.
% Its repeated fourfold pattern makes the attached cubic symmetry visible.

%% Physically specific tensor classes
%
% A typed class records what a tensor means and exposes only meaningful
% operations. It may also set a default unit or compact-matrix convention.
%
% || *class* || *rank* || *physical meaning* ||
% || <strainTensor.strainTensor.html |strainTensor|> || 2 || strain $\varepsilon$ ||
% || <stressTensor.stressTensor.html |stressTensor|> || 2 || stress $\sigma$ ||
% || <strainRateTensor.strainRateTensor.html |strainRateTensor|> || 2 || strain rate $E$ ||
% || <velocityGradientTensor.velocityGradientTensor.html |velocityGradientTensor|> || 2 || velocity gradient $L$ ||
% || <deformationGradientTensor.deformationGradientTensor.html |deformationGradientTensor|> || 2 || deformation gradient $F$ ||
% || <spinTensor.spinTensor.html |spinTensor|> || 2 || spin $\Omega$ ||
% || <curvatureTensor.curvatureTensor.html |curvatureTensor|> || 2 || lattice curvature $\kappa$ ||
% || <dislocationDensityTensor.dislocationDensityTensor.html |dislocationDensityTensor|> || 2 || dislocation density $\alpha$ ||
% || <refractiveIndexTensor.refractiveIndexTensor.html |refractiveIndexTensor|> || 2 || refractive index ||
% || <ChristoffelTensor.ChristoffelTensor.html |ChristoffelTensor|> || 2 || elastic wave propagation ||
% || <stiffnessTensor.stiffnessTensor.html |stiffnessTensor|> || 4 || elastic stiffness $C$ ||
% || <complianceTensor.complianceTensor.html |complianceTensor|> || 4 || elastic compliance $S$ ||
%
% <SchmidTensor.html |SchmidTensor|> is a function rather than a class.
% It constructs a rank two velocity-gradient tensor from a slip-plane normal
% and a slip direction.
%
% A component matrix constructs a typed tensor directly.
% The display includes the default Lagrange strain type.

M = [0 0 0;...
     0 0 0;...
     0 0 1];

eps = strainTensor(M)

%%
% Factory methods provide common physical states.
% Here the displayed matrix is a unit uniaxial stress along z.

sigma = stressTensor.uniaxial(vector3d.Z)

%%
% Specialized operations belong to the corresponding class.
% For example, <stressTensor.calcShearStress.html |calcShearStress|> acts on
% a stress tensor and a slip system.

%% Predefined tensors
%
% MTEX provides constructors for arrays of ones, the rank two identity,
% random tensors, and the rank three Levi-Civita tensor.
% Random tensors are useful for numerical experiments, not as material data.

Tones = tensor.ones('rank',2);
I = tensor.eye('rank',2);
Trandom = tensor.rand('rank',2);
leviCivita = tensor.leviCivita;

%%
% The Levi-Civita components are zero when any two indices are equal.
% They are $+1$ for even permutations of $(1,2,3)$ and $-1$ for odd ones.
% This tensor represents the cross product in index notation.

%% The maths behind a change of frame
%
% The component array is a tensor because it obeys a specific transformation
% law. If $Q$ changes an orthonormal basis, a rank $r$ tensor transforms as
%
% $$ T'_{i_1\ldots i_r} =
% Q_{i_1j_1}\cdots Q_{i_rj_r}T_{j_1\ldots j_r}. $$
%
% Repeated indices are summed.
% This law applies the frame change to every index and distinguishes a tensor
% from an arbitrary multidimensional array.
%
% A frame change re-expresses the same physical object in a different
% reference frame and leaves the object itself untouched.
% Rotating a tensor instead moves the physical property relative to the
% specimen.
% <TensorArithmetics.html Tensor Arithmetics> demonstrates both operations and
% the contractions that apply a tensor to vectors or other tensors.

%% Next
%
% Real coefficients usually arrive in a file.
% Continue with <TensorImport.html Tensor Import> for units, crystal frames,
% and Voigt conventions.
% <TensorVisualisation.html Tensor Visualization> develops directional plots,
% while <TensorAverage.html Tensor Averages> combines single-crystal properties
% with orientations or an ODF.
%
% <PiezoElectricity.html Piezoelectricity> continues the rank three example.
% <Elasticity.html Elasticity> develops moduli and seismic wave velocities from
% rank four stiffness tensors.
% The <ODFTutorial.html ODF tutorial> supplies the orientation distribution
% needed for aggregate averages.

%% Further reading
%
% * R.E. Newnham, <https://doi.org/10.1093/oso/9780198520757.001.0001
% Properties of Materials: Anisotropy, Symmetry, Structure>, Oxford University
% Press, 2005, connects tensor rank, crystal symmetry, and physical properties.
% * A. Authier, editor, <https://doi.org/10.1107/97809553602060000113
% International Tables for Crystallography, Volume D: Physical Properties of
% Crystals>, 2nd ed., IUCr, 2014.
% * D. Mainprice, R. Hielscher and H. Schaeben,
% <https://doi.org/10.1144/SP360.10 Calculating anisotropic physical properties
% from texture data using the MTEX open-source package>, Geological Society,
% London, Special Publications 360 (2011), 175-192.
% * H. Ogi et al., <https://doi.org/10.1063/1.2335684 Elastic, anelastic, and
% piezoelectric coefficients of alpha-quartz determined by resonance ultrasound
% spectroscopy>, Journal of Applied Physics 100 (2006), 053511.
% * <https://www.iso.org/standard/64973.html ISO 80000-2:2019>, Quantities and
% units - Part 2: Mathematics, specifies mathematical symbols used for tensors.

%#ok<*NASGU>
%#ok<*NOPTS>
