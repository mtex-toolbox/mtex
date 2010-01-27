%% MTEX - Analysing Neutron Pole Figures (Dubna)
%
% Detailed demonstration of the MTEX toolbox at the Dubna data example.
%
% The data where meassured by Florian Wobbe at Dubna 2005 of a Quarz
% specimen using Neutron diffraction.


%% Import diffraction data
%

% specify scrystal and specimen symmetry
cs = symmetry('-3m',[1.4,1.4,1.5]);
ss = symmetry('triclinic');

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
pf = loadPoleFigure(fname,h,cs,ss,'superposition',c)

%% plot pole figures

figure('position',[359 450 749 249])
plot(pf)

%% Analyse pole figures

clf
hist(pf)

%% Correct pole figures

pf_corrected = delete(pf,getTheta(getr(pf)) >= 70*degree &...
  getTheta(getr(pf)) <= 75*degree);

plot(pf_corrected)

%% Rotate pole figures

pf_rotated = rotate(pf_corrected,axis2quat(xvector,45*degree));
plot(pf_rotated,'antipodal')

%% Recalculate ODF
%
% We use here the option 'background' to specify the approximative
% background radiation and to increase the accuracy of the reconstruction.
% Furthermore, we have seen from the pole figures that the ODF is quit
% sharp and hence using the zero range method reduces the computational
% time.

odf = calcODF(pf_corrected,'background',10,'zero_range')

%% Error analysis

% calc RP1 error
calcerror(pf_corrected,odf,'RP',1)

% difference plot
plotDiff(pf,odf)


%% Recalculate c-axis pole figures

plotpdf(odf,Miller(0,0,1,cs),'antipodal')


%% Plot inverse pole figure

plotipdf(odf,vector3d(1,1,2))

%% plot recalculated ODF

close all;figure('position',[15 111 920 508])
plot(odf,'sections',18,'silent')

%% rotate ODF back

odfrotated = rotate(odf,axis2quat(xvector,45*degree));
plotpdf(odfrotated,getMiller(pf),'antipodal');
annotate(modalorientation(odfrotated),'marker','d');

%% volume analysis

volume(odf,modalorientation(odf),20*degree)
