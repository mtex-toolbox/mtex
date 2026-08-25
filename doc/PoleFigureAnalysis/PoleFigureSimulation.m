%% Simulating Pole Figure data
%
%%
% With measured data one never knows the answer, so a reconstruction can
% only be judged by how well it reproduces the measurement - which is
% exactly what it was fitted to do. Simulated data remove that circularity:
% start from a known ODF, compute the pole figures it would produce, add
% noise, reconstruct, and compare with what you started from.
%
% This page does that once, and then uses it to answer a practical question:
% how many pole figures does a reconstruction need?

plottingConvention.default('y↑→x');
cs = crystalSymmetry('orthorhombic');
mod1 = orientation.byAxisAngle(xvector,45*degree,cs);
mod2 = orientation.byAxisAngle(yvector,65*degree,cs);
model_odf = 0.5*uniformODF(cs) + ...
  0.05*fibreODF(Miller(1,0,0,cs),xvector,'halfwidth',10*degree) + ...
  0.05*fibreODF(Miller(0,1,0,cs),yvector,'halfwidth',10*degree) + ...
  0.05*fibreODF(Miller(0,0,1,cs),zvector,'halfwidth',10*degree) + ...
  0.05*unimodalODF(mod1,'halfwidth',15*degree) + ...
  0.3*unimodalODF(mod2,'halfwidth',25*degree);

%%
% Six components: half of the volume uniform, three fibres, and two
% unimodal components. Half uniform makes this a deliberately hard case -
% the uniform portion is what a pole figure constrains least.

plot(model_odf,'sections',6,'silent','sigma')

%% Simulating the measurement
%
% Three things decide what a simulated measurement looks like: which lattice
% planes are measured, at which specimen directions, and how noisy the
% counting is. Superposition coefficients may be given as well, for the
% planes whose diffraction peaks overlap.
%
% Seven lattice planes:

h = [Miller(1,1,1,cs),Miller(1,1,0,cs),Miller(1,0,1,cs),Miller(0,1,1,cs),...
  Miller(1,0,0,cs),Miller(0,1,0,cs),Miller(0,0,1,cs)];

%%
% on a <regularS2Grid.html regular grid> of 5 degrees:

r = regularS2Grid('resolution',5*degree);

%%
% <SO3Fun.calcPoleFigure.html |calcPoleFigure|> evaluates the ODF over each
% of them.

pf = calcPoleFigure(model_odf,h,r)

%%
% So far these are exact values. A real measurement counts quanta, so its
% error is Poisson distributed - the brighter the point, the better its
% relative accuracy. <PoleFigure.noisepf.html |noisepf|> adds exactly that,
% for a given mean number of counts.

rng(0) % make the example reproducible
pf = noisepf(pf,1000);

%%

plot(pf)

%% Reconstructing and comparing
%
% The reconstruction is the ordinary one.

odf = calcODF(pf)

%%

plot(odf,'sections',6,'silent','sigma')

%%
% Compared with the model above, the components are in the right places and
% the sections look alike. The number behind that impression:

calcError(odf,model_odf,'resolution',5*degree)

%%
% This is the L1 distance between the two functions, evaluated on a 5 degree
% grid: about eight percent of the volume is in the wrong place. Nothing in
% a real experiment can produce this number, which is the whole reason for
% simulating.

%% How many pole figures are needed
%
% Each additional pole figure adds equations to an underdetermined problem,
% so the error should fall as they are added - and it should stop falling
% once the remaining ambiguity is not the kind more data can resolve. The
% experiment: reconstruct from the first one, the first two, and so on, with
% and without <PoleFigure2ODFGhostCorrection.html ghost correction>.

e = [];
for i = 1:pf.numPF

  odf = calcODF(pf({1:i}),'silent','NoGhostCorrection');
  e(i,1) = calcError(odf,model_odf,'resolution',2.5*degree);
  odf = calcODF(pf({1:i}),'silent');
  e(i,2) = calcError(odf,model_odf,'resolution',2.5*degree);

end

% visualize the result
close all;
plot(1:pf.numPF,e,'LineWidth',2)
xlabel('Number of Pole Figures');
ylabel('Reconstruction Error');
legend({'Without Ghost Correction','With Ghost Correction'});

%%
% Both curves fall steeply from one pole figure to four - 0.30 to 0.11 with
% ghost correction - and then flatten out, with a bump where the fifth is
% added. Past four, more pole figures of this crystal symmetry buy little,
% and which four they are matters more than how many.
%
% The corrected curve is the lower one at every count, but not by much: 0.083
% against 0.102 at seven pole figures, and almost nothing at one. Ghost
% correction repairs a specific defect, the uniform portion, and this ODF
% has a large one by construction - see
% <PoleFigure2ODFAmbiguity.html The Ghost Effect> for what that defect is.

%#ok<*SAGROW>
