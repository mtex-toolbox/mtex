%% Taylor Model
%
% <SchmidFactor.html Schmid analysis> asks which single slip system is best
% aligned with an applied stress. The *Taylor model* asks a different
% question: which combination of slip systems can produce an imposed strain?
% It assumes that every grain undergoes the specimen strain, and therefore
% represents the equal-strain limit of a polycrystal model.

%% Set the specimen frame and strain
% A rolling frame is a named specimen frame with rolling direction (RD),
% transverse direction (TD), and normal direction (ND). Its plotting
% convention places RD north, TD west, and ND out of the page.

specimenFrame.rolling.makeDefault

%%
% Begin with the three predefined bcc slip families. Symmetrization expands
% them to 96 systems because both signs of each Burgers vector are needed to
% represent signed slip with nonnegative coefficients.

cs = crystalSymmetry('432');
sSRepresentative = slipSystem.bcc(cs)
sS = sSRepresentative.symmetrise;
length(sS)

%%
% The strain below extends RD, leaves TD unchanged, and compresses ND by the
% same amount. More generally, $q$ partitions the transverse contraction
% between TD and ND while keeping the strain trace zero.

q = 0;
epsilon = strainTensor(diag([1 -q -(1-q)]))

%% Solve one crystal
% An orientation maps the crystal frame into the specimen frame. The inverse
% therefore expresses the imposed specimen strain in this crystal's frame,
% where the slip systems are defined.

ori = orientation.byEuler(0,30*degree,15*degree,cs)
epsilonCrystal = inv(ori) * epsilon;

[M,gamma,W] = calcTaylor(epsilonCrystal,sS);
M
W

%%
% For this orientation the Taylor factor is 2.1208. The vector |gamma|
% contains one nonnegative slip amount per system, while |W| is the
% crystallographic spin required by that combination. It is important not
% to confuse |gamma| with |sS.b|, which stores the Burgers vectors.

active = gamma > 1e-8;
bar(find(active),gamma(active))
xlabel('slip-system index')
ylabel('slip amount')

%%
% Several systems share the imposed deformation. Their summed activity,
% normalized by the strain magnitude, gives the Taylor factor.

%% Map the Taylor factor over orientation space
% If the strain remains in the specimen frame, |calcTaylor| returns the
% Taylor factor and spin as <SO3FunConcept.html orientation-dependent
% functions>. They can then be evaluated at any crystal orientation.

[MFun,~,WFun] = calcTaylor(epsilon,sS)

MFun.eval(ori)
WFun.eval(ori)

%%
% The harmonic functions approximate the direct solution above. Their main
% advantage is that the expensive Taylor solve is performed once rather than
% separately for every later orientation.

sP = phi1Sections(cs);
sP.phi1 = (0:10:90)*degree;

plot(MFun,'smooth',sP)
mtexColorbar

hold on
plot(WFun,'color','black')
hold off

%%
% The colours reproduce the orientation dependence of the Taylor factor in
% Fig. 5 of Bunge (1970). Darker and lighter regions require different total
% slip for the same strain. The black vectors show the accompanying spin
% direction and magnitude in orientation space.

%% Map the spin magnitude
% For an infinitesimal strain step, the norm of the spin tensor is the angle
% through which the corresponding crystal rotates in the Taylor model.
% The values below are angles for the strain step stored in |epsilon| and
% scale with the size of that step.

plot(norm(WFun)/degree,'smooth',sP,'resolution',0.5*degree)
mtexColorbar

%%
% The symmetry-related peaks mark orientations that rotate most during this
% plane-strain increment. This plot reproduces the construction in Fig. 8 of
% Bunge (1970).

sP = sigmaSections(cs);
plot(norm(WFun)./degree,'smooth',sP)
mtexColorbar

%%
% Sigma sections slice the same spin-magnitude function along a different
% family of paths through orientation space. The extrema are unchanged.

%% Apply the model grain by grain
% Return to the ordinary specimen frame and adopt the plotting convention of
% the CSL map. The data supply one mean orientation for each grain.

specimenFrame.specimen.makeDefault
plottingConvention.default('y↓→x');
mtexdata csl

grains = calcGrains(ebsd,'minPixel',3);
grains = smoothBoundary(grains,5);

%%
% Apply the same plane strain to every grain. The inverse mean orientations
% express it in the individual crystal frames. The fcc family contains both
% Burgers-vector signs for the nonnegative slip amounts used by the solver.

q = 0;
epsilon = strainTensor(diag([1 -q -(1-q)]));
sS = symmetrise(slipSystem.fcc(grains.CS));

[MGrain,gammaGrain,WGrain] = calcTaylor( ...
  inv(grains.meanOrientation) * epsilon,sS);

plot(grains,MGrain)
mtexColorMap white2black
mtexColorbar

%%
% Grain colour now measures the total slip needed to impose the common
% strain. A high Taylor factor identifies an orientation that is hard to
% deform under the equal-strain assumption.

[~,gammaMaxId] = max(gammaGrain,[],2);
sSGrains = grains.meanOrientation .* sS(gammaMaxId);

hold on
quiver(grains,sSGrains.b,'autoScaleFactor',0.7, ...
  'displayName','Burgers vector','project2plane')
quiver(grains,sSGrains.trace,'autoScaleFactor',0.7, ...
  'displayName','slip plane trace')
hold off

%%
% The arrows identify the system with the largest slip amount in each grain.
% One arrow is the surface projection of its Burgers vector, and the other is
% the trace of its slip plane. The full combination still contains the other
% systems with nonzero entries in |gammaGrain|.

newMtexFigure
plot(sSGrains.b)
text([xvector,yvector,zvector],'labeled','BackGroundcolor','w')

%%
% All but one of the selected directed Burgers vectors fall in the upper
% hemisphere for this $q=0$ strain. The solver uses nonnegative slip amounts
% and chooses
% between the two stored Burgers-vector signs, so this is the selected shear
% sense rather than antipodal plotting. Changing $q$ changes the strain path
% and can change both the selected systems and their signs.

%% How the Taylor solve works
% For every system $\alpha$, |calcTaylor| forms the symmetric unit-shear
% tensor $\mathbf P^\alpha$. It finds nonnegative slip amounts
% $\gamma^\alpha$ that reproduce the five independent components of the
% deviatoric strain:
%
% $$\epsilon = \sum_\alpha
%   \gamma^\alpha\mathbf P^\alpha.$$
%
% Among feasible combinations, the solver minimizes the CRSS-weighted slip
% activity $\sum_\alpha \mathrm{CRSS}^\alpha\gamma^\alpha$. With the equal
% CRSS used here, the Taylor factor is
%
% $$M = \frac{\sum_\alpha\gamma^\alpha}
%              {\|\epsilon\|}.$$
%
% The antisymmetric parts of the same shears give the spin tensor |W|.
% This construction is why the Taylor assumption needs enough independent
% slip systems to span all five deviatoric strain components.

%% Texture evolution during rolling
% Iterating the Taylor spin over small strain increments simulates how the
% orientation distribution of a polycrystal evolves during deformation.
% <TextureEvolution.html Texture Evolution> develops that calculation and
% explains the required step-size approximation.

close all

%#ok<*ASGLU>

%% References
%
% * G. I. Taylor, _Plastic Strain in Metals_, _Journal of the Institute of
% Metals_ 62 (1938), 307--324, introduces the equal-strain polycrystal model
% and its minimum-work construction.
% * H.-J. Bunge,
% <https://doi.org/10.1002/crat.19700050112 Some applications of the Taylor
% theory of polycrystal plasticity>, _Kristall und Technik_ 5 (1970),
% 145--175, gives the orientation-dependent Taylor-factor and spin plots
% reproduced on this page.

%% Next
%
% Continue with <SachsModel.html Sachs Model> for the complementary
% equal-stress limit and its comparison with the Taylor upper bound.
