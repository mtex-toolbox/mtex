%% The Dubna Data Interface
%  
% The following examples shows how to import a Dubna data set.

%% specify crystal and specimen symmetries

cs = symmetry('-3m',[1.4,1.4,1.5]);
ss = symmetry('triclinic');

%% specify the file names

fname = {[mtexDataPath '/dubna/Q(10-10)_amp.cnv'],...
  [mtexDataPath '/dubna/Q(10-11)(01-11)_amp.cnv'],...
  [mtexDataPath '/dubna/Q(11-22)_amp.cnv']};

%% specify crystal directions

h = {Miller(1,0,-1,0,cs),...
  [Miller(0,1,-1,1,cs),Miller(1,0,-1,1,cs)],...
  Miller(1,1,-2,2,cs)};

%% specifiy structural coefficients for superposed pole figures

c = {1,[0.52 ,1.23],1};

%% import the data

pf = loadPoleFigure(fname,h,cs,ss,'superposition',c);

%% plot data

close; figure('position',[100,100,800,300]);
plot(pf)

%% See also
% [[interfaces_index.html,interfaces]] [[loadPoleFigure.html,loadPoleFigure]]
% [[S2Grid_plot.html,plot]] [[symmetry_symmetry.html,symmetry]]
% [[Miller_Miller.html,Miller]]

%% Specification
%
% * *.cnv ascii-files 
% * one pole figures per file
%
