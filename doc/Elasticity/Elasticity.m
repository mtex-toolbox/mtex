%% Elasticity
%
%%
% Elasticity is the part of deformation a material takes back. Load it,
% and it changes shape; unload it, and it returns. The relationship between
% the load and the shape change is linear for small strains, and the
% constant of proportionality is the stiffness tensor.
%
% In a crystal that constant depends on direction, so an elastic answer is
% never a single number. It also propagates: an elastic disturbance travels
% as a wave, and its speed is set by the same tensor. This is why elasticity
% is the bridge between a laboratory measurement on a crystal and a seismic
% observation of the Earth - the two are the same physics at different
% scales.
%
% Below, the speed of a compressional wave through olivine, in every
% direction.

plottingConvention.default('y↑→x');

cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],'mineral','Olivine');
C = stiffnessTensor.load(fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa'),cs);

% a velocity is a stiffness divided by a density, so the density is required
C = addOption(C,'density',3.355);

% compressional wave velocity over all directions
[vp,~,~] = velocity(C);

plot(vp,'complete','upper')
mtexColorbar('title','v_p in km/s')

%%
% The fastest direction is close to thirty per cent faster than the slowest,
% in a single crystal. In a rock whose olivine grains have been aligned by
% flow, that anisotropy survives the averaging and becomes measurable
% hundreds of kilometres away.
%
% Note that the density had to be supplied. A stiffness on its own does not
% determine a speed - the wave equation divides it by density - so a
% velocity computed from a tensor carrying no density is not in km/s and is
% not a velocity.
%
%% Three waves, not one
%
% An isotropic solid carries two kinds of elastic wave: one compressional
% and one shear, the latter with any polarisation you like. Anisotropy
% breaks that tie. In a crystal there are three waves in every direction -
% one roughly compressional and two shear waves with definite and mutually
% perpendicular polarisations - and the two shear waves generally travel at
% different speeds.
%
% This splitting is the most useful thing in the chapter, because it is
% directly observable. A shear wave entering an aligned rock leaves as two
% pulses separated in time, and the size and orientation of that separation
% is a measurement of the texture along the path.
%
% "Roughly compressional" is meant literally: away from symmetry directions
% the particle motion of the fast wave is not exactly along the propagation
% direction. The pages below keep track of the polarisation as well as the
% speed for this reason.
%
%% Where to start
%
% <IsotropicTheory.html Isotropic Theory> is the familiar case, and worth
% reading first even if your material is anisotropic - it fixes what the
% usual moduli mean and gives the reference the anisotropic results are
% compared against.
%
% <AnisotropicTheory.html Anisotropic Theory> is the general case: Hooke's
% law with the full tensor, the directional Young's modulus, and how
% symmetry reduces the number of independent constants.
%
% <WaveVelocities.html Wave Velocities> computes the three waves and their
% polarisations, and is where the splitting above is made quantitative.
%
% <CPOSeismicProperties.html CPO Seismic Properties> is the whole chain end
% to end: measured orientations, an averaged tensor for the aggregate, and
% the seismic anisotropy that follows. It is the natural place to see how
% much of the chapter fits together.
%
%% Next
%
% The tensor machinery underneath is <Tensors.html Tensors>, including the
% averaging schemes that turn single-crystal constants into aggregate ones.
% The orientation distributions those averages need come from
% <ODFAnalysis.html ODF> or from <EBSDAnalysis.html EBSD>. Deformation that
% is not recovered on unloading is <Plasticity.html Plasticity>.
%
