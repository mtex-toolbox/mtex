%% Ghost Effect Analysis
%
%%
% The odd order harmonic coefficients of an ODF leave no trace in its pole
% figures, so a reconstruction has to guess them - see
% <PoleFigure2ODFAmbiguity.html the ambiguity of the reconstruction
% problem>. Guessing them as zero is the safe choice and it has a visible
% cost: the texture components come out too weak and sit on a uniform
% background that is too high, sometimes with spurious components beside
% them. Those artefacts are the *ghosts*.
%
% Matthies' remedy is to determine the uniform portion of the unknown ODF
% first - he called it the *phon* - subtract it, and reconstruct the sharp
% remainder, where the non-negativity constraint is strong enough to pin the
% odd coefficients down. MTEX does this by default.
%
% A sharp texture has little to gain, since non-negativity already
% constrains it. This page therefore takes the opposite case: an ODF that is
% nine tenths uniform.

%% A deliberately weak model ODF

cs = crystalSymmetry('222');
mod1 = orientation.byEuler(0,0,0,cs);
odf = 0.9*uniformODF(cs) + ...
  0.1*unimodalODF(mod1,'halfwidth',10*degree)

%% Simulated pole figures
%
% Three lattice planes on a 5 degree grid, computed from the model and used
% as if they had been measured.

% specimen directions
r = equispacedS2Grid('resolution',5*degree,'antipodal');

% crystal directions
h = Miller({1,0,0},{0,1,0},{0,0,1},cs);

% compute pole figures
pf = calcPoleFigure(odf,h,r);

plot(pf)

%% Two reconstructions
%
% Without ghost correction:

rec = calcODF(pf,'noGhostCorrection','silent');

%%
% and with it:

rec_cor = calcODF(pf,'silent');

%% How well do they fit the data
%
% The RP error against the simulated pole figures, without correction:

calcError(pf,rec,'RP')

%%
% and with correction:

calcError(pf,rec_cor,'RP')

%%
% The uncorrected reconstruction fits the data *better* - about 0.009
% against 0.025 per pole figure. That is not a surprise and not a defect:
% ghost correction adds an assumption about the uniform portion, and an
% assumption can only cost fit. Judged on the data alone, the uncorrected
% reconstruction wins.

%% They are not equally close to the truth
%
% Since the model ODF is known here, the reconstructions can be compared
% with it directly. Without correction:

calcError(rec,odf)

%%
% and with correction:

calcError(rec_cor,odf)

%%
% And here it loses by a factor of twenty three: 0.126 against 0.005. This
% is the whole argument for ghost correction in two pairs of numbers. The
% reconstruction that fits the measurement three times better is more than
% twenty times further from the truth.

%% What the difference looks like
%
% Without ghost correction:

plot(rec,'sections',9,'silent','sigma')

%%
% and with it:

plot(rec_cor,'sections',9,'silent','sigma')

%%
% A section through the fibre that contains the component shows the same
% comparison as a curve. The true ODF first:

close all
f = fibre(Miller(0,1,0,cs),yvector);
plot(odf,f,'linewidth',2);
hold on

%%
% without ghost correction:

plot(rec,f,'linewidth',2);

%%
% and with ghost correction:

plot(rec_cor,f,'linestyle','--','linewidth',2);
hold off
legend({'true ODF','without ghost correction','with ghost correction'})

%%
% Three defects at once in the uncorrected curve. Its peak reaches 25 mrd
% where the true one reaches 40. The level between the peaks is 3 mrd
% instead of 1, so the volume the peak lost went into the background. And
% there are two small bumps at 90 and 270 degrees that the true ODF does not
% have at all - components conjured out of nothing.
%
% The corrected curve, dashed, is on top of the true one everywhere. Those
% bumps are the ghosts the effect is named after.

%% In the harmonic coefficients
%
% The effect lives in the odd order coefficients, so that is where it is
% clearest. All three functions are first written as harmonic series.

odf = FourierODF(odf,25)
rec = FourierODF(rec,25)
rec_cor = FourierODF(rec_cor,25)

%%
% The L2 error, without ghost correction:

calcError(rec,odf,'L2')

%%
% and with it:

calcError(rec_cor,odf,'L2')

%%
% 0.36 against 0.03 - the same verdict as the L1 comparison above, an order
% of magnitude apart.

%%
% Plotting the coefficient magnitudes degree by degree shows why. The true
% ODF:

close all;
plotSpektra(odf,'linewidth',2)

%%

hold on

%%
% without ghost correction - note the zig-zag: the odd degrees are pulled
% down towards zero while the even ones are right.

plotSpektra(rec,'linewidth',2)

%%
% and with ghost correction, which follows the true curve smoothly:

plotSpektra(rec_cor,'linewidth',2)
legend({'true ODF','without ghost correction','with ghost correction'})
% next plot command overwrites plot window
hold off

%%
% A zig-zag in a spectrum is the signature to look for. Whenever the odd
% degrees of a reconstruction sit systematically below the even ones, the
% odd order information was guessed rather than measured.
