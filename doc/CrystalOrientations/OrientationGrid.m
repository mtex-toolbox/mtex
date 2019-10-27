%% Grids of Orientation
% 
%%
% In many usecases one is interested in grid of orientations that somehow
% uniformely cover the orientation space. The simplest way of generating
% equispaced orientations with given resolution is by the command

% define a crystal symmetry
cs = crystalSymmetry('432')

% define a grid of orientations
ori = equispacedSO3Grid(cs,'resolution',5*degree)

%%
% Lets visualize them

plot(ori,'axisAngle')


%% Check for equidistribution
%

odf = unimodalODF(ori)

plotPDF(odf,Miller({1,0,0},{1,1,0},{1,1,1},cs))
mtexColorbar

%%

ori = regularSO3Grid(cs,'resolution',5*degree)

%%

plot(ori,'axisAngle')

%%
%

odf = unimodalODF(ori)

plotPDF(odf,Miller({1,0,0},{1,1,0},{1,1,1},cs))
mtexColorbar