%% Tripel points
% how to detect tripel points
%
%% Open in Editor
%
%% Contents
%

%% Calculation of tripel points
%
% MTEX automatically computes tripel points during grain reconstruction.

% import some EBSD data set
mtexdata small

% compute grains
grains = calcGrains(ebsd('indexed'));

% extract all tripel points
tP = grains.tripelPoints


%% Index tripel points by phase
% You may index tripel points by the adjacent phases. The following command
% gives you all tripel points with at least one phase being Forsterite

tP('Forsterite')

%%
% The following command gives you all tripel points with at least two
% phases being Forsterite

tP('Forsterite','Forsterite')

%%
% Finaly, we may mark all inner Diopside tripel points

% smooth the grains a bit
grains = smooth(grains,2);

% and plot them
plot(grains);

% on top plot the tripel points
hold on
plot(tP('Diopside','Diopside','Diopside'),'displayName','Di-Di-Di','color','b')
hold off

%% Index tripel points by grains

[~,id] = max(grains.area);

% the tripel points that belong to the largest grain
tP = grains(id).tripelPoints;


%% Index tripel points by grain boundary



%% Boundary segments from tripel points
%mark boundary segment of all tripel functions that belong to the largest grains



hold on


% the boundary segments which form the tripel points
gB = grains.boundary(tP.boundaryId);

hold on
% plot the tripel point boundary segments
plot(gB,'lineColor','w','linewidth',2)
hold off