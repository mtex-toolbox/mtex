function f = example(varargin)
% Construct the odf from the dubna data set as example for an SO3FunRBF.

CS = crystalSymmetry('-3m',[4.9 4.9 5.4]);
SS = specimenSymmetry;

% specify file names
fname = {...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(10-10)_amp.cnv'),...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(10-11)(01-11)_amp.cnv'),...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(11-22)_amp.cnv')};

% specify crystal directions
h = {Miller(1,0,-1,0,CS),...
     [Miller(0,1,-1,1,CS),Miller(1,0,-1,1,CS)],... % superposed pole figures
     Miller(1,1,-2,2,CS)};

% specify structure coefficients
c = {1,[0.52 ,1.23],1};

% import data
pf = PoleFigure.load(fname,h,CS,SS,'interface','dubna','superposition',c);

[~,f] = evalc('calcODF(pf)');

end