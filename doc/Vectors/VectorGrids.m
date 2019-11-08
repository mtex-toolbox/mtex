%% Spherical Grids
%
%%
%

grid1 = regularS2Grid('resolution',7*degree)

plot(grid1,'upper')

%%
% 

grid2 = equispacedS2Grid('resolution',7*degree)

plot(grid2,'upper')

%%

grid3 = HEALPixS2Grid('resolution',7*degree)

plot(grid3,'upper')

%% Comparison of Uniformity

plot([grid1.calcDensity,grid2.calcDensity,grid3.calcDensity],'upper')
mtexColorbar

%%

