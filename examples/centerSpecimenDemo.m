%% Demo for centering ODF with orthorhombic specimen symmetry
%

%% Open in Editor
%

%% A synthetic example

%%
% some preliminary variables

%plotx2north

CS = crystalSymmetry('cubic');
SS = specimenSymmetry('222');
h = [Miller(1,1,1,CS),Miller(2,0,0,CS),Miller(2,2,0,CS)];


%%
% setup some rotations for a model odf with specimen symmetry

o = SS * [orientation('euler',135*degree,45*degree,120*degree,CS) ...
  orientation('euler', 60*degree, 54.73*degree, 45*degree,CS) ...
  orientation('euler',70*degree,90*degree,45*degree,CS)...
  orientation('euler',0*degree,0*degree,0*degree,CS)];

%%
% a model odf (equal volume portion for all orientations)

% odf = unimodalODF(SO3Grid(r(:),CS),CS,symmetry,'halfwidth',10*degree)

%%
% ideal case = full symmetric, orientations have just different volume portions
c = repmat([.4,.13,.4,.07],4,1)./4;

%%
% test case, some asymmetric volume portions

c = [[.3,.13,.4,.1]
  [.3,.13,.4,.0]
  [.5,.13,.3,0]
  [.5,.13,.3,.1]];
c = c./sum(c(:)); % adjust weight to 1

%%
% the model

psi = deLaValeePoussinKernel('halfwidth',12*degree);
odf = unimodalODF(o(:),CS,psi,'weights',c)

%%
%

plotPDF(odf,h,'antipodal','position',[100 100 900 300],'contourf',8,'silent')

%% 
% 'simulated' rotation of odf (rodf)

rodf = rotate(odf,rotation('euler',5*degree,2*degree,4*degree));
figure, plotPDF(rodf,h,'antipodal','position',[100 100 900 300],'contourf',8,'silent');

%% 
% back rotatated odf (bodf)

[bodf,rr] = centerSpecimen(rodf,xvector)
figure, plotPDF(bodf,h,'antipodal','position',[100 100 900 300],'contourf',8,'silent')

%% 
% error analysis 

fprintf('            l2-norm: %f\n',calcError(bodf,odf,'L2'))
fprintf('            l1-norm: %f\n',calcError(bodf,odf,'L1'))
fprintf('relative percentage: %f\n',calcError(bodf,odf,'RP'))

plotDiff(bodf,odf,'sections',9,'silent');


%% Real world example

%% 
% data import

fname = fullfile(mtexDataPath,'PoleFigure','aachen_exp.EXP');

h = { ...
  Miller(1,1,1,CS), ...
  Miller(1,0,0,CS), ...
  Miller(1,1,0,CS), ...
  Miller(3,1,1,CS), ...
  };

pf = loadPoleFigure(fname,h,CS,symmetry,'interface','aachen_exp');

%%
%

plot(pf,'position',[100 100 900 250],'silent')

%% 
% calc an odf for these data

odf = calcODF(pf)
figure, plotPDF(odf,h,'antipodal','position',[100 100 900 250],'silent')

%%
% sometimes its better to start with an other center

[rodf,r] = centerSpecimen(odf,yvector);
rodf = rotate(rodf,axis2quat(zvector,90*degree));
figure, plotPDF(rodf,h,'antipodal','position',[100 100 900 250],'silent');

Euler(r)




