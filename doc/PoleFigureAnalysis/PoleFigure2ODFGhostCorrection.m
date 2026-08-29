%% Ghost Correction
%
%%
% Pole figures do not contain the odd-order harmonic coefficients of an
% orientation distribution function (ODF). A reconstruction must therefore
% choose those coefficients without help from the measurements. See
% <PoleFigure2ODFAmbiguity.html Ambiguity of Pole Figure Inversion> for the
% demonstration and <SO3FunHarmonicRepresentation.html Harmonic
% Representation> for the coefficient description.
%
% Setting the unknown odd-order coefficients to zero is a safe mathematical
% choice, but it has a visible cost. Real texture components become too weak
% and sit on a uniform background that is too high. Spurious components may
% also appear beside them. These inversion artefacts are called *ghosts*;
% they are not measurement noise.
%
% Matthies' remedy is to estimate the uniform portion of the ODF first. He
% called this portion the *phon*. MTEX estimates it from the low-intensity
% tail of the pole figures, subtracts it, and reconstructs the sharper
% remainder. Non-negativity then constrains the missing odd-order
% coefficients more strongly. <PoleFigure.calcODF.html |calcODF|> applies
% this correction by default.
%
% Ghost correction adds a physical preference; it does not recover
% information that diffraction measured. It matters most for weak textures
% with a substantial uniform portion. Sharp textures have less to gain
% because non-negativity already constrains them strongly.
%
% This page isolates the effect with a known model that is nine tenths
% uniform. It assumes the reconstruction workflow from
% <PoleFigure2ODF.html ODF Reconstruction> and the ODF normalization from
% <ODFTheory.html ODF Theory>.

%% Build a deliberately weak ODF

cs = crystalSymmetry('222');
mod1 = orientation.byEuler(0,0,0,cs);
odf = 0.9*uniformODF(cs) + ...
  0.1*unimodalODF(mod1,'halfwidth',10*degree);

%% Simulate the pole figures
%
% The experiment samples three lattice-plane normals on an antipodal
% specimen-direction grid with 5 degree spacing. These synthetic pole
% figures now stand in for measurements, while the true ODF remains known.

% specimen directions
r = equispacedS2Grid('resolution',5*degree,'antipodal');

% crystal directions
h = Miller({1,0,0},{0,1,0},{0,0,1},cs);

% compute pole figures
pf = calcPoleFigure(odf,h,r);

plot(pf);

%%
% Each pole figure has one broad maximum on a nearly uniform background.
% The weak contrast is exactly the situation in which the uniform portion
% can hide missing odd-order information.

%% Reconstruct with and without correction
%
% The |'noGhostCorrection'| flag disables the default correction.

rec = calcODF(pf,'noGhostCorrection','silent');

%%
% Omitting that flag gives the corrected reconstruction.

recCor = calcODF(pf,'silent');

%% Compare the fits to the pole figures
%
% <PoleFigure.calcError.html |calcError|> returns one RP error per pole
% figure. First evaluate the reconstruction without correction.

rpUncorrected = calcError(pf,rec,'RP','silent')

%%
% Now evaluate the corrected reconstruction with the same measure.

rpCorrected = calcError(pf,recCor,'RP','silent')

%%
% The uncorrected RP values range from 0.0088 to 0.0109, compared with
% 0.0246 to 0.0264 after correction. This is neither surprising nor a
% defect. Ghost correction adds an assumption about the uniform portion,
% and that assumption can only cost fit. Judged on the pole figures alone,
% the uncorrected reconstruction wins.

%% Compare the reconstructions with the truth
%
% A measured texture has no known true ODF. This synthetic example does, so
% <SO3Fun.calcError.html |calcError|> can compare the functions directly.
% First compute the L1 error without correction.

l1Uncorrected = calcError(rec,odf,'L1')

%%
% Then compute the same error with correction.

l1Corrected = calcError(recCor,odf,'L1')

%%
% Here the uncorrected result loses by a factor of 23.2: 0.1255 against
% 0.0054. This is the argument for ghost correction in two pairs of
% numbers. The reconstruction that fits the pole figures roughly two to
% three times better is more than twenty times farther from the true ODF.

%% Inspect the ODF sections
%
% Without ghost correction:

plot(rec,'sections',9,'silent','sigma');

%%
% The component is broad and weak, and the surrounding density is raised.
% Now plot the corrected reconstruction on the same type of sections.

plot(recCor,'sections',9,'silent','sigma');

%%
% The corrected sections concentrate more density at the component and
% return the surrounding background towards its true level.

%% Read a profile through the component
%
% A fibre is the one-dimensional set of orientations that maps a crystal
% direction onto a specimen direction. The following fibre passes through
% the model component. Plot the true ODF first.

close all;
f = fibre(Miller(0,1,0,cs),yvector);
plot(odf,f,'linewidth',2);
hold on;

%%
% Add the reconstruction without correction.

plot(rec,f,'linewidth',2);

%%
% Finally add the corrected reconstruction as a dashed curve.

plot(recCor,f,'linestyle','--','linewidth',2);
hold off;
legend({'true ODF','without ghost correction','with ghost correction'});

%%
% The printed rows follow the legend order. The columns report the maximum
% and the values at 45, 90, and 270 degrees along the fibre.

profileOri = orientation(f,'points',361);
profileValues = [eval(odf,profileOri),eval(rec,profileOri),...
  eval(recCor,profileOri)].';
profileCheck = [max(profileValues,[],2),profileValues(:,46),...
  profileValues(:,91),profileValues(:,271)];
fprintf(['                    peak   at 45   at 90  at 270\n' ...
  'true ODF          %6.2f  %6.2f  %6.2f  %6.2f\n' ...
  'without correction%6.2f  %6.2f  %6.2f  %6.2f\n' ...
  'with correction   %6.2f  %6.2f  %6.2f  %6.2f\n'],profileCheck.');

%%
% The uncorrected curve has three defects. Its peak reaches 25.23 mrd where
% the true peak reaches 39.78 mrd. At 45 degrees it is 2.82 mrd instead of
% 0.90 mrd, so the density missing from the peak has entered the background.
% Small bumps at 90 and 270 degrees are components conjured out of nothing.
%
% The dashed corrected curve follows the true curve closely. Its peak is
% 37.38 mrd and its value at 45 degrees is 1.06 mrd. The two extra bumps in
% the uncorrected curve are the ghosts that give the effect its name.

%% Inspect the harmonic coefficients
%
% The effect lives in the odd-order coefficients, where it is clearest.
% First express all three functions as harmonic series through degree 25.

odf = FourierODF(odf,25);
rec = FourierODF(rec,25);
recCor = FourierODF(recCor,25);

%%
% The L2 error without ghost correction is:

l2Uncorrected = calcError(rec,odf,'L2')

%%
% With ghost correction it is:

l2Corrected = calcError(recCor,odf,'L2')

%%
% The values are 0.3621 and 0.0312. Like the L1 comparison, this puts the
% two reconstructions an order of magnitude apart.

%% Plot the harmonic spectrum
%
% A harmonic spectrum groups coefficient magnitudes by degree. Plot the
% true ODF first.

close all;
plotSpektra(odf,'linewidth',2);
hold on;

%%
% Add the uncorrected reconstruction. Its zig-zag is the key feature: odd
% degrees are pulled towards zero while the even degrees remain close to
% the truth.

plotSpektra(rec,'linewidth',2);

%%
% The corrected reconstruction follows the true spectrum smoothly.

plotSpektra(recCor,'linewidth',2);
legend({'true ODF','without ghost correction','with ghost correction'});
% next plot command overwrites plot window
hold off;

%%
% A systematic odd-even zig-zag is the diagnostic to look for. It shows
% that the reconstruction had to guess odd-order information that the pole
% figures did not measure. The pattern diagnoses this inversion ambiguity;
% it is not by itself evidence that every feature in a measured ODF is
% correct after correction.

%% Further reading
%
% * S. Matthies,
% <https://doi.org/10.1002/pssb.2220920254 On the reproducibility of the
% orientation distribution function of texture samples from pole figures
% (ghost phenomena)>, _physica status solidi (b)_ 92, K135--K138, 1979.
% This paper introduced the ghost phenomenon.
% * S. Matthies and G. W. Vinel,
% <https://doi.org/10.1002/pssb.2221120254 On the reproduction of the
% orientation distribution function of texturized samples from reduced
% pole figures using the conception of a conditional ghost correction>,
% _physica status solidi (b)_ 112, K111--K114, 1982. This paper introduced
% the conditional correction used here.
% * R.-J. Roe,
% <https://doi.org/10.1063/1.1714396 Description of crystallite orientation
% in polycrystalline materials. III. General solution to pole figure
% inversion>, _Journal of Applied Physics_ 36, 2024--2031, 1965. This is
% the classical harmonic treatment of pole figure inversion.
% * R. Hielscher and H. Schaeben,
% <https://doi.org/10.1107/S0021889808030112 A novel pole figure inversion
% method: specification of the MTEX algorithm>, _Journal of Applied
% Crystallography_ 41, 1024--1037, 2008. This specifies the estimator and
% numerical method implemented by MTEX.

%% Next
%
% <PoleFigureSantaFe.html The Santa Fe Example> repeats the comparison on a
% standard model ODF with simulated counting noise. Then continue to
% <PoleFigureDubna.html The Dubna Example> for measured neutron-diffraction
% pole figures, where the true ODF is no longer available for comparison.

%#ok<*NOPTS>
