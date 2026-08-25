%% Successive Refinement Demo
%
%%
% The reconstruction of <PoleFigure2ODF.html the previous page> puts the
% components of the ODF on a fixed grid of a fixed width and solves once.
% Two things can be improved on that, and this page demonstrates both.
%
% The first is to let the *kernel* adapt during the reconstruction rather
% than fixing it in advance, which is what
% <PoleFigure.calcODFIterative.html |calcODFIterative|> does. The second is
% to let the *measurement* adapt: measure coarsely, reconstruct, and spend
% the next measurements where the current estimate says something is
% happening.

%% Adapting the kernel
%
% The ordinary reconstruction of the Dubna data, for reference:

plottingConvention.default("y↑→x");
mtexdata dubna
odf_naive = calcODF(pf);

calcError(pf,odf_naive)

%%

plotPDF(odf_naive,pf.allH)

%%
% The iterative estimation instead starts from a wide kernel and narrows it,
% reconstructing at each width. A wide kernel cannot produce ghosts or
% spurious detail, and each step starts from a solution that is already
% roughly right.

odf_iter = calcODFIterative(pf,'nothinning');

calcError(pf,odf_iter)

%%
% Every one of the seven pole figures is fitted better, in places by nearly
% a factor of two.

plotPDF(odf_iter,pf.allH)

%%
% The two ODFs are not the same function. Their L1 difference:

calcError(odf_iter,odf_naive,'l1')

%%
% Sixteen percent of the volume sits in different places in the two
% reconstructions. Recalculating pole figures from the *difference* of the
% two shows where.

plot(calcPoleFigure(pf,odf_naive-odf_iter))

%%
% The difference runs from -1.1 to 0.6 about a mean of zero, and it is
% spread in broad smooth patterns over the whole sphere rather than
% concentrated at the texture maxima - the centre of each figure against its
% rim. That is what a differently distributed uniform portion looks like,
% the part of an ODF that pole figures constrain least, and the subject of
% <PoleFigure2ODFAmbiguity.html The Ghost Effect>.

%% Adapting the measurement
%
% The rest of this page is a simulation, so that the true answer is known: a
% model ODF of two sharp components, from which pole figures are computed at
% whatever directions we ask for.

cs = crystalSymmetry('cubic');
plottingConvention.default('y↑→x')
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

plotPDF(odf_true,h)

%%
% The measurement starts on a coarse grid of 15 degrees, the kind of grid a
% first scan would use.

r = equispacedS2Grid('resolution',15*degree,'maxtheta',80*degree);

plot(r,'markersize',12,'upper')

%% The refinement loop
%
% Each round measures the current set of directions, reconstructs an ODF
% from everything measured so far, and then chooses the directions for the
% next round: the grid is refined everywhere, and the quarter of the new
% points where the current estimate predicts the highest intensity is kept.
% Five rounds.

r = equispacedS2Grid('resolution',15*degree,'maxtheta',80*degree);
r = repcell(r,size(h));
pf_measured = [];
pf_simulated = [];
pf_sim_h = {};
% number of refinement steps
nsteps = 5;

for k=1:nsteps

  % perform for every Pole Figure a measurement
  pf_simulated = calcPoleFigure(odf_true,h,r,'silent');

  % merge the new measurements with old ones
  pf_measured = union(pf_simulated,pf_measured);
  plot(pf_measured,'silent')
  drawnow

  fprintf('- at resolution : %f\n', mean(cellfun(@(r) r.resolution, pf_measured.allR))/degree);

  if k < nsteps
    % odf modeling
    odf_recalc = calcODF(pf_measured,'zeroRange','silent');

    % in order to minimize the modeling error
    pf_recalcerror  = calcErrorPF(pf_measured,odf_recalc,'l1','silent');

    % we could initialized initial weights with previous estimation
    odf_recalcerror = calcODF(pf_recalcerror,'silent');

    % the error we don't know actually
    fprintf('  error true -- estimated odf   : %f\n', calcError(odf_true,odf_recalc,'silent'))

    % refine the grid for every polefigure
    for l=1:length(h)
      r_old = pf_measured{l}.r;
      [newS2G, r_new] = refine( r_old(:) );

      % selection of points of interest, naive criterion
      pf_sim_h = calcPoleFigure(odf_recalc, h(l),  r_new,'silent');
      th = quantile(pf_sim_h.intensities,0.75);
      r{l} = pf_sim_h.r(pf_sim_h.intensities > th);
    end
  end
end

%%
% Two numbers are printed per round. The mean resolution of everything
% measured so far falls from 14.5 to 3.7 degrees, and the error against the
% true ODF - which a real experiment could not compute - falls from 0.95 to
% 0.24 and then rises again to 0.41.
%
% That rise is the point of the demonstration. The measurement is now dense
% where the texture is strong and coarse everywhere else, and the ordinary
% reconstruction puts ODF components on nodes that no measurement
% constrains.

%% What was measured
%
% The accumulated measurement is anything but a grid.

pf_measured
plot(pf_measured,'silent')

%%
% Dense clusters around the poles of the two components, and the original
% coarse grid everywhere else.

%% Reconstructing from it
%
% At the resolution the dense parts now support, 2.5 degrees:

odf_recalc = calcODF(pf_measured,'zeroRange','resolution',2.5*degree);
fprintf('  error true -- estimated odf   : %f\n', calcError(odf_true,odf_recalc))

%%
% The iterative estimation, which reaches that resolution through a sequence
% of wider kernels, handles the unconstrained nodes far better: they inherit
% the volume of the wider kernel that covered them instead of being fitted
% from nothing.

odf_recalc_iterative = calcODFIterative(pf_measured,'halfwidth',2.5*degree);
fprintf('  error true -- iter. est. odf  : %f\n', calcError(odf_true,odf_recalc_iterative))

%%
% 0.11 against 0.41 - a quarter of the error, from the same measurements.
%
% How much volume the two reconstructions place differently:

calcError(odf_recalc,odf_recalc_iterative,'l1')

%%
% A third of it. On an unevenly sampled measurement the choice of estimator
% is not a detail.
