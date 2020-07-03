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
%   [cId,centerRec] = calcCluster(ori);
%
%   % visualize result
%   for i = 1:length(centerRec)
%     plot(ori(cId==i),'axisAngle')
%     hold on
%     plot(centerRec(i),'MarkerFaceColor','k','MarkerSize',15)
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
    odf = calcKernelODF(ori,'weights',weights,'halfwidth',5*degree,varargin{:});

    % find the modes of the ODF
    [center,~,c] = calcComponents(odf,'seed',ori,varargin{:});
    
    % post process cluster
    for i = 1:min(length(center),20)
    
      % remove points to far from the center
      ori_c = ori.subSet(c==i);
      omega = angle(ori_c,center.subSet(i));
      c(c==i) = i * (omega < 1.5*quantile(omega,0.9));
      
      % recompute center
      odf = unimodalODF(ori_c,weights(c==i),'halfwidth',2.5*degree,varargin{:});
      center = subsasgn(center,i,odf.steepestDescent(center.subSet(i)));
      
    end
    
    
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

odfRec = calcDensity(ori)
[~,centerRec2] = max(odfRec,5)
min(angle_outer(center,centerRec2)./degree)
end

% If the statistics toolbox is installed the following is also possible
% though it does not work so well
% d = angle_outer(ori,ori);
% tic;z = linkage(d);toc
% c = cluster(z,'maxclust',5);