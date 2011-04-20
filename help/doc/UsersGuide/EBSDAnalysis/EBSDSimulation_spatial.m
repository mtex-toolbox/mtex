%% Simulating random Spatial data
% just experimental

%% Generation of random 2d Data

ebsd = simulateEBSD(SantaFe,500);

X = randi(100,500,2);

ebsd = set(ebsd,'X',X);
ebsd = fill(ebsd,[1 100 1 100],1)

plot(ebsd)

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

ebsd = fill(ebsd,[0 25 0 25 0 25],1)

%%
% 

[ grains ebsd] = calcGrains(ebsd);

%%
%

plot(grains)
axis tight
view(60,20)

material dull
lighting phong
camlight('headlight')
grid on


%%
% plot a single phase

plot(grains(get(grains,'phase') == 2))
axis tight
view(60,20)

material dull
lighting phong
camlight('headlight')
grid on

