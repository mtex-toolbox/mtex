%% Succesive refinement Demo

%% Open in Editor
%

%% Regular ODF estimation 
% Please refer to |PoleFigure2ODF| tutorial first. The regular way of
% estimating an ODF:

mtexdata dubna
odf_naive = calcODF(pf);

calcError(pf,odf_naive)

%%
% visual inspection

odf_naive.plot(pf.allH)

%%
% anthor form to regularize the inversion problem is to iteratively
% adjuste the kernel width during ODF estimation.

odf_iter = calcODFIterative(pf,'nothinning');

calcError(pf,odf_iter)

%%
% visual inspection

odf_iter.plot(pf.allH)

%%
% volume portion that is differently distributed between the two methods

calcError(odf_iter,odf_naive,'l1')

%%
% visual inspection indicates that the uniform portion is distributed
% differently

plot(calcPoleFigure(pf,odf_naive-odf_iter))
%plotDiff(odf_naive,odf_iter)

%% Some arbitrary modelODF of a somewhat sharp texture
% demonstrated the iterative ODF estimation with a synthetic data set.

cs = crystalSymmetry('cubic');
ss = specimenSymmetry;

q = rotation.byEuler(10*degree,10*degree,10*degree,'ABG');
q2 = rotation.byEuler(10*degree,30*degree,10*degree,'ABG');

odf_true = .6*unimodalODF(q,cs,ss,'halfwidth',5*degree) + ...
            .4*unimodalODF(q2,cs,ss,'halfwidth',4*degree);

%% Polefigures to measure 

h = [ ...
  Miller(1,1,1,cs), ...
  Miller(1,0,0,cs), ...
  Miller(1,1,0,cs), ...
  ];

figure, odf_true.plotPDF(h)

%% Initial measure grid

r = equispacedS2Grid('resolution',15*degree,'maxtheta',80*degree);

figure
plot(r,'markersize',12)

%% Refinement
% for selected directions r we perform a 'point' like  measurement.

r = equispacedS2Grid('resolution',15*degree,'maxtheta',80*degree);
r = repcell(r,size(h));
pf_measured = [];
pf_simulated = [];
pf_sim_h = {};
% number of refinement steps
nsteps = 5;

for k=1:nsteps
  
  % perform for every PoleFigure a measurement
  pf_simulated = calcPoleFigure(odf_true,h,r,'silent');
    
  % merge the new measurements with old ones
  pf_measured = union(pf_simulated,pf_measured);
  plot(pf_measured,'silent')
  drawnow

  fprintf('- at resolution : %f\n', mean(cellfun(@(r) r.resolution, pf_measured.allR))/degree);  
  
  if k < nsteps
    % odf modelling
    odf_recalc = calcODF(pf_measured,'zeroRange','silent');

    % in order to minimize the modelling error
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

%% Measured Polefigure

pf_measured
plot(pf_measured,'silent');

%% Final model
% the default odf estimation will distribute volume on nodes that do not
% have corresponding data. 

odf_recalc = calcODF(pf_measured,'zeroRange','halfwidth',2.5*degree);
fprintf('  error true -- estimated odf   : %f\n', calcError(odf_true,odf_recalc)) 

%% Compare with iterative odf estimation
% the iterative odf estimation will model the volume portions of nodes that
% do not have corresponding data by assuming volume portions coming from a
% broader halfwidth, thus the error to the true odf will be significantly
% smaller.

odf_recalc_iterative = calcODFIterative(pf_measured,'halfwidth',2.5*degree);
fprintf('  error true -- iter. est. odf  : %f\n', calcError(odf_true,odf_recalc_iterative)) 

%%
% volume portion that is differently distributed 

calcError(odf_recalc,odf_recalc_iterative,'l1')

