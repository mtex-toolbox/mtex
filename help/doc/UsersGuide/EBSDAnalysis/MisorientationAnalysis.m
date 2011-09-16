%% Misorientation Analysis
% How to analyse misorientations.
%
%% Open in Editor
%
%% Contents
%
%% Definition
%
% In MTEX the misorientation between two orientations x, y is defined as
%
% $$ mis(x,y) = x^{-1} * y  $$
%
% In te case of EBSD data intergranular misorientations, misorientations
% between neighbouring grains, and missorientations between random
% measurments are of interest.


%% The sample data set
% Let us first import some EBSD data by a [[matlab:edit mtexdata, script file]]

mtexdata aachen

%%
% and <EBSD.calcGrains.html reconstruct> the grains by

[grains ebsd] = calcGrains(ebsd,'threshold',5*degree);


%% Intergranular misorientation
% The intergranular misorientation is automaticaly computed while
% reconstructing the grain structure. It is stored as the property
% *mis2mean* within the ebsd variable and can be accesed by the command
% <ebsd_get.html,get>.

% get the misorientations to mean
mori = get(ebsd,'mis2mean')

% plot a histogram of the angle
hist(angle(mori)

%%
% The visualization of the misorientation can be done by

plot(ebsd,'property','mis2mean')


%% Boundary Misorientation
% Not yet implemented!


