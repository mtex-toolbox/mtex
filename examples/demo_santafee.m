%% The santafee example
%
% Simulate a set of pole figures for the Santafee standard ODF, estimate
% an ODF and compare it to the inital Santafee ODF.

%% Simulate pole figures

% get crystal and specimen symmetry
[cs,ss] = getSym(santafee);

% crystal directions
h = [Miller(1,0,0,cs),Miller(1,1,0,cs),Miller(1,1,1,cs),Miller(2,1,1,cs)];

% specimen directions
r = S2Grid('resolution',5*degree);

% pole figures
pf = simulatePoleFigure(santafee,h,r);

% add some noise
pf = noisepf(pf,100);

% plot them
close; figure('position',[100,100,800,300])
plot(pf)

%% ODF Estimation

rec = calcODF(pf,'RESOLUTION',10*degree,'background',1,'iter_max',6)

%% ODF Estimation with Ghost Correction
rec2 = calcODF(pf,'RESOLUTION',10*degree,'background',10,'iter_max',6,'ghost_correction')

%% Error analysis

% calculate RP error
calcerror(rec,santafee)

% difference plot between meassured and recalculated pole figures
close; figure('position',[100,100,800,300])
plotDiff(pf,rec)
 
%% Plot estimated pole figures

plotpdf(rec,getMiller(pf),'complete')

%% Plot estimated ODF (Ghost Corrected)

close; figure('position',[46 171 752 486]);
plot(rec2,'alpha','sections',18,'resolution',5*degree,...
     'plain','gray','contourf','FontSize',10)


%% Plot odf

close; figure('position',[46 171 752 486]);
plot(santafee,'alpha','sections',18,...
     'plain','gray','contourf','FontSize',10)
   
