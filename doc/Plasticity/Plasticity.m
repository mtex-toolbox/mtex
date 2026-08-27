%% Plasticity
%
%%
% Past the elastic limit a crystal does not spring back. It deforms by
% sliding: whole blocks of lattice shear over one another along particular
% planes and in particular directions. Which planes and which directions is
% not arbitrary - they are the most densely packed ones, where the atoms
% have least distance to travel - and a plane together with a direction in
% it is called a *slip system*.
%
% This is why plasticity belongs in a texture toolbox. Slip systems are
% fixed in the crystal, so how easily a grain deforms depends on how the
% grain is oriented relative to the load. Deformation is anisotropic for
% the same reason stiffness is, and it feeds back: sliding rotates the
% lattice, so deforming a material changes its texture, which changes how
% it deforms next.
%
% Below is a cubic crystal with its slip planes drawn inside it.

plottingConvention.default('y↑→x');

cs = crystalSymmetry('m-3m','mineral','Aluminium');
cS = crystalShape.cube(cs);
sS = slipSystem.fcc(cs);

plot(cS,'faceAlpha',0.2)
hold on
plot(cS,sS,'faceColor','red')
hold off

%%
% A face-centred cubic metal slips on the {111} planes along <110>
% directions: four planes with three directions in each, so twelve slip
% systems - or twenty-four if the two senses of shear are counted
% separately, which is what |symmetrise| returns.
%
%% Which system slips
%
% A slip system responds only to the part of the applied stress that shears
% it. Resolve the stress onto the slip plane and along the slip direction,
% and the result is the *resolved shear stress*; the factor relating it to
% the applied stress is the *Schmid factor*, which depends purely on
% geometry and ranges from zero to one half.
%
% Schmid's law says slip begins when the resolved shear stress reaches a
% critical value, so the system with the largest Schmid factor goes first.
% This is a good first answer and a poor last one: it treats each grain as
% though it were alone, when in reality a grain is wedged among neighbours
% that constrain it.
%
%% The same bounds as elasticity, for the same reason
%
% Predicting how a polycrystal deforms means deciding what every grain has
% in common. The *Taylor* model assumes all grains undergo the same strain,
% which needs five independent slip systems per grain and generally
% overestimates the strength. The *Sachs* model assumes all grains feel the
% same stress, lets each slip on its best system alone, and underestimates
% it.
%
% These are the same two assumptions that bound elastic averages, in
% plastic dress, and neither is true. Real grains compromise, and the models
% below differ mainly in how they let them.
%
%% Where to start
%
% <SlipSystems.html Slip Systems> defines them for the common structures.
% <SchmidFactor.html Schmid Factor> covers the geometry above and is where
% most single-grain reasoning happens.
%
% Then the polycrystal models. <TaylorModel.html Taylor Model> is the
% equal-strain end, <SingleSlipModel.html Single Slip Model> the
% equal-stress end - it is also where the Sachs model is treated, since the
% physics is the same. <TaylorHex.html Taylor Hex> applies the Taylor model
% to hexagonal metals, where the slip systems have very different strengths
% and the model is more delicate. <SlipTransmission.html Slip Transmission>
% asks whether slip in one grain can continue into its neighbour, which is
% the constraint the models above approximate away.
%
% <DislocationSystems.html Dislocation Systems>, <GND.html GND> and
% <WBV.html WBV> approach the same material from the other side. A gradient
% of orientation inside a grain cannot exist without dislocations of one
% sign left over, so measuring the gradient measures those *geometrically
% necessary* dislocations. This is one of the few places where an
% orientation map yields a defect density directly.
%
% <TextureEvolution.html Texture Evolution> closes the feedback loop
% described at the start, and <Lankford.html Lankford> computes the
% anisotropy coefficient that sheet forming is judged by.
% <VPSCImport.html VPSC> reads results from the widely used
% visco-plastic self-consistent code.
%
%% Next
%
% Deformation that is recovered is <Elasticity.html Elasticity>, and the
% tensors both use are <Tensors.html Tensors>. The orientation changes
% inside grains that GND analysis needs are measured in
% <EBSDAnalysis.html EBSD>. Deformation twinning is a second mechanism
% besides slip and is treated with
% <GrainBoundaries.html Grain Boundaries>.
%
