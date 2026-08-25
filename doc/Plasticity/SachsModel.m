%% Sachs Model
%
%%
% A polycrystal yields when its grains start to slip, and how much stress
% that takes depends on assumptions no measurement supplies. The two
% classical ones bracket the answer.
%
% The *Taylor* model assumes every grain undergoes the same strain as the
% specimen. Enforcing that takes five active slip systems per grain and
% gives an upper bound on the yield stress -
% <TaylorModel.html the Taylor page> computes it.
%
% The *Sachs* model assumes the opposite: the stress is the same in every
% grain, and each grain slips on the single system that is best oriented for
% it, ignoring what the neighbours need. Grains deform independently, the
% specimen does not hold together, and the result is a lower bound.
%
% MTEX has no |calcSachs|, because the model needs nothing beyond a Schmid
% factor - see <SchmidFactor.html The Schmid Factor>.

%% The Sachs factor
%
% Take fcc slip systems and a uniaxial tension along z:

cs = crystalSymmetry('m-3m');
sS = symmetrise(slipSystem.fcc(cs))

sigma = stressTensor.uniaxial(vector3d.Z)

%%
% For a random texture, ten thousand orientations:

rng(0) % make the example reproducible
ori = orientation.rand(10000,cs);

%%
% The resolved shear stress on every slip system of every grain, as a matrix
% with one row per grain:

SF = sS.SchmidFactor(inv(ori) * sigma);

size(SF)

%%
% The Sachs assumption is that only the best of them matters, so take the
% maximum along each row:

[SFmax,active] = max(SF,[],2);

%%
% The stress needed to start that system is the critical resolved shear
% stress divided by its Schmid factor, so the factor by which the specimen
% is harder than a single well oriented crystal is the mean of one over the
% Schmid factor - the Sachs factor:

mean(1./SFmax)

%%
% 2.24 for a random fcc texture, the value the literature quotes. For
% comparison, the Taylor factor of the same texture and a matching strain:

M = calcTaylor(inv(orientation.rand(2000,cs)) * strainTensor(diag([1 -0.5 -0.5])),sS);
mean(M)

%%
% 3.07, again the classical value. The two bracket the truth: a real fcc
% polycrystal yields somewhere between 2.24 and 3.07 times the critical
% resolved shear stress of its slip systems, and where in between depends on
% how much the grains constrain each other.

%% The distribution behind the number
%
% The mean hides a spread. Every grain has its own best Schmid factor,
% between 0 and the theoretical maximum of 0.5:

histogram(SFmax,20)
xlabel('maximum Schmid factor')
ylabel('number of orientations')

%%
% The distribution is strongly skewed towards 0.5, and the smallest value
% among ten thousand random orientations is 0.28. That is a consequence of
% having twelve slip systems to choose from: it takes a very particular
% orientation for all twelve to be badly placed at once.
%
% Which system is picked is in the second output of the |max| above, and it
% is what a Sachs calculation predicts will be seen in the microscope - a
% prediction that can be checked, unlike the yield stress bound itself.
