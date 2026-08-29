%% Successive Refinement of Pole Figure Reconstructions
%
%%
% <PoleFigure2ODF.html ODF Estimation> reconstructs an orientation
% distribution function (ODF) on one orientation grid with one kernel
% width. A kernel is the smooth component placed at each grid orientation.
% Its width sets the smallest scale that the reconstruction can represent.
%
% This page refines two different parts of that workflow. First,
% <PoleFigure.calcODFIterative.html |calcODFIterative|> keeps the
% measurements fixed while it successively narrows the kernel. Second, a
% simulation keeps the reconstruction method fixed while it adds
% measurements where the current ODF predicts high pole density.
%
% Successive kernel refinement is not the same as asking |calcODF| for more
% solver iterations. It changes the representation scale and uses each
% coarser solution to initialise the next one. Neither kind of refinement
% removes the non-uniqueness of pole figure inversion; see
% <PoleFigure2ODFAmbiguity.html The Ghost Effect>.

%% Adapting the kernel
%
% The seven measured Dubna pole figures provide a reference case. The
% ordinary reconstruction solves directly at its target resolution.

plottingConvention.default('y↑→x');
mtexdata dubna silent
odf_naive = calcODF(pf,'silent');

calcError(pf,odf_naive,'silent')

%%
% The seven values are the fit errors for the seven measured pole figures.
% Their recalculated pole figures are the visual baseline for the iterative
% result below.

plotPDF(odf_naive,pf.allH,'silent')

%%
% The iterative reconstruction starts from a uniform ODF. It solves first
% with a wide kernel, transfers those weights to a finer grid, narrows the
% kernel, and solves again. The coarse stages suppress fine-scale variation
% and provide informed starting weights for the finer stages.
%
% This scale progression acts as a regularisation strategy for irregularly
% sampled data. It does not replace ghost correction. The |'nothinning'|
% flag retains low-weight grid nodes so that this comparison isolates the
% effect of the changing scale.

odf_iter = calcODFIterative(pf,'nothinning');

calcError(pf,odf_iter,'silent')

%%
% One fit error is reported per pole figure. All seven are smaller than those
% from the ordinary reconstruction, in places by nearly a factor of two.

plotPDF(odf_iter,pf.allH,'silent')

%%
% The peak positions in the two galleries are similar. The error values
% show that their intensities are not, so a visual match alone is not enough
% to compare reconstructions. Their L1 difference measures how much ODF
% volume is distributed differently.

calcError(odf_iter,odf_naive,'l1')

%%
% Sixteen percent of the volume sits in different places in the two
% reconstructions. Recalculating pole figures from their signed difference
% shows where that volume moved. The printed values give the minimum, mean,
% and maximum difference over all seven pole figures.

pf_difference = calcPoleFigure(pf,odf_naive-odf_iter);
plot(pf_difference)
differenceIntensity = pf_difference.intensities;
fprintf('pole figure difference min / mean / max : %.2f / %.2f / %.2f\n', ...
  min(differenceIntensity(:)),mean(differenceIntensity(:)), ...
  max(differenceIntensity(:)))

%%
% The range from -1.09 to 0.63 is centred at 0.00. Broad, smooth
% differences extend across the sphere instead of concentrating at the
% texture maxima. Compare the centre of each pole figure with its rim.
%
% This is the appearance of a differently distributed uniform portion. It
% is the part of an ODF that pole figures constrain least, which is why a
% smaller fit error does not prove that the reconstructed ODF is closer to
% the unknown true ODF.

%% Adapting the measurement
%
% The rest of the page uses a simulation so that the true ODF is known.
% <PoleFigureSimulation.html Simulating Pole Figure Data> develops this
% validation strategy. Here the model has two sharp components, and pole
% figures can be evaluated at whichever specimen directions are selected.

cs = crystalSymmetry('cubic');
plottingConvention.default('y↑→x');
ss = specimenSymmetry;

q = rotation.byEuler(10*degree,10*degree,10*degree,'ABG');
q2 = rotation.byEuler(10*degree,30*degree,10*degree,'ABG');

odf_true = .6*unimodalODF(q,cs,ss,'halfwidth',5*degree) + ...
            .4*unimodalODF(q2,cs,ss,'halfwidth',4*degree);

%%
% Three lattice planes will be measured.

h = [ ...
  Miller(1,1,1,cs), ...
  Miller(1,0,0,cs), ...
  Miller(1,1,0,cs), ...
  ];

plotPDF(odf_true,h,'silent')

%%
% The compact maxima reflect the 4 and 5 degree component halfwidths. They
% are the features that a coarse measurement must first locate and then
% sample more densely.

%% The initial measurement grid
%
% The first scan uses a nearly equispaced 15 degree grid out to a specimen
% tilt of 80 degrees.

r = equispacedS2Grid('resolution',15*degree,'maxTheta',80*degree);

plot(r,'MarkerSize',12,'upper')

%%
% The points cover the accessible cap uniformly. The gaps between them are
% deliberately much wider than the sharp model components.

%% The refinement loop
%
% Each round measures the current directions and merges them with all
% earlier measurements. An ordinary reconstruction then predicts the pole
% density at the directions inserted by <vector3d.refine.html |refine|>.
% Only the quarter with the highest predicted intensity is measured in the
% next round. Five rounds are used here.
%
% This highest-intensity rule is deliberately naive. It exploits the
% current estimate but does not account for uncertainty, counting noise,
% acquisition cost, or the possibility that the current estimate missed a
% component. It demonstrates adaptive sampling, not a general experimental
% design prescription.

r = equispacedS2Grid('resolution',15*degree,'maxTheta',80*degree);
r = repcell(r,size(h));
pf_measured = [];
nsteps = 5;

for k = 1:nsteps

  % simulate the new measurements
  pf_simulated = calcPoleFigure(odf_true,h,r,'silent');

  % merge new and previous measurements
  pf_measured = union(pf_simulated,pf_measured);
  plot(pf_measured,'silent')
  drawnow

  meanResolution = mean(cellfun(@(r) r.resolution,pf_measured.allR));
  fprintf('- mean sampling resolution : %f\n',meanResolution/degree);

  if k < nsteps
    % reconstruct from all measurements collected so far
    odf_recalc = calcODF(pf_measured,'zeroRange','silent');
    fprintf('  error true -- estimated odf   : %f\n', ...
      calcError(odf_true,odf_recalc,'silent'))

    % select high-intensity directions from the refined grids
    for l = 1:length(h)
      r_old = pf_measured{l}.r;
      [~,r_new] = refine(r_old(:));
      pf_predicted = calcPoleFigure(odf_recalc,h(l),r_new,'silent');
      threshold = quantile(pf_predicted.intensities,0.75);
      r{l} = pf_predicted.r(pf_predicted.intensities > threshold);
    end
  end
end

%%
% Every round prints the mean resolution of the three accumulated direction
% sets. This single value summarises an irregular sampling pattern; it does
% not mean that neighbouring points are that far apart everywhere.
%
% The mean resolution falls from 14.5 to 3.7 degrees. The four interim ODF
% errors are 0.95, 0.41, 0.24, and 0.31. A real experiment could not compute
% these errors because its true ODF is unknown.
%
% That rise is the point of the demonstration. The measurement is now dense
% where the texture is strong and coarse everywhere else. An ordinary
% fine-grid reconstruction then puts ODF components at orientations that
% the sparse regions do not constrain.

%% What was measured
%
% The object summary gives the number of accumulated directions for each
% pole figure. The sampling pattern is no longer a regular grid.

pf_measured
plot(pf_measured,'silent')

%%
% Dense clusters surround the predicted poles of the two components. The
% original coarse coverage remains between them. This uneven coverage is
% exactly the case for which successive kernel refinement is useful. Within
% each cluster, the colours rise towards a predicted pole-density maximum.

%% Reconstructing from the irregular measurement
%
% First use an ordinary reconstruction at the 2.5 degree resolution that
% the dense regions can support.

odf_recalc = calcODF(pf_measured,'zeroRange','resolution',2.5*degree, ...
  'silent');
fprintf('  error true -- estimated odf   : %f\n', ...
  calcError(odf_true,odf_recalc))

%%
% The iterative reconstruction reaches the same target scale through a
% sequence of wider kernels. Sparse regions inherit the broad distribution
% established at coarse scale instead of being determined only at the
% finest scale.

odf_recalc_iterative = calcODFIterative(pf_measured, ...
  'halfwidth',2.5*degree);
fprintf('  error true -- iter. est. odf  : %f\n', ...
  calcError(odf_true,odf_recalc_iterative))

%%
% The errors are 0.11 and 0.41. The iterative error is less than one third
% of the direct error from the same measurements. The L1 distance below
% shows how much the two estimated ODFs distribute differently.

calcError(odf_recalc,odf_recalc_iterative,'l1')

%%
% About a third of the volume is placed differently. On an unevenly sampled
% measurement, the choice between a direct fine-scale solve and successive
% refinement is therefore part of the model, not an implementation detail.

%% Further reading
%
% * R. Hielscher and H. Schaeben,
% <https://doi.org/10.1107/S0021889808030112 A Novel Pole Figure Inversion
% Method: Specification of the MTEX Algorithm>, _Journal of Applied
% Crystallography_ 41 (2008), 1024-1037. This paper derives the component
% method used by |calcODF| for sharp textures and irregular specimen
% directions.
% * F. Bachmann,
% <https://doi.org/10.1007/978-3-658-14941-3_4 Texturbestimmung aus
% Beugungsbildern>, in _Optimierung der Goniometrie zur Texturbestimmung aus
% Röntgenbeugungsbildern_, Springer Spektrum, 2016, pp. 79-106. This chapter
% describes the reconstruction strategy behind |calcODFIterative|.
% * ASTM International,
% <https://doi.org/10.1520/E0081-96R24 ASTM E81-96(2024): Standard Test
% Method for Preparing Quantitative Pole Figures>. This standard covers
% X-ray acquisition procedures. It does not prescribe an inversion method
% or the adaptive sampling rule demonstrated here.

%% Next
%
% <PoleFigureSimulation.html Simulating Pole Figure Data> adds counting
% noise and asks how many pole figures a reconstruction needs. Then return
% to <PoleFigure2ODFAmbiguity.html The Ghost Effect> for the information
% that no refinement of measurement density can recover.
