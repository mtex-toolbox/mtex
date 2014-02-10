%% Succesive refinement Demo

%% Open in Editor
%

%% Some arbitrary modelODF


cs = symmetry('cubic');
ss = symmetry;

q = Euler(10*degree,10*degree,10*degree,'ABG');
q2 =  Euler(10*degree,30*degree,10*degree,'ABG');

odf_true = .6*unimodalODF(q,cs,ss,'halfwidth',5*degree) + ...
            .4*unimodalODF(q2,cs,ss,'halfwidth',4*degree)
         

%% Polefigures to measure 

h = [ ...
  Miller(1,1,1,cs), ...
  Miller(1,0,0,cs), ...
  Miller(1,1,0,cs), ...
  ];

figure, plotpdf(odf_true,h)


%% Initial measure grid

r = equispacedS2Grid('resolution',15*degree,'antipodal');

figure
plot(r,'markersize',12)

%% Refinement
% for selected directions r we perform a 'point' like  measurement.

r = repcell(r,size(h));
pf_measured = [];

% number of refinement steps
nsteps = 5;

for k=1:nsteps
  
  % perform for every PoleFigure a measurement
  for l=1:length(h)
    pf_simulated(l) = calcPoleFigure(odf_true,h(l),r{l});
  end
    
  % merge the new measurements with old ones
  pf_measured = union(pf_simulated,pf_measured);  
  
  fprintf('--- at resolution : %f\n', pf_measured.r.resolution/degree);
  
  if k < nsteps
    % odf modelling
    odf_recalc = calcODF(pf_measured,'silent');

    % in order to minimize the modelling error
    pf_recalcerror  = calcErrorPF(pf_measured,odf_recalc,'l1','silent');  
    odf_recalcerror = calcODF(pf_recalcerror,'silent');
    
    % the error we don't know actually
    fprintf('  error true -- estimated odf   : %f\n', calcError(odf_true,odf_recalc)) 
    
    % refine the grid for every polefigure
    for l=1:length(h)   
      
      r_new = get(pf_measured(l),'r');
      [newS2G r_new] = refine(  r_new );
            
      % selection of points of interest
      pf_sim(l) = calcPoleFigure(odf_recalc, h(l),  S2Grid(r_new));
      pf_sim(l) = quantile(pf_sim(l),0.15);
      
      Z = slope(odf_recalcerror, h(l), r_new);
      pf_slope(l) = PoleFigure(h(l),S2Grid(r_new),Z,cs,ss);
      pf_slope(l) = quantile(pf_slope(l),0.15);
      
      r{l} = unique([get(pf_sim(l),'r') get(pf_slope(l),'r')]);
      
    end    
  end  

end

% final model
odf_recalc = calcODF(pf_measured,'zero_range','silent');
fprintf('  error true -- estimated odf   : %f\n', calcError(odf_true,odf_recalc)) 


%% Measured Polefigure

pf_measured
plot(pf_measured,'silent');

%% Compared to a dense measured Polefigure
%

r = equispacedS2Grid('resolution',get(pf_measured,'resolution'));
for l=1:length(h)
  pf_simulated(l) = calcPoleFigure(odf_true,h(l),r);
end

odf_measuredfull = calcODF(pf_simulated,'zero_range','silent');

fprintf('  error true -- estimated odf on dense grid  : %f\n',...
  calcError(odf_true,odf_measuredfull)) 

fprintf('  error sparse -- dense gird                 : %f\n',...
  calcError(odf_recalc,odf_measuredfull)) 


%%
% percentage of full grid

GridLength(pf_measured)./GridLength(pf_simulated)

%%
% true odf
figure, plot(odf_true,'sections',9)

%%
% modelled odf
figure, plot(odf_recalc,'sections',9)


