classdef cMeans < kMeans
% fuzzy c means clustering of orientations or directions
%
% Like @kMeans, but every input gets a membership in each cluster rather
% than one hard label. The fuzzifier m controls how soft that is; m close
% to 1 approaches k means.
%
% Syntax
%   cm = cMeans(n);
%   [cid,center,u] = cm.doClustering(ori)
%
% Input
%  n   - number of clusters
%  ori - @orientation or @vector3d
%
% Output
%  cid    - cluster id of the largest membership
%  center - the cluster centers
%  u      - membership of each input in each cluster
%
% Class Properties
%  n      - number of clusters
%  center - the cluster centers
%  m      - fuzzifier, > 1
%
% See also
% kMeans orientation/calcCluster
%
  
  properties
    m = 1.5 % fuzzifier
  end
  
  methods
    
    function cm = cMeans(n) 
      cm.n = n;  
    end
    
    function [cid, center, u] = doClustering(cm,obj)
    
      cm.initSeeds(obj);
            
      D = 0.00001 + angle_outer(obj,cm.center).^(2/(cm.m-1));
      u = 1 ./ (D .* repmat(sum(1./D,2),1,cm.n));
      
      u_old = zeros(size(u));
      
      % computes new centers until the labels do not change anymore
      while mean((u(:) - u_old(:)).^2) > 1e-3
        
        % compute new centers
        for i = 1:cm.n
          cm.center(i) = mean(obj,'weights',u(:,i).^cm.m);
        end
        
        % store old labels
        u_old = u;
        
        % assign new labels
        D = 0.001 + angle_outer(obj,cm.center).^(2/(cm.m-1));
        u = 1 ./ (D .* repmat(sum(1./D,2),1,cm.n));
                
      end
      
      center = cm.center;
      [~,cid] = max(u,[],2);
      
    end
    
  end
  
end