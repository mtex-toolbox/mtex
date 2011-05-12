%% Simulating random Spatial data
% just experimental

%% Generation of random 2d Data

ebsd = simulateEBSD(SantaFe,500);

X = randi(20,500,2);

ebsd = set(ebsd,'X',X);
figure,plot( calcGrains(ebsd) )

ebsd = fill(ebsd,[0 20 0 20],1)
figure,plot( calcGrains(ebsd) )


%% Generation of random 3d Data
% some random orientations and spatial coordinates

CS = symmetry('cubic');
SS = symmetry;

X = randi(25,50,3);
o = SO3Grid('random',CS,SS,'points',size(X,1));
ebsd(1) = EBSD(orientation(o),'xy',X,'phase',1);

X = randi(25,20,3);
o = SO3Grid('random',CS,SS,'points',size(X,1));
ebsd(2) = EBSD(orientation(o),'xy',X,'phase',2);

%%
% currently the voronoi decomposition in 3d is not supported, so before
% computing grains we interpolate data by on a regular grid
%

[grains ebsd] = calcGrains(ebsd,'voronoi')
plot(grains,'edgecolor','k')

%%

ebsd = fill(ebsd,[0 25 0 25 0 25],1)

%%
% 

[ grains ebsd] = calcGrains(ebsd);

%%
%

plot(grains)

material dull
lighting phong
camlight('headlight')
grid on


%%
% plot a single phase

plot(grains(get(grains,'phase') == 2))

material dull
lighting phong
camlight('headlight')
grid on


%%



