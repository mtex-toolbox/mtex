%% Plasticity
%
% Below the elastic limit, removing a load lets a crystal recover its shape.
% Beyond that limit, some deformation remains. Plastic deformation is
% carried mainly by crystal slip and, in suitable materials and loading
% states, by <TwinningTutorial.html deformation twinning>.
%
% Crystal slip moves dislocations so that one part of the lattice shears
% past another on a particular plane and in a particular direction. A plane
% together with an in-plane shear direction is a *slip system*. Densely
% packed planes and directions are often easy slip paths because the atomic
% translation is short, but packing density alone does not define the active
% systems. Their resistance also depends on the material, temperature,
% strain rate, and microstructure.
%
% This is why plasticity belongs in a texture toolbox. Slip systems are
% fixed in the crystal frame, so the response of a grain depends on its
% orientation relative to the load. Plastic deformation is anisotropic for
% the same geometric reason as elasticity. Slip also rotates the lattice,
% so deformation changes the texture and therefore changes the later
% response.

%% See one slip system
% Use one representative of the fcc $\{111\}\langle110\rangle$ family in
% aluminium. The red disk is the slip plane and the arrow in the disk is the
% Burgers vector, which supplies the shear direction.

plottingConvention.default('y↑→x');

cs = crystalSymmetry('m-3m','mineral','Aluminium');
cS = crystalShape.cube(cs);
sS = slipSystem.fcc(cs);

plot(cS,'faceAlpha',0.2)
hold on
plot(cS,sS,'faceColor','red')
hold off

%%
% The arrow lies in the plane, so the direction is perpendicular to the
% plane normal. Crystal symmetry expands this representative into four
% planes with three directions in each. There are twelve geometric systems,
% or twenty-four entries if the two shear senses are stored separately.

sSGeometric = sS.symmetrise('antipodal');
sSSigned = sS.symmetrise;
[length(sSGeometric),length(sSSigned)]

%% Which system slips?
% A slip system responds only to the part of the applied stress that shears
% its plane along its Burgers vector. This component is the *resolved shear
% stress*. The dimensionless *Schmid factor* relates it to a uniaxial applied
% stress, depends only on geometry, and ranges in magnitude from zero to one
% half.
%
% Schmid's law says that slip begins when the resolved shear stress reaches
% the critical resolved shear stress (CRSS). With equal CRSS values, the
% system with the largest suitably signed Schmid factor activates first.
% This is a useful first answer and a poor last one: an isolated-grain
% calculation ignores the neighbours that constrain the grain.

%% Polycrystal bounds
% A polycrystal model must decide what all grains share. The *Taylor model*
% assumes that every grain undergoes the specimen strain. Reproducing a
% general deviatoric strain needs five independent shear systems and usually
% gives an upper bound on strength.
%
% The *Sachs model* makes the opposite assumption. Every grain feels the same
% stress and slips independently on its best system, so compatibility is not
% enforced and the predicted strength is a lower bound. These assumptions
% parallel the uniform-strain and uniform-stress bounds used in elasticity.
% Real grains compromise between them.
%
% The Sachs and single-slip models share an independent-grain premise, but
% they are not the same calculation. Sachs gives a strength bound under a
% common stress. The single-slip texture model follows the lattice rotation
% produced when one prescribed system carries the deformation.

%% Follow the chapter
% Begin with <SlipSystems.html Slip Systems> to construct a plane, Burgers
% vector, symmetry-equivalent family, and CRSS values. Then use
% <SchmidFactor.html Schmid Factor> to resolve a crystal or specimen stress
% and apply the calculation to an EBSD grain map. The parallel
% <TwinningTutorial.html Deformation Twinning> branch explains why a signed
% shear factor needs extra care for a polar twin system.
%
% The polycrystal sequence starts with <TaylorModel.html Taylor Model>, the
% equal-strain limit. <SachsModel.html Sachs Model> then develops the
% equal-stress lower bound. <SingleSlipModel.html Single Slip Model> follows
% the texture evolution of independently slipping crystals, and
% <SlipTransmission.html Slip Transmission> tests whether selected systems
% can carry shear across a boundary between neighbouring grains.

%% Measure dislocation content
% <DislocationSystems.html Dislocation Systems> defines the Burgers vector,
% line direction, tensor basis, and energy weights of edge and screw
% dislocations. <GND.html GND> uses measured orientation gradients to fit
% densities of chosen geometrically necessary dislocation systems.
% <WBV.html WBV> instead estimates a net weighted Burgers vector without
% choosing those systems first.
%
% A gradient of orientation inside a grain requires a geometrically
% necessary dislocation content to preserve compatibility. This provides
% one of the few routes from an orientation map to a defect-density estimate,
% but the result is not a direct or unique measurement. Two-dimensional EBSD
% leaves tensor components unknown, and the inferred densities depend on the
% candidate systems, noise treatment, and energy assumptions.

%% Evolve and summarize a texture
% <VPSCImport.html VPSC> imports texture and slip-activity histories from the
% visco-plastic self-consistent code. <TextureEvolution.html Texture
% Evolution> computes an incremental Taylor history inside MTEX instead.
% <TaylorHex.html Taylor Hex> applies that model to magnesium, where the
% deformation families have unequal and temperature-dependent strengths.
%
% Finally, <Lankford.html Lankford> uses the Taylor model to predict the
% plastic strain ratio of a rolled sheet as the tensile direction changes.
% That page distinguishes the average resistance to thinning from the
% in-plane variation that promotes earing.

%% Related foundations
% Recovered deformation is introduced in <Elasticity.html Elasticity>.
% Both elastic and plastic models use the objects developed in
% <Tensors.html Tensors>. The orientation gradients used for dislocation
% analysis come from <EBSDAnalysis.html EBSD>, while candidate twin
% boundaries are identified in <TwinningBoundaries.html Twinning Analysis>.

% Close the generated figure before the closing sections.
close all

%#ok<*NASGU,*NOPTS>

%% References
%
% * G. I. Taylor, _Plastic Strain in Metals_, _Journal of the Institute of
% Metals_ 62 (1938), 307--324, introduces the equal-strain polycrystal model
% and its minimum-work construction.
% * U. F. Kocks, C. N. Tomé and H.-R. Wenk,
% <https://books.google.com/books?id=vkyU9KZBTioC Texture and Anisotropy>,
% Cambridge University Press, 1998, develops slip-system geometry, the Sachs
% and Taylor bounds, and deformation-induced texture evolution.

%% Next
%
% Continue with <SlipSystems.html Slip Systems> to turn the red plane and
% arrow above into MTEX objects, generate the complete crystallographic
% family, and assign its critical resolved shear stress.
