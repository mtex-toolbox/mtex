function [cId,center] = calcCluster(v,varargin)
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
% Options
%  method - classix (default) | hierarchical | matlab
%
% Output
%  cId    - list of clusters ids
%  center - center of the clusters
%
% Example 
%
%   %generate vector data of up to 5 clusters
%   vin = vector3d.rand(5);
%   sF2 = calcDensity(vin,'halfwidth',10*degree);
%   v   = sF2.discreteSample(800);
% 
%   % find clusters and their centers
%   [cId,center] = calcCluster(v,'numCluster',5,'method','hierarchical');
% 
%   % visualize the result
%   plot(v,cId)
%   hold on
%   plot(center,'add2all','MarkerSize',10,'MarkerFaceColor','k')
%   hold off
% 
%   %check the accuracy of the recomputed centers
%   min(angle_outer(center,vin)./degree)
%

method = get_option(varargin,'method','classix');

switch method

  case 'classix'
    
    if v.antipodal
      data = [v.x.^2,v.y.^2,v.z.^2,v.x.*v.y,v.x.*v.z,v.y.*v.z];
    else
      data = v.xyz;
    end
      
    radius = get_option(varargin,'radius');

    % try to estimate a reasonable radius parameter
    if isempty(radius)
      
      k = 10;
      [~, dist] = knnsearch(data, data, "K", k+1);
      radius = 2*median(dist(:,end));

    end
      
    minPts = get_option(varargin,'minPoints',numel(v)/100) ;
    opts.merge_scale = 1.5;
    opts.merge_tiny_groups = 1;
    opts.use_mex = 0;

    cId = classix(data, radius, minPts, opts);
  
    if nargout == 2
      center = accumarray(cId,v);
    end


  case 'matlab'
    
    varargin = delete_option(varargin,'method',1);
    
    % compute the full distance matrix 
    d = angle_outer(v,v);
    d = d(triu(true(size(d)),1));
    
    % use the statistic toolbox
    z = linkage(d,varargin{:});
    
    cId = cluster(z,varargin{:});
  
  
  case 'hierarchical'
    
    %dist = @(a,b) angle(a,b);
    %[cId,center] = doHClustering(vec,dist,varargin{:});
    [cId,center] = doHClustering(v,varargin{:});
    
end
end

