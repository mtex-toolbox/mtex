function [cId,center] = calcCluster(vec,varargin)
% seperate directions into clusters
%
% Syntax
%   [cId,center] = calcCluster(vec,'halfwidth',2.5*degree)
%   [cId,center] = calcCluster(vec,'numCluster',n,'method','hierarchical')
%   [cId,center] = calcCluster(vec,'maxAngle',omega,'method','hierarchical')
%
% Input
%  vec - @vector3d
%  n   - number of clusters
%  omega - maximum angle 
%
% Output
%  cId    - list of clusters ids
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


method = get_option(varargin,'method','hierarchical');

switch method
    
  
  case 'matlab'
    
    varargin = delete_option(varargin,'method',1);
    
    % compute the full distance matrix 
    d = angle_outer(vec,vec);
    d = d(triu(true(size(d)),1));
    
    % use the statistic toolbox
    z = linkage(d,varargin{:});
    
    cId = cluster(z,varargin{:});
  
  
  case 'hierarchical'
    
    %dist = @(a,b) angle(a,b);
    %[cId,center] = doHClustering(vec,dist,varargin{:});
    [cId,center] = doHClustering(vec,varargin{:});
    
end
end

