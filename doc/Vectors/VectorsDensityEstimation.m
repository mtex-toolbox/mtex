%% Spherical Density Estimation
%
%% TODO
% 

mtexdata forsterite
cAxes = ebsd('Fo').orientations * ebsd('Fo').CS.cAxis
cAxes.antipodal = true;

%%

plot(cAxes,'upper','MarkerFaceColor','none','MarkerEdgeAlpha',0.01)

%%

pdf = cAxes.calcDensity

plot(pdf,'upper')