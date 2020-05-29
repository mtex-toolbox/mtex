classdef cMeans < kMeans
  
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