%% Texture evolution in rolled magnesium during uniaxial tension
%
% This page compares two Taylor-model predictions for rolled magnesium
% pulled along its rolling direction. The starting sheet has a basal fibre
% texture, but the two temperatures use different slip resistances and
% reach different strains. The calculation shows how those choices change
% both the texture and the activity assigned to each deformation family.
%
% The motivating tension experiments reached approximately 30 percent
% strain at room temperature and 70 percent at 250 degrees Celsius.

%% Set the crystal and specimen frames
%
% The sheet is orthotropic, so its specimen symmetry is the orthorhombic
% group 222. Expressing it in a rolling frame names the specimen axes
% rolling direction (RD), transverse direction (TD), and normal direction
% (ND), and every pole figure below is drawn and annotated in those axes.
% Here the tension axis is RD.

ss = specimenSymmetry('222');
ss.frame = specimenFrame.rolling

%%
% Load the lattice parameters and hexagonal symmetry from the magnesium
% crystal-information file. |properGroup| keeps the rotational part of the
% point group used to generate oriented slip and twinning systems.

cs = crystalSymmetry.load('Mg-Magnesium.cif')
cs = cs.properGroup;

%% Build the initial basal fibre texture
%
% In an ideal rolled magnesium sheet, the crystal c-axes are parallel to ND
% while rotations about that axis are random. A fibre ODF represents that
% basal fibre texture directly.

odf = fibreODF(cs.cAxis,vector3d.Z,ss);
odf = FourierODF(odf);

%%
% Plot the basal pole, a prismatic pole, and a pyramidal pole. Pole figures are
% antipodal here, so opposite directions are drawn as the same pole.

h = Miller({0,0,0,1},{1,0,-1,0},{1,0,-1,1},cs);
plotPDF(odf,h,'contourf','complete','upper')
mtexColorbar

%%
% The basal poles form one maximum at ND. The prismatic poles form a ring
% because the initial model contains every rotation about the c-axis with
% equal probability. RD is also the tension direction in all three plots.

%% Choose temperature-dependent families
%
% The <SlipSystems.html Slip Systems> page defines critical resolved shear
% stress (CRSS) and explains why hexagonal materials have no universal slip
% set. CRSS depends on material, temperature, and experiment, and published
% values vary widely. The dimensionless values below are illustrative ratios
% normalized to basal slip, not a universal magnesium parameter set.
%
% At room temperature, basal slip commonly dominates magnesium deformation
% and extension twins can also have a low CRSS. For this basal texture,
% tension perpendicular to the c-axis does not activate extension twinning.
% The model therefore includes only compression twins and assigns them the
% largest CRSS.

sScold = [slipSystem.basal(cs,1),...
  slipSystem.prismatic2A(cs,66),...
  slipSystem.pyramidalCA(cs,80),...
  slipSystem.twinC1(cs,100)];

% Generate all symmetry-related systems and remember their family ids.
[sScold,slipId] = sScold.symmetrise;

%%
% At higher temperature, the assumed CRSS of both non-basal slip families
% decreases. The compression-twin CRSS remains high in this comparison.

sSwarm = [slipSystem.basal(cs,1),...
  slipSystem.prismatic2A(cs,15),...
  slipSystem.pyramidalCA(cs,10),...
  slipSystem.twinC1(cs,100)];
sSwarm = sSwarm.symmetrise;

%% Define the two strain states
%
% Plastic incompressibility requires each infinitesimal strain tensor to
% have zero trace. The room-temperature case assumes unequal contraction
% along TD and ND. The 250-degree case assumes that this transverse
% anisotropy is negligible, so both directions contract equally.

epsCold = 0.3 * strainTensor(diag([1 -0.6 -0.4]))
epsWarm = 0.7 * strainTensor(diag([1 -0.5 -0.5]))

%% Solve the Taylor model for the starting texture
%
% Draw a synthetic polycrystal from the initial ODF. |optimalSample| places
% the orientations so that they reproduce the ODF as closely as possible,
% which needs far fewer of them than a random draw. Both simulations start
% from this same polycrystal.

ori = odf.optimalSample(5000)

%%
% Express each strain in each crystal frame and solve the Taylor problem.
% The columns of |bCold| and |bWarm| are slip or twin amounts for the
% symmetrized systems. The spin tensors describe the corresponding lattice
% rotations.

[~,bCold,Wcold] = calcTaylor(inv(ori) .* epsCold,sScold);
[~,bWarm,Wwarm] = calcTaylor(inv(ori) .* epsWarm,sSwarm);

%%
% Apply each crystallographic spin to the initial orientations.

oriCold = ori .* orientation(-Wcold);
oriWarm = ori .* orientation(-Wwarm);

meanRotation = [mean(angle(ori,oriCold)),...
  mean(angle(ori,oriWarm))] ./ degree

%%
% The mean orientation changes are 8.3179 degrees at room temperature and
% 15.4162 degrees at 250 degrees Celsius. The larger warm value reflects
% both its larger imposed strain and its different CRSS ratios.

%% One-step approximation
%
% This page evaluates the spin only at the starting orientations and applies
% the entire 30 or 70 percent strain in one update. It is therefore an
% illustrative one-step approximation, especially at the larger strain.
% <TextureEvolution.html Texture Evolution> shows the more accurate
% incremental calculation in which orientations are updated repeatedly.

%% Compare the pole figures
%
% Add the room-temperature and 250-degree results beneath the initial pole
% figures, then arrange the three states as rows on common specimen axes.

newMtexFigure('layout',[3,3])
plotPDF(odf,h,'contourf','complete','upper','grid','grid_res',30*degree)

nextAxis
plotPDF(oriCold,h,'contourf','upper','complete',...
  'grid','grid_res',30*degree,'noLabel','noTitle')

nextAxis
plotPDF(oriWarm,h,'contourf','upper','complete',...
  'grid','grid_res',30*degree,'noLabel','noTitle')
mtexColorbar


%%
% Compare each column from top to bottom: initial, room temperature, then
% 250 degrees Celsius. Both deformed rows depart from the ideal basal fibre,
% and they differ from one another because their CRSS ratios, strain shapes,
% and total strains are different. The plot cannot attribute a difference
% to temperature alone because all three inputs change together.

%% Summarize deformation-family activity
%
% Sum the Taylor coefficients of symmetry-related systems using |slipId|.
% Dividing by the number of sampled crystals gives the mean amount assigned
% to each family per crystal.

slipId = repmat(slipId.',length(ori),1);
statSsCold = accumarray(slipId(:),bCold(:)) ./ length(ori);
statSsWarm = accumarray(slipId(:),bWarm(:)) ./ length(ori);

familyActivity = array2table([statSsCold.';statSsWarm.'],...
  'VariableNames',{'Basal','Prismatic','Pyramidal','CompressionTwin'},...
  'RowNames',{'RoomTemperature','250DegreesC'})

%%
% Use a logarithmic scale because the active family totals span several
% orders of magnitude.

figure(2)
bar([statSsCold.';statSsWarm.'])
set(gca,'YScale','log','XTickLabel',{'RT','250 degrees C'})
ylabel('Mean deformation amount per crystal')
legend({'Basal slip','Prismatic slip','Pyramidal slip','Comp. twin'},...
  'Location','eastoutside')
legend('boxoff')

%%
% Prismatic and pyramidal slip carry almost all deformation in this example.
% The warm CRSS ratios favour pyramidal slip over prismatic slip, whereas
% the order is reversed at room temperature. Compression-twin activity is
% below $3 \times 10^{-10}$ per crystal, nine to ten orders of magnitude
% under prismatic and pyramidal slip. Because the imposed total strains
% differ, compare the family ranking within a row rather than absolute bar
% heights between temperatures.

%% References
%
% * G. I. Taylor, _Plastic Strain in Metals_, _Journal of the Institute of
% Metals_ 62 (1938), 307--324. This paper introduces the equal-strain
% polycrystal model used to select the deformation-system amounts.
% * A. Jain and S. R. Agnew,
% <https://doi.org/10.1016/j.msea.2006.03.160 Modeling the temperature
% dependent effect of twinning on the behavior of magnesium alloy AZ31B
% sheet>, _Materials Science and Engineering A_ 462 (2007), 29--36. This
% paper documents the strong temperature dependence of non-basal slip CRSS
% and the sensitivity of magnesium predictions to the chosen CRSS values.

%% Next
%
% <Lankford.html Lankford> uses Taylor factors to predict the plastic strain
% ratio of a sheet as its loading direction changes. It turns the same
% orientation-dependent deformation model into a measure of sheet anisotropy.

%#ok<*ASGLU,*NOPTS>
