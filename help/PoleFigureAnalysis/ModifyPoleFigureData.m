%% Modify Pole Figure Data
% 
% This section explains how one can manipulate pole figure data in MTEX.

%% Import diffraction data
%
% Let us therefore import some data and plot them.

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

% plot raw data
figure('position',[359 450 749 249])
plot(pf)

%% Correct Pole figure data



%% Remove certain measurements from the data
%

% get theta angle
theta = get(pf,'theta');

% remove all measurement that have theta angle between 70 and 75 degree
pf_corrected = delete(pf,theta > 69*degree & theta < 76*degree);

plot(pf_corrected)

%% Rotate pole figures

pf_rotated = rotate(pf_corrected,axis2quat(xvector,45*degree));
plot(pf_rotated,'reduced')

