%% ptx data interface
%
% The following examples shows how to import a Trullenque data set.

%% specify crystal and specimen symmetries

cs = symmetry('cubic');
ss = symmetry;

%% specify the file names

fname = {...
  [mtexDataPath '/trullenque/GT104.PTX'],...
  [mtexDataPath '/trullenque/GT110.PTX'],...
  [mtexDataPath '/trullenque/GT202.PTX']};

%% import the data

pf = loadPoleFigure(fname,cs,ss);

%% plot data

plot(pf)

%% See also
% [[interfaces_index.html,interfaces]] [[loadPoleFigure.html,loadPoleFigure]]
% [[S2Grid_plot.html,plot]] [[symmetry_symmetry.html,symmetry]]

%% Specification
%
% * *.ptx - ascii files
% * one pole figures per file
%
%% Remarks
%
% * header is not read, it is always assumed to have 72 intensities for each
% * khi - angle
%
