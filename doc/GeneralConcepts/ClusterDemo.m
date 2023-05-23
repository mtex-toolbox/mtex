%% Cluster demo 
% This code demonstrates how the clustering algorithm can be used to assign
% vector3d and crystal directions to groups by proximity.
%
%%
% define an octohedral crystal symmetry
cs  = crystalSymmetry('432');

% define an ODF with two radial peaks
ori = orientation.byEuler([10 40]*degree,[30 50]*degree,[50 70]*degree,cs)
odf = unimodalODF(ori,'halfwidth',5*degree);


% view the odf 
plotPDF(odf,Miller(1,0,0,odf.CS),'contour','linewidth',2);

% generate 10k orientations from this randomly defined ODF function
ori = odf.discreteSample(10000);

% convert the orientations to vector3D
r = ori * Miller(1,0,0,odf.CS);

%%
% assign each vector3d to one of twelve clusters, and calculate the
% vector3D located at the center of each cluster
[cId,center] = calcCluster(r,'numCluster',12);

% plot the clusters, sorted by colour
figure;
plot(r,ind2color(cId))

% annotate all the cluster centers, on all figures.
annotate(center,'add2all');

%%
% Note that the upper and lower hemisphere plots are versions of each
% other, reflected horizontally plus vertically.  This means that the
% underlying data has antipodal symmetry, contributing equally to both
% hemispheres. Let's include that in the cluster sorting.
%%
% repeat the calculation after changing all the vector3d to be antipodal
r.antipodal = true;

% repeat the calculation assigning vector3D to clusters.  Due to the
% increase in symmetry, there are only six clusters now.
[cId,center] = calcCluster(r,'numCluster',6);

% plot the vectors.  Note that we no longer get an upper and lower hemisphere plot; the antipodal symmetry tells MTEX they are equivilent and so one sufficient to represent the data.
figure;plot(r,ind2color(cId))

% annotate the cluster centers.
annotate(center,'add2all')

%%
% pick a vector3d, and use that to convert the 10k random orientations
% previously generated into crystal directions.
h = ori \ vector3d(1,1,0);

% assign the crystal directions to two clusters
[cId,center] = calcCluster(h,'numCluster',2);

% plot the crystal symmetry data on appropiate fundamental sector
plot(h.project2FundamentalRegion,ind2color(cId),'fundamentalSector')

% annote the cluster centers
annotate(center,'add2all')

%%
% just as we calculated clusters for vector3D and crystal directions, we're
% now going to do so for orientations
[cId,center] = calcCluster(ori,'numCluster',2,'method','hierarchical');

% create a pole figure of the orientations coloured by the cluster they
% belong to.
plotPDF(ori,ind2color(cId),Miller(1,0,0,cs),'all')

%%
% If you have the statistics toolbox, you can make some calculations about
% the spread of points assigned to each cluster.

% compute the full distance matrix between all combinations of vector3D
d = angle_outer(r,r);
% convert all small values to zero to simplify later calculations
d(d<0.01) = 0;
%d = d(triu(true(size(d)),1));

% use the statistic toolbox
try
  d = squareform(d);
  z = linkage(d,'ward');
    
  %cId = cluster(z,'cutoff',30*degree);
  cId = cluster(z,'maxclust',6);

  plotCluster(r,cId)
catch
  warning('Statistics Toolbox not installed!')
end

%%


function plotCluster(r,cId,varargin)

scatter(r(cId==1),'MarkerFaceColor',ind2color(1),varargin{:})
hold on
for i = 2:max(cId)
  scatter(r(cId==i),'add2all','MarkerFaceColor',ind2color(i),varargin{:})
end
hold off
end
