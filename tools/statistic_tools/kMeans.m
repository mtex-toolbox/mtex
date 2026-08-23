classdef kMeans < handle
% k means clustering of orientations or directions
%
% Works on anything with a mean and an angle, so it clusters @orientation,
% @vector3d or @Miller alike. The seeds are chosen by k-means++.
%
% References
%
% * k-means++: The Advantages of Careful Seeding, by David Arthur and
% Sergei Vassilvitskii, SODA 2007.
%
% Syntax
%   km = kMeans(n);
%   [label,center] = km.doClustering(ori)
%
% Input
%  n   - number of clusters
%  ori - @orientation or @vector3d
%
% Output
%  label  - cluster id of each input
%  center - the cluster centers
%
% Class Properties
%  n      - number of clusters
%  center - the cluster centers
%
% See also
% cMeans orientation/calcCluster
%

  properties
    n      % number of clusters
    center % cluster center
  end
  
  methods
    
    function km = kMeans(n) 
      if nargin == 1, km.n = n; end
    end
    
    function initSeeds(km,obj)

      % Choose one center uniformly at random from among the data points.
      km.center = obj(randi(length(obj)));
      D = inf(length(obj),1);
            
      for k = 2:km.n
 
        %For each data point x, compute D(x), the distance between x and
        %the nearest center that has already been chosen.
        D = min(D,angle(obj,km.center(k-1)));
        
        %Choose one new data point at random as a new center, using a
        %weighted probability distribution where a point x is chosen with
        %probability proportional to D(x)2.
        id = discretesample(D.^2,1);
        km.center(k) = obj(id);
        
      end     
      
    end
    
    function [label, center] = doClustering(km,obj)
    
      km.initSeeds(obj);
      
      label = find(km.center,obj);
      label_old = nan(size(label));
      
      % computes new centers until the labels do not change anymore
      while any(label(:) ~= label_old(:))
        
        % compute new centers
        for i = 1:km.n
          km.center(i) = mean(obj(label == i));
        end
        
        % store old labels
        label_old = label;
        
        % assign new labels
        label = find(km.center,obj);
                
      end
      
      center = km.center;
      
    end
    
  end
  
end