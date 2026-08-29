%% Wave Velocities
%
%%
% An elastic disturbance travels through a crystal as three waves.
% For each propagation direction there is one fast, roughly compressional
% P-wave and two slower S-waves.
% Each wave has a speed and a polarisation direction.
%
% Anisotropy makes all six quantities depend on propagation direction.
% This page computes them from a stiffness tensor, visualises shear-wave
% splitting, and compares phase velocity with energy velocity.

plottingConvention.default('y↑→x');

%% Load stiffness and density
%
% Use the olivine stiffness tensor introduced in
% <AnisotropicTheory.html Anisotropic Elasticity>.
% The tensor is in GPa and is expressed in the olivine crystal frame.

fname = fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa');
cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],...
  'mineral','Olivine');
C = stiffnessTensor.load(fname,cs)

%%
% Wave speed depends on both stiffness and material density $\rho$.
% The density of olivine used here is 3.355 g/cm$^3$.
% Store it in the tensor because almost every command below needs it.

rho = 3.355;
C = addOption(C,'density',rho)

%%
% Density can instead be supplied while constructing the tensor.
% The corresponding syntax is
% |stiffnessTensor(M,cs,'density',rho)|.
% It can also be passed as a trailing argument to individual commands.
% Without density, stiffness alone does not determine a velocity in km/s.

%% Solve for one propagation direction
%
% The propagation direction $n$ is normal to the moving wavefront.
% The polarisation direction gives the particle vibration.
% <stiffnessTensor.velocity.html |velocity|> returns all three speeds and
% all three polarisations at once.

n = vector3d.X;
[vpX,vs1X,vs2X,ppX,ps1X,ps2X] = velocity(C,n)

%%
% The outputs are ordered as P-wave, fast S-wave, and slow S-wave.
% The speeds |vpX|, |vs1X|, and |vs2X| are in km/s.
% The axes |ppX|, |ps1X|, and |ps2X| give their polarisations.
% A polarisation is an <VectorsAxes.html axis> because its sign is arbitrary.
%
% The chosen $x$ direction is a symmetry axis of the olivine crystal.
% The three polarisations therefore coincide with coordinate axes.
% Here the P-wave polarisation is exactly parallel to its propagation.

%% Solve for a list of directions
%
% The same command accepts any list of propagation directions.

xyz = [vector3d.X,vector3d.Y,vector3d.Z]
vpXYZ = velocity(C,xyz)

%% Solve over the complete sphere
%
% Omit the propagation direction to compute every direction.
% The first three outputs are <S2FunConcept.html spherical functions>.
% They give P-, fast-S-, and slow-S-wave speed as functions of direction.
%
% The remaining outputs are <S2FunAxisField.html spherical axis fields>.
% They give the corresponding polarisation at each direction.

[vp,vs1,vs2,pp,ps1,ps2] = velocity(C)

%%
% These are ordinary spherical functions and can be evaluated anywhere.

vpFromGridX = vp.eval(vector3d.X)

%%
% By default, |velocity| samples a triangulated grid and interpolates between
% its nodes. This explains the small deviation from the exact |vpX| above.
%
% The option |'harmonic'| returns a
% <S2FunHarmonicRepresentation.html harmonic expansion> instead.
% Harmonic expansions are smooth and respect crystal symmetry exactly.
% They are the better choice for three-dimensional plots.

vpHarm = velocity(C,'harmonic')

%% Plot speed and polarisation together
%
% Plot the P-wave speed over the upper hemisphere.
% Overlay its polarisation axes at sampled propagation directions.

newMtexFigure
plot(vp,'upper')
hold on
plot(pp)
hold off
mtexColorMap blue2red
mtexColorbar('title','P-wave speed in km/s')

%%
% The colour at each point gives speed for that propagation direction.
% The line segment gives the corresponding particle vibration.
% Most segments stay close to the radial propagation direction.
% The P-wave is therefore almost, but not exactly, longitudinal.

%% See shear-wave splitting
%
% Spherical functions support ordinary arithmetic.
% Subtract the slow S-wave speed from the fast S-wave speed.
% Overlay the fast-wave polarisation |ps1|.

deltaVs = vs1-vs2;

newMtexFigure
plot(deltaVs,'upper')
hold on
plot(ps1)
hold off
mtexColorMap blue2red
mtexColorbar('title','fast minus slow S-wave speed in km/s')

%%
% An incident S-wave splits into two perpendicular polarisations.
% The two components travel at different speeds and arrive with a delay.
% The line segments show the fast S-wave polarisation measured by a
% seismologist.
%
% Directions where the speed difference vanishes are acoustic axes.
% Both S-waves have the same speed there, so no splitting occurs.

%% Quantify anisotropy
%
% Velocity variation is commonly reported relative to a mean velocity.
% The convention below uses the midpoint of the fastest and slowest values.

[maxVp,maxPos] = max(vp);
[minVp,minPos] = min(vp);
AVp = 200*(maxVp-minVp)./(maxVp+minVp)

%%
% P-wave anisotropy is one number for the complete directional function.
% Mark the fastest direction with a black square.
% Mark the slowest direction with a white circle.
%
% S-wave anisotropy compares the two S-waves in each common propagation
% direction, so it remains a directional function.
% The ratio of P-wave to fast-S-wave speed is a third useful quantity.

AVs = 200*(vs1-vs2)./(vs1+vs2);

newMtexFigure('layout',[1,3])

plot(vp,'upper','noLabel')
hold on
plot(maxPos(1),'Marker','s','MarkerSize',10,...
  'MarkerFaceColor','k','MarkerEdgeColor','w')
plot(minPos(1),'Marker','o','MarkerSize',10,...
  'MarkerFaceColor','w','MarkerEdgeColor','k')
hold off
mtexTitle('P-wave speed')

nextAxis
plot(AVs,'upper','noLabel')
mtexTitle('S-wave anisotropy')

nextAxis
plot(vp./vs1,'upper','noLabel')
mtexTitle('Vp/Vs1')

mtexColorMap blue2red

% one call with one title per panel - repeated calls toggle the colorbars off
mtexColorbar('title',{'km/s','percent','ratio'})

%%
% The first map locates the directions behind the scalar |AVp|.
% The second map is zero on acoustic axes and largest where splitting is
% strongest. The third map is dimensionless and need not have extrema in
% the same directions as either speed alone.

%% Compare with an isotropic aggregate
%
% Average randomly oriented olivine crystals with a
% <uniformODF.html uniform ODF>.
% The first output of <tensor.mean.html |mean|> is the Voigt average.
% <IsotropicTheory.html Isotropic Theory> defines the Voigt, Reuss, and Hill
% alternatives and explains why the exact aggregate stiffness is bounded.

C_iso = mean(C,uniformODF(cs))

%%
% This average is elastically isotropic.
% Its wave speeds are independent of propagation direction.
% They are determined completely by bulk modulus $K$, shear modulus $G$,
% and density.

K = C_iso.bulkModulus;
G = C_iso.shearModulus;

vpIso = sqrt((K + 4/3*G)./rho)
vsIso = sqrt(G./rho)

%%
% These formulas agree with |velocity| for the isotropic tensor.

[vp_iso,vs1_iso,vs2_iso] = velocity(C_iso,vector3d.X)

%%
% Both isotropic S-waves have the same speed.
% An isotropic medium therefore has no shear-wave splitting.
% Place its P-wave speed between the single-crystal extremes.

cprintf([minVp,vpIso,maxVp],...
  '-Lc',{'min Vp' 'isotropic' 'max Vp'})

%% Compare phase velocity with energy velocity
%
% The computed speeds are phase velocities.
% Phase velocity describes how fast a wavefront moves along its normal $n$.
%
% Energy travels along the energy velocity vector $V_e$.
% In a lossless medium this is a good proxy for group velocity.
% <stiffnessTensor.energyVector.html |energyVector|> computes it from the
% stiffness, propagation direction, phase speed, and polarisation.

% an arbitrary, non-symmetry propagation direction
nOblique = vector3d.byPolar(45*degree,20*degree);

[vpOblique,vs1Oblique,vs2Oblique,ppOblique,ps1Oblique,ps2Oblique] = ...
  velocity(C,nOblique);

Ve = energyVector(C,nOblique,vpOblique,ppOblique)

%%
% In an anisotropic medium, $V_e$ is generally not parallel to $n$.
% The energy is deflected sideways by the following angle in degrees.

energyDeflection = angle(Ve,nOblique)./degree

%%
% The magnitude of $V_e$ is at least as large as the phase velocity.
% Its projection onto $n$ reproduces the phase velocity exactly.

cprintf([norm(Ve),dot(Ve,nOblique),vpOblique],...
  '-Lc',{'|Ve|' 'Ve.n' 'Vp'})

%%
% Passing an empty propagation direction with spherical speed and
% polarisation functions returns a
% <S2FunVectorField.html spherical vector field>.

VeField = energyVector(C,[],vp,pp)

%% Plot phase-velocity and slowness surfaces
%
% A phase-velocity surface places each speed at a radial distance from the
% origin. A slowness surface uses reciprocal speed in s/km.
% Plot sections through the plane with normal $x$.

planeNormal = vector3d.X;

% common section and arrow options
optSec = {'color','interp','linewidth',6,'doNotDraw'};
optQuiver = {'linewidth',2,'autoScaleFactor',0.35,'doNotDraw'};
optQuiverProp = {'color','k','linewidth',2,...
  'autoScaleFactor',0.25,'doNotDraw'};
prop = S2VectorFieldHarmonic.normal;

newMtexFigure('layout',[1,2])

% phase velocities
plotSection(vp,planeNormal,optSec{:},'DisplayName','Vp')
hold on
plotSection(vs1,planeNormal,optSec{:},'DisplayName','Vs1')
plotSection(vs2,planeNormal,optSec{:},'DisplayName','Vs2')

% polarisation directions
quiverSection(vp,pp,planeNormal,'color','c',optQuiver{:},...
  'DisplayName','pp')
quiverSection(vs1,ps1,planeNormal,'color','g',optQuiver{:},...
  'DisplayName','ps1')
quiverSection(vs2,ps2,planeNormal,'color','m',optQuiver{:},...
  'DisplayName','ps2')

% propagation directions as reference
quiverSection(vp,prop,planeNormal,optQuiverProp{:},'DisplayName','n')
quiverSection(vs1,prop,planeNormal,optQuiverProp{:})
quiverSection(vs2,prop,planeNormal,optQuiverProp{:})
hold off
axis off tight
mtexTitle('Phase velocity surface')

nextAxis

% slowness surfaces
plotSection(1./vp,planeNormal,optSec{:},'DisplayName','Vp')
hold on
plotSection(1./vs1,planeNormal,optSec{:},'DisplayName','Vs1')
plotSection(1./vs2,planeNormal,optSec{:},'DisplayName','Vs2')

% polarisation directions
quiverSection(1./vp,pp,planeNormal,'color','c',optQuiver{:},...
  'DisplayName','pp')
quiverSection(1./vs1,ps1,planeNormal,'color','g',optQuiver{:},...
  'DisplayName','ps1')
quiverSection(1./vs2,ps2,planeNormal,'color','m',optQuiver{:},...
  'DisplayName','ps2')

% propagation directions as reference
quiverSection(1./vp,prop,planeNormal,optQuiverProp{:},'DisplayName','n')
quiverSection(1./vs1,prop,planeNormal,optQuiverProp{:})
quiverSection(1./vs2,prop,planeNormal,optQuiverProp{:})
hold off
axis off tight
legend('Vp','Vs1','Vs2','pp','ps1','ps2','n',...
  'Location','eastOutside')
mtexTitle('Slowness surface')

mtexColorMap blue2red
mtexColorbar('title',{'km/s','s/km'},'location','southOutside')
drawNow(gcm)

%%
% In both panels, the black arrows show propagation direction.
% The coloured arrows show the three polarisations.
%
% The view looks along the section normal $x$.
% Every propagation direction in this plane has its fast S-wave polarised
% exactly along $x$, so the green |ps1| arrows point straight at the reader
% and project to a point.
% The legend still lists |ps1|, but only the cyan |pp| and the magenta |ps2|
% arrows have a length on screen, and both lie in the section plane.
%
% The phase panel is longest where a wave is fastest.
% The slowness panel is longest where that same wave is slowest.

%% Use the overview plot
%
% <stiffnessTensor.plotSeismicVelocities.html |plotSeismicVelocities|>
% collects the main velocity, anisotropy, ratio, and polarisation maps.

plotSeismicVelocities(C)

%%
% Read the panels together: extrema in one wave need not coincide with
% extrema in splitting or in a velocity ratio.

%% The maths behind the wave speeds
%
% Consider a plane wave with propagation direction $n$, phase velocity $v$,
% and polarisation $p$.
% Its displacement field has the form
%
% $$u(x,t)=p\,f(n\mathbin{\cdot}x-vt).$$
%
% Insert this trial wave into the equation of motion
% $\rho\,\partial_t^2u_i=\partial_j\sigma_{ij}$.
% Use Hooke's law $\sigma_{ij}=C_{ijkl}\varepsilon_{kl}$ from
% <AnisotropicTheory.html Anisotropic Elasticity>.
% The result is the Christoffel equation
%
% $$C_{ijkl}n_jn_l\,p_k=\rho v^2p_i.$$
%
% The rank-two tensor $T_{ik}(n)=C_{ijkl}n_jn_l$ is the Christoffel tensor.
% <stiffnessTensor.ChristoffelTensor.html |ChristoffelTensor|> computes it
% for a chosen propagation direction.

T = ChristoffelTensor(C,vector3d.X)

%%
% The symmetry $C_{ijkl}=C_{klij}$ makes $T$ symmetric.
% Its three eigenvalues are therefore real and its eigenvectors are mutually
% perpendicular.
% Positive-definite stiffness also makes all three eigenvalues positive.
% They correspond to three real wave speeds.

[pEigen,lambda] = eig(T)

%%
% MTEX returns these eigenvalues in ascending order.
% Divide by density and take square roots to recover speeds in km/s.

vEigen = sqrt(lambda./rho)

%%
% The largest value belongs to the P-wave, whose polarisation is closest to
% the propagation direction. The two smaller values belong to the fast and
% slow S-waves. The earlier call to |velocity| performs this decomposition
% and sorting automatically.

%#ok<*NASGU>
%#ok<*NOPTS>
%#ok<*ASGLU>

%% References
%
% * E. H. Abramson, J. M. Brown, L. J. Slutsky, and J. Zaug,
% <https://doi.org/10.1029/97JB00682 The elastic constants of San Carlos
% olivine to 17 GPa>, _Journal of Geophysical Research_ 102(B6) (1997),
% 12253-12263, provides the olivine stiffness tensor used here.
% * F. I. Fedorov, _Theory of Elastic Waves in Crystals_, Plenum Press,
% New York, 1968, derives the energy-velocity expression implemented by
% |energyVector|.

%% Next
%
% <CPOSeismicProperties.html Seismic Properties of Polycrystals> applies
% this workflow to measured preferred orientations. It averages the crystal
% tensors and interprets the aggregate seismic anisotropy.
