%% The SantaFe example
%
% Simulate a set of pole figures for the SantaFe standard ODF, estimate
% an ODF and compare it to the inital SantaFe ODF.

%% Simulate pole figures

% get crystal and specimen symmetry
cs = get(SantaFe,'CS');
ss = get(SantaFe,'SS');

% crystal directions
h = [Miller(1,0,0,cs),Miller(1,1,0,cs),Miller(1,1,1,cs),Miller(2,1,1,cs)];

% specimen directions
r = S2Grid('equispaced','resolution',5*degree,'antipodal');

% pole figures
pf = simulatePoleFigure(SantaFe,h,r);

% add some noise
pf = noisepf(pf,100);

% plot them
close; figure('position',[100,100,800,300])
plot(pf)

%% ODF Estimation

rec = calcODF(pf)

%% ODF Estimation with Ghost Correction
rec2 = calcODF(pf,'ghost_correction')

%% Error analysis

% calculate RP error
calcerror(rec2,SantaFe)

% difference plot between meassured and recalculated pole figures
close; figure('position',[100,100,800,300])
plotDiff(pf,rec2)
 
%% Plot estimated pole figures

plotpdf(rec2,get(pf,'Miller'),'complete')

%% Plot estimated ODF (Ghost Corrected)

close; figure('position',[46 171 752 486]);
plot(rec2,'alpha','sections',18,'resolution',5*degree,...
     'projection','plain','gray','contourf','FontSize',10,'silent')


%% Plot odf

close; figure('position',[46 171 752 486]);
plot(SantaFe,'alpha','sections',18,...
     'projection','plain','gray','contourf','FontSize',10,'silent')
   
%% Plot Fourier Coefficients

%%
close all;
% true ODF
plotFourier(SantaFe,'bandwidth',32)
% keep plot for adding the next plots
hold all

% Without ghost correction:
plotFourier(rec,'bandwidth',32)

% With ghost correction:
plotFourier(rec2,'bandwidth',32)

legend({'true ODF','without ghost correction','with ghost correction'})
% next plot command overwrites plot
hold off
