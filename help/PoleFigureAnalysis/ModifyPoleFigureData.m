%% Modify Pole Figure Data
% 
% This section explains how to manipulate pole figure data in MTEX.

%% Import diffraction data
%
% Let us therefore import some data and plot them.


% specify crystal and specimen symmetries
cs = symmetry('m-3m');
ss = symmetry('-1');

% specify file name
fname = [mtexDataPath '/geesthacht/ST42-104-110.dat'];

% specify crystal directions
h = { ...
  Miller(1,0,4,cs), ...
  Miller(1,0,4,cs), ...
  Miller(1,1,0,cs), ...
  Miller(1,1,0,cs), ...
  };

% import the data
pf = loadPoleFigure(fname,h,cs,ss);

% plot imported polefigure
plot(pf)


%% Splitting and Reordering of Pole Figures
% As we can see the first and the third pole figure complete pole figures
% and the second and the fourth pole figure contain some values for
% background correction. Let us therefore split the pole figures into
% these two groups. 

pf_complete = pf([1 3]);
pf_background= pf([2 4]);

%%
% Actually it is possible to work with pole figures as with simple numbers.
% E.g. it is possible to 


%% Correct Pole figure data
% In order to correct the pole figures we have use the command
% <PoleFigure_correct.html correct>, which also allows for defocusing
% correction.

pf = correct(pf_complete,'background',pf_background);
plot(pf)

%% Modify certain pole figure values

 


%% Remove certain measurements from the data
% A comon problem in pole figure analysis is to detect outiers and to
% remove them from the data. In order to demonstrate this procedure in MTEX
% let us first add outlier to the data.





% get theta angle
theta = get(pf,'theta');

% remove all measurement that have theta angle between 70 and 75 degree
pf_corrected = delete(pf,theta > 69*degree & theta < 76*degree);

plot(pf_corrected)

%% Rotate pole figures
% Sometimes it is neccasary to rotate the pole figures. In order to do this
% with MTEX on has first to define a rotation, e.e. by

% This defines a rotation around the x-axis about 100 degree
q = axis2quat(xvector,100*degree);

%%
% Second, the command <PoleFigure_rotate rotate> can be used to rotate the
% pole figure data.
pf_rotated = rotate(pf,q);
plot(pf_rotated,'reduced')



