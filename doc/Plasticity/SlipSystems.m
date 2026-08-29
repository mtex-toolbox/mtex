%% Slip Systems
%
% Crystal slip shears one part of a crystal past another by dislocation
% motion on a lattice plane. A *slip system* specifies the plane and the
% direction of that shear. This page constructs one system, generates its
% symmetry-equivalent family, and assigns strengths to several families.

%% Define one slip system
% A slip system combines a Burgers vector $\mathbf b$, which gives the slip
% direction and displacement, with a slip-plane normal $\mathbf n$.
% The direction must lie in the plane, so $\mathbf b\cdot\mathbf n=0$.
%
% Start with the lattice and crystal frame of hexagonal alpha-titanium.
% The four-index notation used below is introduced with
% <CrystalDirections.html crystal directions>.

cs = crystalSymmetry('622',[3,3,4.7],'x||a', ...
  'mineral','Titanium (Alpha)')

%%
% One first-order prismatic $\langle a\rangle$ system has Burgers vector
% $[2\bar1\bar10]$ and plane normal $(01\bar10)$.

b = Miller(2,-1,-1,0,cs,'UVTW')
n = Miller(0,1,-1,0,cs,'HKIL')

%%
% Passing the two directions to the
% <slipSystem.slipSystem.html |slipSystem|> constructor keeps them together
% as one physical shear mode. The constructor also checks orthogonality.

sSPrismatic = slipSystem(b,n)

%%
% Common families also have named constructors. For example, this creates
% one representative of the basal $\langle11\bar20\rangle\{0001\}$ family.

sSBasal = slipSystem.basal(cs)

%% Draw the plane and direction
% Drawn inside the crystal, the plane shows where the lattice shears and the
% arrow shows the direction of shear. The same plane with another in-plane
% direction is therefore a different slip system.

cS = crystalShape.hex(cs);

plot(cS,'faceAlpha',0.4,'faceColor',[0.7 0.8 0.9])
hold on
plot(cS,sSBasal,'faceColor','red')
hold off

%%
% The red disk is the basal plane. The red arrow lies in that disk, which
% makes the required orthogonality of $\mathbf b$ and $\mathbf n$ visible.

%% Generate the complete family
% A representative does not describe every basal system in a hexagonal
% crystal. Crystal symmetry generates the equivalent systems.
% The option |'antipodal'| identifies opposite Burgers-vector signs, because
% they describe the two shear senses of the same geometric system.

sSBasalSym = sSBasal.symmetrise('antipodal')

%%
% Alpha-titanium has three such basal systems. The norm of each Burgers
% vector is 3 in the lattice units selected in |cs|.

length(sSBasalSym)
sSBasalSym.b.norm

%% Choose families and their CRSS
% For cubic lattices, |slipSystem.fcc(cs)| and |slipSystem.bcc(cs)| provide
% standard sets. Hexagonal lattices deliberately have no |slipSystem.hcp|.
% The active families and their *critical resolved shear stress* (CRSS)
% depend on the material, temperature, and loading rather than on the
% lattice alone. MTEX therefore provides each family separately:
%
%   slipSystem.basal(cs)          <11-20>{0001}
%   slipSystem.prismaticA(cs)     <2-1-10>{01-10}
%   slipSystem.prismatic2A(cs)    <01-10>{2-1-10}     2nd order prismatic
%   slipSystem.pyramidalA(cs)     <2-1-10>{01-11}     1st order pyramidal <a>
%   slipSystem.pyramidalCA(cs)    <2-1-13>{-1101}     1st order pyramidal <c+a>
%   slipSystem.pyramidal2CA(cs)   <2-1-13>{-2112}     2nd order pyramidal <c+a>
%   slipSystem.twinT1(cs)         <1-101>{-1102}      tensile twinning
%   slipSystem.twinT2(cs)         <2-1-16>{-2111}     tensile twinning
%   slipSystem.twinC1(cs)         <-110-2>{-1101}     compressive twinning
%   slipSystem.twinC2(cs)         <2-1-1-3>{2-1-12}   compressive twinning
%
% The second argument sets the CRSS of a family. This illustrative set makes
% the basal systems easiest to activate and makes the families comparable.
% Use values measured for the material and conditions in a real model.

sS = [slipSystem.basal(cs,1), slipSystem.prismatic2A(cs,66), ...
  slipSystem.pyramidalCA(cs,80), slipSystem.twinC1(cs,100)]

%% Deformation and Schmid tensors
% In linearized kinematics, a unit shear on a slip system contributes the
% displacement gradient $\mathbf b\otimes\mathbf n$ after both vectors are
% normalized. Its symmetric part is strain and its antisymmetric part is
% lattice spin. MTEX returns this quantity as the deformation tensor.

L = sSBasal.deformationTensor

%%
% MTEX uses exactly the same normalized dyad as the Schmid tensor. The next
% page contracts it with a stress tensor to obtain resolved shear stress.

S = sSBasal.SchmidTensor

%% Express a system in the specimen frame
% A newly constructed slip system is expressed in the crystal frame.
% An <OrientationDefinition.html orientation> maps the crystal frame into a
% specimen frame. Multiplication applies that map to both $\mathbf b$ and
% $\mathbf n$.

ori = orientation.rand(cs)
sSSpecimen = ori * sSBasal

%#ok<*NASGU>

%% References
%
% * U. F. Kocks, C. N. Tomé and H.-R. Wenk,
% <https://books.google.com/books?id=vkyU9KZBTioC Texture and Anisotropy>,
% Cambridge University Press, 1998, develops slip-system geometry and the
% crystal-plasticity kinematics used here.

%% Next
%
% Continue with <SchmidFactor.html Schmid Factor> to relate the plane and
% direction of each slip system to an applied stress.
