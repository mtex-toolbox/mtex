%% Tensors
%
%%
% Some properties of a material are the same whichever way you look -
% density, temperature, mass. Most interesting ones are not. Push on a
% crystal along one axis and it stiffens differently than along another;
% light travels through it at a speed that depends on direction; heat and
% electricity flow more easily one way than the next. A *tensor* is the
% object that carries such a direction-dependent property.
%
% The pattern is always the same. A physical law relates two quantities,
% and if both of them have directions then the constant between them must
% carry directions too. Stress and strain are each described by a 3x3
% matrix, so the stiffness relating them needs four indices and 81
% components. The rank of a tensor is simply how many directions it has to
% keep track of.
%
% Below is the stiffness of olivine, drawn as the stiffness a rod cut from
% the crystal would have, in every possible direction.

plottingConvention.default('y↑→x');

cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],'mineral','Olivine');
C = stiffnessTensor.load(fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa'),cs);

plot(C.YoungsModulus,'complete','upper')
mtexColorbar('title','Young''s modulus in GPa')

%%
% Olivine is stiffest along one axis and softest along another, by roughly
% 165 to 287 GPa, and the plot is symmetric about each of the three
% perpendicular mirror planes of an orthorhombic crystal. A tensor must be
% invariant under every symmetry operation of its phase, and that
% requirement is what collapses those 81 stiffness components down to the
% nine independent ones an orthorhombic crystal actually has - and to three
% for a cubic one.
%
%% A tensor is only meaningful with its frame
%
% The numbers in a tensor mean nothing without saying which coordinate axes
% they refer to. The very same physical property has different components
% in the crystal frame and in the specimen frame, and converting between
% them is a rotation applied to every index at once.
%
% This is the single most common source of wrong answers with tensors, and
% it is quiet: components in the wrong frame are still plausible numbers. It
% is worse for low-symmetry crystals, where there is a genuine choice in how
% the crystal axes are laid onto Cartesian ones, so two sources can publish
% correct tensors that disagree - see
% <CrystalReferenceSystem.html Reference System>. MTEX attaches the symmetry
% and its frame to every tensor for exactly this reason.
%
%% From one crystal to a polycrystal
%
% A specimen is not one crystal. To predict how the aggregate behaves you
% need to combine the single-crystal tensor with the distribution of
% orientations - the ODF - and that combination is an *average*.
%
% There is no single right way to do it. Averaging the stiffnesses assumes
% every grain feels the same strain; averaging the compliances assumes every
% grain feels the same stress. Both assumptions are wrong in a real
% material, they bracket the truth from above and below, and the gap between
% them is a genuine statement about how much the answer is not determined by
% texture alone.
%
%% Where to start
%
% <TensorDefinition.html Definition> builds tensors of each rank and
% introduces the specific classes - stress, strain, stiffness and the rest.
% <TensorImport.html Import> reads published tensors from file, which is how
% most real ones arrive.
%
% <TensorArithmetics.html Arithmetics> covers the operations, above all
% rotation into another frame and the contraction that applies a tensor to a
% vector or to another tensor. <TensorVisualisation.html Plotting> makes
% pictures like the one above.
%
% <TensorAverage.html Averages> is the polycrystal step described just now,
% and the page to read before quoting any bulk property.
%
% Three worked properties follow, each a different rank and a different
% physics: <PiezoElectricity.html Piezo Electricity>,
% <BirefringenceDemo.html Birefringence> and
% <MagneticAnisotropy.html Magnetic Anisotropy>.
%
%% Next
%
% Elastic tensors have a chapter of their own,
% <Elasticity.html Elasticity>, including wave speeds.
% <Plasticity.html Plasticity> covers deformation past the elastic limit.
% The orientation distribution the averages need is
% <ODFAnalysis.html ODF>, and the crystal frames tensors live in are
% <CrystalGeometry.html Crystal Geometry>.
%
