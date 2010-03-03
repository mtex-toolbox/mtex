%% Orientation Density Functions
%
%% Abstract
% This example demonstrates the most important MTEX tools for analysing
% Pole Figure Data.

%% Import Pole Figures

% specify crystal and specimen symmetry
CS = symmetry('-3m',[1.4 1.4 1.5]);
SS = symmetry;

% specify file names
fname = {...
  [mtexDataPath '/dubna/Q(10-10)_amp.cnv'],...
  [mtexDataPath '/dubna/Q(10-11)(01-11)_amp.cnv'],...
  [mtexDataPath '/dubna/Q(11-22)_amp.cnv']};

% specify crystal directions
h = {Miller(1,0,-1,0,CS),...
     [Miller(0,1,-1,1,CS),Miller(1,0,-1,1,CS)],... % superposed pole figures
     Miller(1,1,-2,2,CS)};

% specify structure coefficients
c = {1,[0.52 ,1.23],1};

% import data
pf = loadPoleFigure(fname,h,CS,SS,'superposition',c);

close;figure('position',[43   362   1005   353])
plot(pf)


%% Extract information from imported pole figure data
%
% *get raw data*

I = get(pf,'intensities'); % intensities
h = get(pf,'Miller')       % Miller indice
r = get(pf,'r')            % specimen directions

%%
% *basic statistics*

min(pf)
max(pf)
hist(pf)
find_outlier(pf)

%% Manipulate pole figure data
%
% *Correct data*

pf = 2*pf1 + 5*pf2;
pf = [pf1,pf2];
pf = pf([1,3,5]);

%%
% *sdf*

scale(pf,alpha),
union(pf1,pf2),
pf = delete(pf,indices)
pf = rotate(pf,q)
pf = set(pf,'data',value,indices)

%%

[theta,rho] = get(pf,'polar');
pf_modified = delete(pf,theta >= 70*degree & theta <= 75*degree)

plot(pf_modified)

%%
rot = rotation('axis', xvector-yvector,'angle',25*degree);
pf_modified = rotate(pf,rot)

plot(pf_modified)

%% PDF - to - ODF Reconstruction


rec = calcODF(pf,'RESOLUTION',10*degree,'background',1,'iter_max',6)

plotpdf(rec,h)


%%
%
% define specimen directions
r = S2Grid('regular','antipodal')
pf_santafee = simulatePoleFigure(santafee,r);

rec = calcODF(pf_santafee,'RESOLUTION',10*degree,...
 'background',10,'iter_max',6)

plotodf(rec,'sections',6)

%%
%
rec_corrected = calcODF(pf_santafee,'RESOLUTION',10*degree,...
 'background',10,'iter_max',6,'ghost_correction')

plotodf(rec,'sections',6)


%% Error Analysis


calcerror(pf_santafee,rec)
calcerror(pf_santafee,rec_corrected)

%%
% *Difference plot*

plotDiff(pf,rec)


%%
% *ODF error*

calcError(santafee,rec)
calcError(santafee,rec_corrected)

%% Exercises
%
% 3)
%
% a) Load the pole figure data of a quartz specimen from: data/dubna!

%%
% b) Inspect the raw data. Are there noticeable problems?

%%
% c) Compute an ODF from the pole figure data.

%%
% d) Plot some pole figures of that ODF and compare them to the measured
% pole figures.

%%
% e) Compute the RP errors for each pole figure.

%%
% f) Plot the difference between the raw data and the calculated pole
% figures. What do you observe?

%%
% g) Remove the erroneous values from the pole figure data and repeat the
% ODF calculation. How do the RP error change?

%%
% h) Vary the number of pole figures used for the ODF calculation. What is
% the minimum set of pole figures needed to obtain a meaningful ODF?


