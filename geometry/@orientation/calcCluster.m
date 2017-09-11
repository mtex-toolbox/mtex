function [c,center] = calcCluster(ori,varargin)
% sort orientations into clusters
%
% Syntax
%   [c,center] = calcCluster(ori,'halfwidth',2.5*degree)
%   [c,center] = calcCluster(ori,'numCluster',n,'method','hierarchical')
%   [c,center] = calcCluster(ori,'maxAngle',omega,'method','hierarchical')
%
% Input
%  ori - @orientation
%  n   - number of clusters
%  omega - maximum angle 
%
% Output
%  c - list of clusters
%  center - center of the clusters
%
% Example 
%
%   % generate orientation clustered around 5 centers
%   cs = crystalSymmetry('432');
%   center = orientation.rand(5,cs); 
%   odf = unimodalODF(center,'halfwidth',5*degree)
%   ori = odf.calcOrientations(1500);
%
%   % find the clusters and its centers
%   [c,centerRec] = calcCluster(ori);
%
%   % visualize result
%   for i = 1:length(modes)
%     plot(ori(cId==i),'axisAngle')
%     hold on
%     plot(modes(i),'MarkerFaceColor','k','MarkerSize',10)
%   end
%   hold off
%
%   %check the accuracy of the recomputed centers
%   min(angle_outer(center,centerRec)./degree)
%


method = get_option(varargin,'method','odf');

switch method
  case 'odf'
    % extract weights
    weights = get_option(varargin,'weights',ones(size(ori)));

    % set up an ODF
    odf = unimodalODF(ori,weights,varargin{:});

    % find the modes of the ODF
    [center,~,c] = calcComponents(odf,varargin{:});
  case 'hierarchical'
    [c,center] = doHClustering(ori,varargin{:});
    
end
end

function test
  
% generate orientation clustered around 5 centers
cs = crystalSymmetry('432');
center = orientation.rand(5,cs);
odf = unimodalODF(center,'halfwidth',5*degree);
ori = odf.calcOrientations(1500);

% find the clusters and its centers
tic; 
[c,centerRec] = calcCluster(ori,'method');
toc

% visualize result
for i = 1:length(centerRec)
  plot(ori(c==i),'axisAngle')
  hold on
  plot(centerRec(i),'MarkerFaceColor','k','MarkerSize',10)
end
hold off

%check the accuracy of the recomputed centers
min(angle_outer(center,centerRec)./degree)

odfRec = calcODF(ori)
[~,centerRec2] = max(odfRec,5)
min(angle_outer(center,centerRec2)./degree)
end

% If the statistics toolbox is installed the following is also possible
% though it does not work so well
% d = angle_outer(ori,ori);
% tic;z = linkage(d);toc
% c = cluster(z,'maxclust',5);