%% Tripel points
% how to detect tripel points
%
%% Open in Editor
%
%% Contents
% This is some starting implementation for tripel points in orientation
% images. 

%% Calculation of tripel points
%
% MTEX automatically computes tripel points during grain reconstruction.
% They are acessable similarly to <BoundaryAnalysis.html grain boundaries>
% as an property of the grain list.

% import some EBSD data set
mtexdata small

% compute grains
grains = calcGrains(ebsd('indexed'));

% extract all tripel points
tP = grains.tripelPoints

%% Index tripel points by phase
%
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
%
% Since, tripel points are asociated to grains we may single out tripel
% points that belong to a specific grain or some subset of grains.

% find the index of the largest grain
[~,id] = max(grains.area);

% the tripel points that belong to the largest grain
tP = grains(id).tripelPoints;

% plot these tripel points
plot(grains(id),'FaceColor',[0.2 0.8 0.8],'displayName','largest grains');
hold on
plot(grains.boundary)
plot(tP,'color','r')
hold off


%% Index tripel points by grain boundary
%
% Tripel points are not only a property of grains but also of grain
% boundaries. Thus we may ask for all tripel points that belong to
% Fosterite - Forsterite boundaries with misorientation angle larger then
% 60 degree

% all Fosterite - Forsterite boundary segments
gB_Fo = grains.boundary('Forsterite','Forsterite')

% Fo - Fo segments with misorientation angle larger 60 degree
gB_large = gB_Fo(gB_Fo.misorientation.angle>60*degree)

% plot the tripel points
plot(grains)
hold on
plot(gB_large,'linewidth',2,'linecolor','w')
plot(gB_large.tripelPoints,'color','m')
hold off


%% Boundary segments from tripel points
%
% On the other hand we may also ask for the boundary segments that build up
% a tripel point. These are stored as the property boundaryId for each
% tripel points. 
%

% lets take Forsterite tripel points
tP = grains.tripelPoints('Fo','Fo','Fo');

% the boundary segments which form the tripel points
gB = grains.boundary(tP.boundaryId);

% plot the tripel point boundary segments
plot(grains)
hold on
plot(gB,'lineColor','w','linewidth',2)
hold off

%%
% Once we have extracted the boundary segments adjecent to a tripel point
% we may also extract the corresponding misorientations. The following
% command gives a n x 3 list of misorientations where n is the number of
% tripel points

mori = gB.misorientation

%% 
% Hence, we can compute for each tripel point the sum of misorientation
% angles by

sumMisAngle = sum(mori.angle,2);

%%
% and my visualize it by

plot(grains,'figSize','large')
hold on
plot(tP,sumMisAngle ./ degree,'markerEdgeColor','w')
hold off
mtexColorMap(blue2redColorMap)
CLim(gcm,[80,180])
mtexColorbar
