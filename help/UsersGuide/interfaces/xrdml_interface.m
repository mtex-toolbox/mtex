%% XRDML Interface
% An examples how to import XRDML data.
%

%% Specify Crystal and Specimen Symmetries

cs = symmetry('cubic');
ss = symmetry;


%% Specify File Names

fname = [mtexDataPath '/xrdml/Cu-111 Standard Tex-Pol-C 3degree.xrdml'];


%% Import Data

%pf = loadPoleFigure(fname,cs,ss,'interface','xrdml');


%% Plot Pole Figure

%plot(pf)


%% See Also
% [[interfacesPoleFigure_index.html,interfaces]] [[loadPoleFigure.html,loadPoleFigure]]
% [[S2Grid_plot.html,plot]] [[symmetry_symmetry.html,symmetry]]

