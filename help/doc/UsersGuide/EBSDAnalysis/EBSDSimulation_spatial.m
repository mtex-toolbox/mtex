%% Simulating random Spatial data
% just experimental

%% Generation of random 2d Data

ebsd = calcEBSD(SantaFe,100);

xy = randi(20,150,2);
xy = unique(xy,'rows');

ebsd = set(ebsd,'x',xy(1:100,1));
ebsd = set(ebsd,'y',xy(1:100,2));

figure,plot( calcGrains(ebsd) )

ebsd = fill(ebsd,[0 20 0 20],1)
figure,plot( calcGrains(ebsd) )


%% Generation of random 3d Data
% some random orientations and spatial coordinates

CS = symmetry('cubic');
SS = symmetry;

X = randi(25,50,3);
X = unique(X,'rows');
options.x = X(:,1);
options.y = X(:,2);
options.z = X(:,3);

o = orientation('random',CS,SS,'points',size(X,1));

ebsd = EBSD(o,'options',options);

%%
% currently the voronoi decomposition in 3d is not supported, so before
% computing grains we interpolate data by on a regular grid
%

ebsd = fill(ebsd,[0 25 0 25 0 25],1)

plot(ebsd)

%%

grains = calcGrains(ebsd);

%%
%

plot(grains)

view(3)

material dull
lighting phong
camlight('headlight')
grid on



