%% The Philips Data Interface
% An examples how to import Philips data.
%
%% specify crystal and specimen symmetries

cs = symmetry('cubic');
ss = symmetry;

%% specify the file names

fname = {...
  [mtexDataPath '/philips/NiR-700-111.txt'],...
  [mtexDataPath '/philips/NiR-700-200.txt'],...
  [mtexDataPath '/philips/NiR-700-220.txt']};

%% import the data

pf = loadPoleFigure(fname,cs,ss);

%% plot data

close; figure('position',[100,100,800,300]);
plot(pf)

%% See also
% [[interfacesPoleFigure_index.html,interfaces]] [[loadPoleFigure.html,loadPoleFigure]]
% [[S2Grid_plot.html,plot]] [[symmetry_symmetry.html,symmetry]]

%% Specification
%
% * *.txt - ascii files
% * one pole figures per file
%
