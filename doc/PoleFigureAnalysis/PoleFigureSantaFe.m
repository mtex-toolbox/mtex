%% The SantaFe example
%
%%
% The Santa Fe ODF is a model texture agreed on at a workshop in Santa Fe so
% that different pole figure inversion codes could be compared on the same
% problem. Because it is a model, the true answer is known, and a
% reconstruction can be judged on what it recovers rather than on what it
% fits.
%
% This page runs the standard exercise: simulate pole figures from it, add
% counting noise, reconstruct with and without
% <PoleFigure2ODFGhostCorrection.html ghost correction>, and compare.

odf = SantaFe;

% crystal directions
h = Miller({1,0,0},{1,1,0},{1,1,1},{2,1,1},odf.CS);

% specimen directions
r = equispacedS2Grid('resolution',5*degree,'antipodal');

% pole figures
pf = calcPoleFigure(odf,h,r);

% add some noise
rng(0) % make the example reproducible
pf = noisepf(pf,100);

% plot them
plot(pf,'MarkerSize',5)
mtexColorMap LaboTeX

%%
% A mean of 100 counts is deliberately poor - the noise is clearly visible
% in the figures, as it would be in a fast measurement.

%% Two reconstructions
%
% With ghost correction, which is the default:

rec = calcODF(pf)

%%
% and without:

rec2 = calcODF(pf,'NoGhostCorrection')

%% How far from the true ODF
%
% Since the model is known, the reconstruction can be compared with it
% directly rather than with the data it was fitted to.

% calculate RP error
calcError(rec,odf)

%%
% Five percent of the volume is in the wrong place. The uncorrected
% reconstruction scores 0.100 on the same measure, twice as far.
%
% Where the recalculated pole figures disagree with the simulated ones:

% difference plot between measured and recalculated pole figures
plotDiff(pf,rec)

%%
% The differences are scattered rather than structured, which is what noise
% looks like. A systematic misfit would show as a coherent patch.

%% The reconstruction against the model
%
% The recalculated pole figures:

plotPDF(rec,pf.h,'antipodal')

%%
% and the reconstructed ODF, in sections:

plot(rec,'sections',18,'resolution',5*degree,...
  'contourf','FontSize',10,'silent','figSize','large','minmax')
mtexColorMap white2black

%%
% beside the true one:

plot(SantaFe,'sections',18,'contourf','FontSize',10,'silent',...
  'figSize','large','minmax')
mtexColorMap white2black

%%
% The components are in the right places and slightly lower: the model peaks
% at 5.0 mrd and the reconstruction at 4.4. Read the |minmax| values printed
% on the sections rather than trusting the impression the contours give -
% and note the minimum, 0.57 against 0.73 for the model. Without ghost
% correction it drops to 0.20, the reconstruction digging holes in the
% background to pay for what it left out of the peaks.

%% The harmonic coefficients
%
% The clearest view of what each reconstruction did is degree by degree.

close all;
% true ODF
plotSpektra(SantaFe,'bandwidth',32,'linewidth',2)
% keep plot for adding the next plots
hold on

% With ghost correction:
plotSpektra(rec,'bandwidth',32,'linewidth',2)

% Without ghost correction:
plotSpektra(rec2,'bandwidth',32,'linewidth',2)

legend({'true ODF','with ghost correction','without ghost correction'})
% next plot command overwrites plot
hold off

%%
% The uncorrected curve zig-zags: its odd degrees fall below the true ones
% while its even degrees follow them. That is the ghost effect in its
% natural habitat, and <PoleFigure2ODFAmbiguity.html The Ghost Effect>
% explains why the odd degrees are the ones at risk.
