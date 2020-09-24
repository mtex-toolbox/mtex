%% Subgrain Boundaries
%
%% TODO: expand this page
%

mtexdata ferrite silent

[grains,ebsd.grainId] = calcGrains(ebsd('indexed'));

% remove one pixel grains
ebsd(grains(grains.grainSize<3)) = [];

%%
% When specifying two threshold the first value controls the grain
% boundaries whereas the second is used for the subgrain boundaries


[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'threshold',[1*degree, 5*degree]);

grains = smooth(grains,5)


%%


plot(grains,grains.meanOrientation,'faceAlpha',0.5,'linewidth',2,'figSize','large')

hold on

omega = grains.innerBoundary.misorientation.angle;
plot(grains.innerBoundary,'linewidth',1)
%plot(grains.innerBoundary,omega ./ degree,'linewidth',1.5)
%mtexColorMap white2black
%setColorRange([1,5])

hold off

%%
% The number of subgrain boundary segments inside each grain can be
% computed by the command <grain2d.subBoundarySize.html |subBoundarySize|>.
% In the following figure we use it to visualize the density of subgrain
% boundaries per grain pixel.

plot(grains, grains.subBoundarySize ./ grains.grainSize)

%% 
% We may compute also the density of subgrain boundaries per grain as the
% length of the subgrain boundaries devided by the grain area. This can be
% done using the commands <grain2d.subBoundaryLength.html |subBoundaryLength|>
% and <grain2d.area.html |area|>

plot(grains, grains.subBoundaryLength ./ grains.area)


%%
% Analyse the misorientation axes of the subgrain boundary misorientations


plot(grains.innerBoundary.misorientation.axis,'fundamentalRegion','contourf')