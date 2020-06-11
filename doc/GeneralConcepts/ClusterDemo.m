%% Cluster demo 
%
%%

cs  = crystalSymmetry('432');
odf = unimodalODF(orientation.rand(2,cs),'halfwidth',5*degree)


ori = odf.discreteSample(10000)

r = ori * Miller(1,0,0,odf.CS)

%scatter(r)


%%

[cId,center] = calcCluster(r,'numCluster',12);

plotCluster(r,cId)

annotate(center,'add2all')


%%

r.antipodal = true

[cId,center] = calcCluster(r,'numCluster',6);

plotCluster(r,cId)

annotate(center,'add2all')

%%

h = ori \ vector3d(1,2,0);

[cId,center] = calcCluster(h,'numCluster',2);

plotCluster(h.project2FundamentalRegion,cId,'fundamentalSector')

annotate(center,'add2all')

%%

[cId,center] = calcCluster(ori,'numCluster',2,'method','hierarchical');

plotCluster(r,cId)

annotate(center * Miller(1,0,0,ori.CS),'add2all')


%%

[cId,center] = calcCluster(ori,'numCluster',2,'method','odf');

plotCluster(r,cId)

annotate(center * Miller(1,0,0,ori.CS),'add2all')


%%

% compute the full distance matrix 
d = angle_outer(r,r);
d(d<0.01) = 0;
%d = d(triu(true(size(d)),1));
d = squareform(d);


% use the statistic toolbox
z = linkage(d,'single');
    
%cId = cluster(z,'cutoff',30*degree);
cId = cluster(z,'maxclust',12);

plotCluster(r,cId)


%%


function plotCluster(r,cId,varargin)

scatter(r(cId==1),'MarkerFaceColor',ind2color(1),varargin{:})
hold on
for i = 2:max(cId)
  scatter(r(cId==i),'add2all','MarkerFaceColor',ind2color(i),varargin{:})
end
hold off
end