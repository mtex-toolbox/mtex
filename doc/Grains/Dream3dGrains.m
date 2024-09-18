%% 

%%

fname = fullfile(mtexDataPath,'EBSD','SmallIN100_MeshStats.dream3d');

grains = grain3d.load(fname)


%%

clf

id = 2;
plot(grains(id))

c = grains(id).boundary.centroid;

%hold on
%scatter3(c.x,c.y,c.z,'.')
%hold off

hold on
quiver3(c,grains(id).boundary.N,'arrowSize',0.15)
hold off

