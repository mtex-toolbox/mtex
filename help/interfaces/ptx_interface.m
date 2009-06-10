%% The PTX Data Interface
% 
% The following examples shows how to import a PTX data set.

%% specify crystal and specimen symmetries

cs = symmetry('-3m',[4.99,4.99,17]);
ss = symmetry;

%% specify the file names

fname = {...
  [mtexDataPath '/ptx/gt9104.ptx'],...
  [mtexDataPath '/ptx/gt9110.ptx'],...
  [mtexDataPath '/ptx/gt9202.ptx']};


%% import the data

pf = loadPoleFigure(fname,cs,ss);

%% plot data

close all; figure('position',[100 100 900 300])
plot(pf)

%% See also
% [[interfacesPoleFigure_index.html,interfaces]] [[loadPoleFigure.html,loadPoleFigure]]
% [[S2Grid_plot.html,plot]] [[symmetry_symmetry.html,symmetry]]

%% Specification
%
% * *.ptx - ascii files
% * one pole figures per file
%
%% Remarks
%
% * header is not read, it is always assumed to have 72 intensities for each
% * khi - angle to be read?
