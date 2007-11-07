%% MTEX - Short Tutorial (Dubna)
% 
% How to use MTEX to estimate a ODF from diffraction data.

%% Import diffraction data
%

% specify scrystal and specimen symmetry
cs = symmetry('-3m',[1.4,1.4,1.5]);
ss = symmetry('tricline');

% specify file names
fname = {...
  [mtexDataPath '/dubna/Q(10-10)_amp.cnv'],...
  [mtexDataPath '/dubna/Q(10-11)(01-11)_amp.cnv'],...
  [mtexDataPath '/dubna/Q(11-22)_amp.cnv']};

% specify crystal directions
h = {Miller(1,0,-1,0,cs),[Miller(0,1,-1,1,cs),Miller(1,0,-1,1,cs)],Miller(1,1,-2,2,cs)};

% specify structure coefficients
c = {1,[0.52 ,1.23],1};

% import pole figure data
pf = loadPoleFigure(fname,h,cs,ss,'superposition',c,...
  'comment','Dubna Tutorial pole figures')

%% Plot pole figures

close;figure('position',[359 450 749 249])
plot(pf)

%% Estimate an ODF
odf = calcODF(pf,'resolution',10*degree,'iter_max',10)

%% Calculate c-axis pole figure from the ODF
plotpdf(odf,Miller(0,0,1,cs))

