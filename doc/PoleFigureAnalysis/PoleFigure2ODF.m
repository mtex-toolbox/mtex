%% ODF Estimation from Pole Figure Data
%
%%
% A pole figure does not measure individual orientations. Each value sums
% every orientation that places one lattice plane in one specimen direction.
% Those orientations form a one-dimensional fibre in orientation space.
% One pole figure therefore cannot be inverted by itself.
%
% Combining several pole figures adds constraints, but it still does not
% make the inverse problem unique. The practical task is to find an
% orientation distribution function (ODF) whose recalculated pole figures
% agree with the measurements, and then to inspect where they do not agree.
%
% This page assumes the pole-figure idea from
% <PoleFigureAnalysis.html Pole Figures> and corrected measurements from
% <PoleFigureCorrection.html Data Correction>. The definition and units of
% an ODF are introduced in <ODFTheory.html ODF Theory>.
% Here the reconstruction uses <PoleFigure.calcODF.html |calcODF|>.
% <PoleFigure2ODFAmbiguity.html The Ghost Effect> explains what the
% measurements can never determine.

plottingConvention.default('y↑→x');
mtexdata dubna silent

%% Inspect the measurements first
%
% The data contain seven neutron-diffraction pole figures from a quartz
% specimen. One measurement is a superposition of two unresolved
% reflections. <PoleFigureImport.html Import> explains how the Miller
% indices and their structure coefficients enter that measurement model.

plot(pf)

%%
% The seven panels contain sharp maxima at different specimen directions.
% The superposed reflection has two Miller indices in its title. Look for
% missing coverage, isolated points, or a pattern that is inconsistent with
% the other panels before asking an ODF to explain the data.

%% Reconstruct an ODF
%
% With no options, |calcODF| uses MTEX's modified least-squares solver and
% automatic ghost correction.

tic
odf = calcODF(pf)
defaultTime = toc;

%%
% The result is an <SO3FunRBF.SO3FunRBF.html |SO3FunRBF|>. It represents
% the ODF as a weighted superposition of unimodal kernel functions on a grid
% in orientation space. The display reports 19,848 grid centres for this
% reconstruction. The object can be analysed like any other ODF; continue
% to <ODFAnalysis.html ODF Analysis> after validating the reconstruction.

%% Compare recalculated and measured pole figures
%
% The first validation is visual. Recalculate exactly the lattice planes
% and superpositions that were measured.

plotPDF(odf,pf.allH,'antipodal','silent','superposition',pf.c)

%%
% The maxima appear in the same regions and reach comparable intensities.
% The recalculated pole figures are smoother because the finite-width
% kernels do not reproduce every fluctuation in the measurement.
%
% <PoleFigure.calcError.html |calcError|> makes the same comparison one pole
% figure at a time. The |'RP'| measure divides the absolute difference by
% the recalculated intensity, but only where that intensity exceeds the
% threshold supplied after |'RP'|. The default threshold is 1.

rpError = calcError(pf,odf,'RP','silent')

%%
% The seven RP values range from 0.36 to 0.86. Because RP is relative, weak
% regions can dominate even when their absolute differences are small.
%
% Called without a measure, |calcError| uses a regularised relative error.
% It divides by the larger intensity plus half the scale factor, so it does
% not divide by a value near zero.

regularisedError = calcError(pf,odf,'silent')

%%
% The regularised values range from 0.24 to 0.40. They are not smaller RP
% values; they answer a different question. Compare reconstructions with
% the same measure and threshold throughout. The other available measures
% are |'l1'| and |'l2'|.
%
% A single error vector hides where the mismatch occurs.
% <PoleFigure.plotDiff.html |plotDiff|> plots the regularised relative
% difference for every measured direction.

plotDiff(pf,odf,'silent')

%%
% These residuals are not scattered. In every one of the seven panels the
% mean residual grows from the centre of the disc outward, roughly doubling
% by the rim.
%
% Scattered residuals would be consistent with measurement noise. A pattern
% this orderly points to a systematic cause worth checking, and one that
% grows with specimen tilt is the signature of an omitted defocusing
% correction. An incorrect background or a pole figure that does not belong
% with the others would also leave structure. The pattern is a diagnostic
% clue, not proof of any one cause.

%% Comparing two ODFs
%
% The <SO3Fun.calcError.html |calcError|> overload also compares two ODFs.
% This is a different calculation from comparing an ODF with pole-figure
% measurements. To make the distinction visible, build one broad component
% at the strongest orientation of the reconstruction.

[~,oriPref] = max(odf);
odfModel = unimodalODF(oriPref,'halfwidth',15*degree);

plotPDF(odfModel,pf.allH,'antipodal','superposition',pf.c)

odfDifference = calcError(odfModel,odf)

%%
% The model pole figures retain the main maxima and omit the weaker
% components. The large ODF difference is therefore expected: one
% unimodal component cannot represent this multi-component texture.

%% Control the discretization
%
% The solver places unimodal components on a grid in orientation space.
% The |'resolution'| option sets the grid spacing, while each default de la
% Vallee Poussin kernel has the same halfwidth as that spacing.
%
% The |calcODF| reference describes its default grid as 1.5 times the pole-
% figure resolution. The current |MLSSolver| constructor instead uses the
% stored resolution of the first pole figure. Pass |'resolution'| explicitly
% when that distinction matters to reproducibility.
%
% A 15 degree grid demonstrates the speed-resolution trade-off.

tic
odfCoarse = calcODF(pf,'resolution',15*degree,'silent');
coarseTime = toc;

plotPDF(odfCoarse,pf.allH,'antipodal','silent','superposition',pf.c)

defaultPeak = max(odf);
coarsePeak = max(odfCoarse);
meanDefaultRP = mean(rpError);
meanCoarseRP = mean(calcError(pf,odfCoarse,'RP','silent'));
fprintf(['Default: %.2f s, peak %.1f mrd, mean RP %.2f; ',...
  '15 degree: %.2f s, peak %.1f mrd, mean RP %.2f\n'],...
  defaultTime,defaultPeak,meanDefaultRP,...
  coarseTime,coarsePeak,meanCoarseRP);

%%
% The 15 degree result keeps the main maxima but broadens them. The timing
% printed above shows the speed-up. Its peak is 27.1 mrd instead of
% 94.0 mrd, and the mean RP error rises from 0.59 to 0.75.
% A coarse grid cannot represent a sharp texture. A finer grid costs more
% time and, once it exceeds the information in the measurements, can give a
% false impression of resolved detail.
%
% Two options control the kernel directly. The |'kernel'| option accepts an
% |SO3Kernel| object. The |'halfwidth'| option keeps the default de la Vallee
% Poussin kernel and changes its width.

%% The zero range method
%
% If a measured pole figure is genuinely zero in a region, every
% orientation contributing there must also have zero density. The zero
% range method removes those orientation-grid nodes before solving. It can
% make a sharp reconstruction with large empty regions both faster and
% finer.

tic
odfZero = calcODF(pf,'zeroRange','silent');
zeroTime = toc;

plotPDF(odfZero,pf.allH,'antipodal','silent','superposition',pf.c)

zeroPeak = max(odfZero);
meanZeroRP = mean(calcError(pf,odfZero,'RP','silent'));
fprintf(['Zero range: %.2f s, peak %.1f mrd, mean RP %.2f; ',...
  'default: %.2f s, peak %.1f mrd, mean RP %.2f\n'],...
  zeroTime,zeroPeak,meanZeroRP,...
  defaultTime,defaultPeak,meanDefaultRP);

%%
% On this data set the method does change the reconstruction. The peak rises
% from 94.0 to 110.4 mrd and the mean RP error falls from 0.59 to 0.51.
% The timings printed above show that it also runs faster here, because the
% solver keeps far fewer grid nodes. The sharper recalculated
% maxima are the visible difference to look for. Try the method rather than
% assuming it will help. The
% <zeroRangeMethod.zeroRangeMethod.html |zeroRangeMethod|> reference lists
% the threshold and smoothing options that decide what counts as zero.

%% Ghost correction
%
% The odd-order harmonic coefficients of an ODF do not appear in its pole
% figures, so the measurements do not determine them. Setting them to zero
% produces the *ghost effect*: a raised uniform background, weakened real
% components, and sometimes spurious components.
%
% <PoleFigure2ODFGhostCorrection.html Ghost Correction> explains Matthies'
% remedy, which MTEX applies by default and which matters most for weak
% textures. <PoleFigureSantaFe.html The Santa Fe Example> measures the
% benefit on a model ODF for which the true answer is known. A good fit to
% the pole figures alone does not establish that a reconstructed ODF is
% unique or true.

%% The maths behind the estimator
%
% In simplified notation, |calcODF| minimises a modified least-squares
% functional over non-negative combinations of the kernel components:
%
% $$f_{\mathrm{est}} = \mathrm{argmin}_{f} \sum_{i=1}^{N} \sum_{j=1}^{N_i} \frac{|\alpha_i Rf(h_i,r_{ij}) - I_{ij}|^2}{I_{ij}}.$$
%
% Dividing by $I_{ij}$ makes the functional modified least squares. It
% weights each measurement by its own intensity, so a bright point cannot
% dominate a dark one. The factor $\alpha_i$ absorbs the unknown scale of
% each pole figure, which allows unnormalised intensity data to be used.

%% Further reading
%
% * R. Hielscher and H. Schaeben,
% <https://doi.org/10.1107/S0021889808030112 A novel pole figure inversion
% method: specification of the MTEX algorithm>, _Journal of Applied
% Crystallography_ 41, 1024-1037, 2008. This is the complete specification
% of the estimator and numerical algorithm used here.
% * R.-J. Roe,
% <https://doi.org/10.1063/1.1714396 Description of crystallite orientation
% in polycrystalline materials. III. General solution to pole figure
% inversion>, _Journal of Applied Physics_ 36, 2024-2031, 1965. This is the
% classical harmonic treatment of the inverse problem.
% * H.-J. Bunge,
% <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis in Materials
% Science: Mathematical Methods>, Butterworths, English ed., 1982. This is
% the standard textbook treatment of pole figures and ODF reconstruction.
% * S. Matthies and G. W. Vinel,
% <https://doi.org/10.1002/pssb.2221120254 On the reproduction of the
% orientation distribution function of texturized samples from reduced pole
% figures using the conception of a conditional ghost correction>,
% _physica status solidi (b)_ 112, K111-K114, 1982. This introduces the
% conditional ghost correction used by MTEX.

%#ok<*NOPTS>
