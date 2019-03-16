%% Slip Transmition
% How to analyse slip transmission at grain boundaries
%
%% Open in Editor
%
%% Contents
%

%% Import Titanium data
% From Mercier D. - MTEX 2016 Workshop - TU Chemnitz (Germany)
% Calculation and plot on GBs of m' parameter
% Dataset from Mercier D. - cp-Ti (alpha phase - hcp)

mtexdata csl

% compute grains
[grains, ebsd.grainId] = calcGrains(ebsd('indexed'));

% make them a bit nicer
grains = smooth(grains);

% extract inner phase grain boundaries
gB = grains.boundary('indexed');

plot(ebsd,ebsd.orientations)
hold on
plot(grains.boundary)
hold off

%% Taylor model
% 

% consider Basal slip
sS = slipSystem.fcc(ebsd.CS)

% and all symmetrically equivalent variants
sS = sS.symmetrise;

% consider plane strain
q = 0.5;
eps = strainTensor(diag([-q 1 -(1-q)]));

% and compute Taylor factor as well as the active slip systems
[M,b,W] = calcTaylor(inv(grains.meanOrientation).*eps,sS);

%%

% find the maximum 
[~,id] = max(b,[],2);

%%
% The variable |id| contains now for each grain the id of the slip system
% with the largest Schmidt factor. In order to visualize it we first rotate
% for each grain the slip system with largest Schmid factor in specimen
% coordinates

sSGrain = grains.meanOrientation .* sS(id)

% and plot then the plance normal and the Burgers vectors into the centers
% of the grains

plot(grains,M)

largeGrains = grains(grains.grainSize > 10)

hold on
quiver(grains,cross(sSGrain.n,zvector),'displayName','slip plane')
hold on
quiver(grains,sSGrain.b,'displayName','slip direction')
hold off

%%
% We may also analyse the distribution of the slip directions in a pole
% figure plot

plot(sSGrain.b)

%%
% The same as a contour plot. We see a clear trend towards east.

plot(sSGrain.b,'contourf')

