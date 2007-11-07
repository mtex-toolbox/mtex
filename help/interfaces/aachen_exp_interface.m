%% Aachen_exp data interface
% 
% The following examples shows how to import a Aachen_exp data set.

%% specify crystal and specimen symmetries

cs = symmetry('cubic');
ss = symmetry;

%% specify the file names
fname1 = [mtexDataPath '/aachen_exp/HCP.exp'];
fname2 = [mtexDataPath '/aachen_exp/FCC.exp'];

%% import the data

pf1 = loadPoleFigure(fname1,cs,ss);
pf2 = loadPoleFigure(fname2,cs,ss);

%% plot data of pole figure 1

plot(pf1)

%% plot data of pole figure 2

close; figure('position',[100,100,600,500]);
plot(pf2)

%% See also
% [[interfaces_index.html,interfaces]] [[loadPoleFigure.html,loadPoleFigure]]
% [[S2Grid_plot.html,plot]] [[symmetry_symmetry.html,symmetry]]


%% Specification
% * *.exp txt-files
% * many pole figures per file
% * three headerlines per pole figure
% * specimen grid specified in the second headerline
%
%% Questions:
%
% * 4 Miller indece????? (0,1,0,1)
% * superposed pole figures
%