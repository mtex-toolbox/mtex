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
%   ori = odf.discreteSample(1500);
%
%   % find the clusters and its centers
%   [cId,centerRec] = calcCluster(ori,'silent');
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

% deal with nan orientations
if any(isnan(ori))
  
  c = nan(size(ori));
  notNaN = ~isnan(ori);
  [c(notNaN),center] = calcCluster(ori.subSet(notNaN),varargin{:});
  
  return
end


method = get_option(varargin,'method','odf');

switch method
  case 'odf'
    % extract weights
    weights = get_option(varargin,'weights',ones(size(ori)));

    % set up an ODF
    odf = calcDensity(ori,'weights',weights,'halfwidth',5*degree,varargin{:});

    % find the modes of the ODF
    [center,~,c] = calcComponents(odf,'seed',ori,varargin{:});
    
    numCluster = get_option(varargin,'numCluster',min(20,length(center)));

    center = subSet(center,1:numCluster);
    c(c>numCluster) = NaN;

    % post process cluster
    for i = 1:numCluster
    
      % remove points to far from the center
      ori_c = ori.subSet(c==i);
      omega = angle(ori_c,center.subSet(i));
      ind = (omega < 1.5*quantile(omega,0.9));
      if ~all(ind)
        c(c==i) = i * (omega < 1.5*quantile(omega,0.9));
        ori_c = ori.subSet(ind);
      end
      
      % recompute center
      odf = unimodalODF(ori_c,'halfwidth',2.5*degree,varargin{:},'weights',weights(c==i));
      center = subsasgn(center,i,odf.steepestDescent(center.subSet(i)));
      
    end
    
  case 'hierarchical'
    [c,center] = doHClustering(ori,varargin{:});
    
end
end

function test %#ok<DEFNU>
  
% generate orientation clustered around 5 centers
cs = crystalSymmetry('432');
center = orientation.rand(5,cs);
odf = unimodalODF(center,'halfwidth',5*degree);
ori = odf.discreteSample(1500);

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

odfRec = calcDensity(ori) %#ok<NOPRT>
[~,centerRec2] = max(odfRec,'numLocal',5) %#ok<NOPRT>
min(angle_outer(center,centerRec2)./degree)
end

% If the statistics toolbox is installed the following is also possible
% though it does not work so well
% d = angle_outer(ori,ori);
% tic;z = linkage(d);toc
% c = cluster(z,'maxclust',5);