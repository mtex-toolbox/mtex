%% 1) no fill, no grains, all pixels
mtexdata small
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd);
ebsd(grains(grains.grainSize<=3)) = [];
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd);
F = splineFilter; 
ebsd = smooth(ebsd,F);
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd);
plot(ebsd)
hold on
plot(grains.boundary,'lineColor',[1 0 0],'linewidth',2)
hold off


%% 2) no fill, no grains, indexed pixels
mtexdata small
[grains,ebsd('indexed').grainId] = calcGrains(ebsd('indexed'));
ebsd(grains(grains.grainSize<=3)) = [];
[grains,ebsd('indexed').grainId] = calcGrains(ebsd('indexed'));
F = splineFilter; 
ebsd = smooth(ebsd('indexed'),F);
[grains,ebsd('indexed').grainId] = calcGrains(ebsd('indexed'));

nextAxis
plot(ebsd)
hold on
plot(grains.boundary,'lineColor',[1 0 0],'linewidth',2)
hold off


%% 3) fill, no grains, all pixels
mtexdata small
[grains,ebsd.grainId] = calcGrains(ebsd);
ebsd(grains(grains.grainSize<=3)) = [];
[grains,ebsd.grainId] = calcGrains(ebsd);
F = splineFilter; 
ebsd = smooth(ebsd,F,'fill');
[grains,ebsd.grainId] = calcGrains(ebsd);

nextAxis
plot(ebsd)
hold on
plot(grains.boundary,'lineColor',[1 0 0],'linewidth',2)
hold off


%% 4) fill, no grains, indexed pixels
mtexdata small
[grains,ebsd('indexed').grainId] = calcGrains(ebsd('indexed'));
ebsd(grains(grains.grainSize<=3)) = [];
[grains,ebsd('indexed').grainId] = calcGrains(ebsd('indexed'));
F = splineFilter; 
ebsd = smooth(ebsd('indexed'),F,'fill');
[grains,ebsd('indexed').grainId] = calcGrains(ebsd('indexed'));

nextAxis
plot(ebsd)
hold on
plot(grains.boundary,'lineColor',[1 0 0],'linewidth',2)
hold off


%% 5) fill, grains, indexed pixels
mtexdata small
[grains,ebsd('indexed').grainId] = calcGrains(ebsd('indexed'));
ebsd(grains(grains.grainSize<=3)) = [];
[grains,ebsd('indexed').grainId] = calcGrains(ebsd('indexed'));
F = splineFilter; 
ebsd = smooth(ebsd('indexed'),F,'fill',grains);
[grains,ebsd('indexed').grainId] = calcGrains(ebsd('indexed'));

nextAxis
plot(ebsd)
hold on
plot(grains.boundary,'lineColor',[1 0 0],'linewidth',2)
hold off
drawNow(gcm)