%% Pole Figure Simulation
%
% MTEX allows to to simulate an arbitary number of pole figure data from
% any ODF. This is quit helpfull if you want to analyse the pole figure to
% ODF estimation routine.
%

%% Define an Model ODF
%
% Let us first define a superposition of model ODFs.

cs = symmetry('orthorhombic');
ss = symmetry('triclinic');
model_odf = 0.5*uniformODF(cs,ss) + ...
  0.05*fibreODF(Miller(1,0,0),xvector,cs,ss,'halfwidth',10*degree) + ...
  0.05*fibreODF(Miller(0,1,0),yvector,cs,ss,'halfwidth',10*degree) + ...
  0.05*fibreODF(Miller(0,0,1),zvector,cs,ss,'halfwidth',10*degree) + ...
  0.05*unimodalODF(axis2quat(xvector,45*degree),cs,ss,'halfwidth',15*degree) + ...
  0.3*unimodalODF(axis2quat(yvector,65*degree),cs,ss,'halfwidth',25*degree);
plotodf(model_odf,'sections',6,'silent')


%% Simulate Pole Figure Data
%
% In order to simulate fole figure data five thinks are required
%
% * an arbitrary ODF
% * a list of Miller indece
% * a grid of specimen directions
% * superposition coefficients (optional)
% * the magnitude of error (optional)
%

%%
% The list of <Miller_index.html Miller indece>

h = [Miller(1,1,1,cs),Miller(1,1,0,cs),Miller(1,0,1,cs),Miller(0,1,1,cs),...
  Miller(1,0,0,cs),Miller(0,1,0,cs),Miller(0,0,1,cs)];

%%
% The <S2Grid_index.html grid> of specimen directions

r = S2Grid('regular','resolution',5*degree);


%%
% Now the pole figures can be simulated using the command
% <ODF_simulatePoleFigure.html simulatePoleFigure>. 

pf = simulatePoleFigure(model_odf,h,r)

%%
% Add some noise to the data. Here assume that the mean intensity is 1000.

pf = noisepf(pf,1000);

%%
% Plot the simulated pole figures.

plot(pf)


%% ODF Estimation from Pole Figure Data
%
% From these simulated pole figures we can now estimate an ODF,

odf = calcODF(pf)


%%
% which can be plotted,

plotodf(odf,'sections',6,'silent')


%%
% and compared to the original model ODF.

calcerror(odf,model_odf,'resolution',5*degree)


%% Exploration of the relationship between estimation error and number of single orientations
%
% For a more systematic analysis of the estimation error we vary the number
% of pole figures used for ODF estimation from 1 to 7 and calculate for any
% number of pole figures the approximation error. Furthermore, we also
% apply ghost correction and compare the approximation error to the
% previous reconstructions.

e = [];
for i = 1:length(pf)

  odf = calcODF(pf(1:i),'silent');
  e(i,1) = calcerror(odf,model_odf,'resolution',2.5*degree);
  odf = calcODF(pf(1:i),'ghost_correction','silent');
  e(i,2) = calcerror(odf,model_odf,'resolution',2.5*degree);

end

%% 
% Plot the error in dependency of the number of single orientations.

close all;
plot(1:length(pf),e)
xlabel('Number of Pole Figures');
ylabel('Reconstruction Error');
legend({'Without Ghost Correction','With Ghost Correction'});
