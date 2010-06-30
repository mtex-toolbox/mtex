%% Aachen_exp Interface
% An examples how to import Aachen_exp data.
%
%% Specify Crystal and Specimen Symmetries

cs = symmetry('cubic');
ss = symmetry;


%% Specify File Name

fname = [mtexDataPath '/aachen_exp/HCP.exp'];


%% Import Data

pf = loadPoleFigure(fname,cs,ss);


%% Plot Pole Figures

plot(pf)


%% See also
% [[interfacesPoleFigure_index.html,interfaces]] [[loadPoleFigure.html,loadPoleFigure]]
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
