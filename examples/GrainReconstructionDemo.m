%% 


%% Import some EBSD data

mtexdata forsterite
plotx2east

plot(ebsd)

%% First attempt on grain reconstruction

[grains,ebsd.grainId] = calcGrains(ebsd,'angle',5*degree);

plot(grains)


%%
% The resulting grains contain a lot of holes and one pixel grains due to
% misindexing. A good measure for regions where indexing went wrong is the
% band contrast

plot(ebsd,ebsd.bc)

%%
% We see its quite low at the grain boundaries and, e.g., in the top left
% rectangle. Lets set the phase of measurements with bandcontrast
% smaller then a certain threshold to notIndexed

condition = ebsd.bc < 80;

% setting the phase to zero means notIndexed
ebsd(condition).phase = 0
plot(ebsd)


%%

[grains,ebsd.grainId] = calcGrains(ebsd,'angle',5*degree);

plot(grains)


%%

plot(grains,log(grains.grainSize ./ grains.boundarySize))
colorbar

%%
% remove 

ind = ~grains.isIndexed & log(grains.grainSize ./ grains.boundarySize) < -0.4;

plot(ebsd)
hold on
plot(grains(ind),'faceColor',[0 0 0],'DisplayName','fill this')
hold off

% remove marked measurements
ebsd(grains(ind)) = []

%%

[grains,ebsd.grainId] = calcGrains(ebsd,'angle',5*degree);

plot(grains)

%%
% fill grains that are to small

ind = grains.grainSize < 5;

hold on
plot(grains(ind),'faceColor',[0 0 0],'DisplayName','fill this')
hold off

% remove marked measurements
ebsd(grains(ind)) = []

%%
% 

[grains,ebsd.grainId] = calcGrains(ebsd,'angle',5*degree);

plot(grains)



%% Smooth grains

grains = smooth(grains,2);

plot(grains)
