classdef l1TVFilter < EBSDFilter
  % smoothes quaternions by projecting them into tangential space and
  % performing there smoothing spline approximation
  
  properties
    alpha = 0.01 % smoothing parameter
    maxit = 50;
    lambda
  end
  
  methods
    
    function F = l1TVFilter(alpha)
      if nargin > 0, F.alpha = alpha;end
      F.lambda = 1 ./ (1:F.maxit);   
    end
    
    function ori = smooth(F,ori)

      % project to tangential space
      [qmean,q] = mean(ori);
      tq = log(q,quaternion(qmean));      
            
      % perform smoothing
      tq.x = l1TV(tq.x,F.alpha,F.maxit,F.lambda);
      tq.y = l1TV(tq.y,F.alpha,F.maxit,F.lambda);
      tq.z = l1TV(tq.z,F.alpha,F.maxit,F.lambda);
            
      % project back to orientation space
      ori = orientation(expquat(tq,quaternion(qmean)),ori.CS,ori.SS);
      
      function x = l1TV(in,alpha,maxit,lambda)
                      
        x = in;
        for k=1:maxit 
          
          x=proxDist(lambda(k),x,in);
          x=proxReg(lambda(k),alpha,x);
                    
        end
        
      end
      
    end
  end
end

