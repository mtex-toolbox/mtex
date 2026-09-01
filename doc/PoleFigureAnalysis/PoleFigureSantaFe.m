%% The Santa Fe Benchmark
%
%%
% The Santa Fe orientation distribution function (ODF) is a model texture
% agreed on at a workshop in Santa Fe so that pole-figure inversion methods
% could be compared on the same problem. An ODF is a density over
% orientation space. Because this one is known exactly, a reconstruction can
% be judged by what it recovers rather than only by how well it fits the data.
%
% This page assumes the forward experiment from
% <PoleFigureSimulation.html Simulating Pole Figure Data> and the inverse
% problem from <PoleFigure2ODF.html ODF Estimation>. The origin of the ghost
% effect is explained in <PoleFigure2ODFAmbiguity.html The Ghost Effect>.
% Here the complete controlled experiment is used to measure how much
% <PoleFigure2ODFGhostCorrection.html ghost correction> recovers.
%
% A plotting convention states how the specimen reference frame is laid out
% on screen. The benchmark uses Y upward and X to the right. This convention
% does not rotate the specimen or change the ODF.

plottingConvention.default('y↑→x');

%% The known model
%
% <SantaFe.html |SantaFe|> has cubic crystal symmetry and orthorhombic
% specimen symmetry. It combines a 0.73 mrd uniform background with one
% component containing 27 percent of the volume. Values are in multiples of
% a random distribution (mrd), so a uniform ODF has the value 1 mrd
% everywhere; see <ODFTheory.html ODF Theory>.

odf = SantaFe;

%% Simulate noisy pole figures
%
% Four lattice directions are sampled on an antipodally symmetric specimen
% grid with 5 degree spacing.

% crystal directions
h = Miller({1,0,0},{1,1,0},{1,1,1},{2,1,1},odf.CS);

% specimen directions
r = equispacedS2Grid('resolution',5*degree,'antipodal');

% pole figures
pf = calcPoleFigure(odf,h,r);

%%
% <PoleFigure.noisepf.html |noisepf|> draws Poisson counts. At a direction
% with pole density $P_h(r)$, the mean count is $100P_h(r)$ in this example;
% 100 is an intensity scale, not the same mean at every point. No background
% is added.

pf = noisepf(pf,100);

plot(pf,'MarkerSize',5)
mtexColorMap LaboTeX

%%
% The four panels retain the model's broad pattern, while individual grid
% values fluctuate. Relative fluctuations are most conspicuous in weak
% regions because Poisson noise is large compared with a small signal.

%% Reconstruct with and without ghost correction
%
% <PoleFigure.calcODF.html |calcODF|> applies ghost correction by default.
% The second call disables it explicitly. Solver output is suppressed here
% because <PoleFigure2ODF.html ODF Estimation> explains the iteration history.

rec = calcODF(pf,'silent');
rec2 = calcODF(pf,'noGhostCorrection','silent');

%% Compare fit with recovery
%
% Two different comparisons are needed. The ODF error from
% <SO3Fun.calcError.html |calcError|> is half the mean absolute difference
% on a 5 degree orientation grid. For normalized ODFs, it is the fraction of
% material that would have to move through orientation space to turn one
% distribution into the other.
%
% The mean pole-figure residual instead compares each function with the
% noisy data. It is the regularised relative error used by
% <PoleFigure.calcError.html |calcError|>, averaged over the four pole
% figures. The extrema give a second reading of the reconstructed ODFs.

odfError = [0;...
  calcError(rec,odf,'resolution',5*degree);...
  calcError(rec2,odf,'resolution',5*degree)];

meanPoleFigureResidual = [mean(calcError(pf,odf,'silent'));...
  mean(calcError(pf,rec,'silent'));...
  mean(calcError(pf,rec2,'silent'))];

minimumMrd = [min(odf);min(rec);min(rec2)];
maximumMrd = [max(odf);max(rec);max(rec2)];

comparison = table(odfError,meanPoleFigureResidual,minimumMrd,maximumMrd,...
  'RowNames',{'model','withGhostCorrection','withoutGhostCorrection'})

%%
% The corrected reconstruction has an ODF error of 0.0498, so 5.0 percent
% of the volume is in the wrong place. The uncorrected error is 0.1002, more
% than twice as large. All three mean pole-figure residuals round to 0.050,
% and the uncorrected reconstruction fits the noisy data slightly best. A
% good fit to the projections therefore does not prove that an ODF is
% unique or true.

%% Where the corrected reconstruction misses the data
%
% <PoleFigure.plotDiff.html |plotDiff|> shows the regularised relative
% difference at every simulated measurement direction.

plotDiff(pf,rec,'silent')

%%
% The residuals are scattered rather than concentrated in one coherent
% patch. That pattern is consistent with the counting noise added above.
% With measured data it would be a diagnostic clue, not proof that noise is
% the only cause.

%% Recalculated pole figures
%
% The pole figures recalculated from the corrected ODF reproduce the broad
% maxima in the noisy simulation.

plotPDF(rec,pf.h,'antipodal')

%%
% Their smoothness is expected: the reconstruction uses finite-width
% kernels and is not intended to reproduce every random fluctuation. This
% agreement is necessary, but the table above shows why it is not a
% sufficient validation when the true ODF is unknown.

%% Read the three ODFs
%
% First plot the corrected reconstruction in Euler-angle sections.

plot(rec,'sections',18,...
  'contourf','FontSize',10,'silent','figSize','large','minmax')
mtexColorMap white2black

%%
% The known model provides the reference.

plot(odf,'sections',18,...
  'contourf','FontSize',10,'silent','figSize','large','minmax')
mtexColorMap white2black

%%
% Finally, plot the reconstruction without ghost correction.

plot(rec2,'sections',18,...
  'contourf','FontSize',10,'silent','figSize','large','minmax')
mtexColorMap white2black

%%
% The components occupy the right places in both reconstructions. Read the
% |minmax| labels instead of comparing independently scaled contour shades.
% The model peaks at 5.0 mrd and the corrected reconstruction at 4.4 mrd.
% Its minimum is 0.57 mrd against the model background of 0.73 mrd. Without
% ghost correction the minimum falls to 0.20 mrd: the reconstruction digs
% holes in the background to pay for intensity missing from the peaks.

%% Read the harmonic spectrum
%
% <SO3Fun.plotSpektra.html |plotSpektra|> groups the magnitude of the
% harmonic coefficients by degree. This is the most direct view of the
% even--odd defect.

close all;
plotSpektra(odf,'bandwidth',32,'linewidth',2,'figSize','small')
hold on
plotSpektra(rec,'bandwidth',32,'linewidth',2)
plotSpektra(rec2,'bandwidth',32,'linewidth',2)
legend({'true ODF','with ghost correction','without ghost correction'})
hold off

%%
% The uncorrected curve zig-zags: its odd degrees lie below the true ones,
% while its even degrees follow them. That is the ghost effect in harmonic
% space. The corrected curve follows the model much more smoothly because
% ghost correction estimates information that the pole figures do not
% determine.

%% Further reading
%
% * K. Pawlik, J. Pospiech and K. Lücke,
% <https://labosoft.com.pl/download/adcmethod.htm The development of a new
% direct method of ODF reproduction from pole figures and its testing with
% the help of model functions>, in J. S. Kallend and G. Gottstein (eds.),
% _ICOTOM 8_, The Metallurgical Society, 105--110, 1988. This is the
% model-function comparison presented at the Santa Fe conference.
% * S. Matthies and G. W. Vinel,
% <https://doi.org/10.1002/pssb.2221120254 On the reproduction of the
% orientation distribution function of texturized samples from reduced pole
% figures using the conception of a conditional ghost correction>,
% _physica status solidi (b)_ 112, K111--K114, 1982. This paper introduces
% the conditional ghost-correction idea.
% * R. Hielscher and H. Schaeben,
% <https://doi.org/10.1107/S0021889808030112 A novel pole figure inversion
% method: specification of the MTEX algorithm>, _Journal of Applied
% Crystallography_ 41, 1024--1037, 2008. This paper specifies the estimator
% and numerical reconstruction used here.

%% Next
%
% Continue with <PoleFigureDubna.html the Dubna example> to apply the same
% validation sequence to measured neutron pole figures. Once an ODF has
% been validated, <ODFAnalysis.html ODF Analysis> introduces its properties
% and derived quantities.
