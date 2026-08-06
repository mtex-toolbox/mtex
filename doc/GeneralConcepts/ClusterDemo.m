%% Cluster demo 
%
% Clustering allows to separate data, like orientations, directions, grain
% shapes, ... into groups by proximity. While MTEX supports several
% clustering algorithms, the currently best one is
% <https://classix.readthedocs.io/en/stable/ classix>.
%
%% 
% Lets start by clustering some directional data which we sample from our
% smiley function

S2F = S2Fun.smiley.^2;

v = S2F.discreteSample(10000);

scatter(v,'MarkerAlpha',0.2,'MarkerSize',2)

%%

[cInd,center] = calcCluster(v);

plot(v,ind2color(cInd),'MarkerAlpha',0.2,'MarkerSize',2)

annotate(center)

%%
% The output |cInd| is a list of integers that associates each data point
% with its cluster. For fine tuning the classix clustering algorithm has
% the options |'radius'| and |'minPoints'|.
% 
% Note that MTEX automatically adapts the algorithm in presence of
% antipodals symmetry, i.e., the symmetrically equivalent points at the top
% and the bottom of the smiley are assigned to the same cluster.

v.antipodal = true;
[cInd,center] = calcCluster(v);

plot(v,ind2color(cInd),'MarkerAlpha',0.2,'MarkerSize',2)

annotate(center)

%%
% Analogously to directions, we may also cluster orientations. In order to
% demonstrate this we first draw a random sample from a model ODF
% consisting of a fibre and a unimodal component.

% define a cubic crystal symmetry
cs  = crystalSymmetry('432');

% define an ODF with two radial peaks
odf = 0.7*fibreODF(fibre.gamma(cs),'halfwidth',10*degree) + ...
  0.3*unimodalODF(orientation.byEuler(30*degree,10*degree,60*degree,cs))

% simulate 10k orientations from the ODF
ori = odf.discreteSample(10000);

%%
% Lets visualize the ODF and the random sampling

% view the ODF 
plotSection(odf,'contourf')
mtexColorMap white2black

% together with the random sample
plot(ori,'add2all','MarkerSize',3,'MarkerAlpha',0.25,'all')

%%
% We again use the classix method for for clustering the orientations. Note
% that the algorithm separates the fibre from the unimodal
% portion. In particular, it correctly assigns all symmetrically equivalent
% orientations to the same cluster.

[cId,center] = calcCluster(ori,'method','classix');

plotSection(ori,ind2color(cId),'markerSize',3,'MarkerAlpha',0.25,'all')

annotate(center)


%%


function plotCluster(r,cId,varargin)

scatter(r(cId==1),'MarkerFaceColor',ind2color(1),varargin{:})
hold on
for i = 2:max(cId)
  scatter(r(cId==i),'add2all','MarkerFaceColor',ind2color(i),varargin{:})
end
hold off
end
