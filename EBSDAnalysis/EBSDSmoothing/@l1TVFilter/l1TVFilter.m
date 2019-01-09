classdef l1TVFilter < EBSDFilter
  % smoothes quaternions by projecting them into tangential space and
  % performing there smoothing spline approximation
  
  properties
    alpha = 0.6  % regularization parameter
    maxit = 100; % maximum number of iterations
    lambda       % 
  end
  
  methods
    
    function F = l1TVFilter(alpha)
      if nargin > 0, F.alpha = alpha;end
      F.lambda = (1:1000).^(-1.2);
    end
    
    function ori = smooth(F,ori)

      % project into fundamental region
      [~,qIn] = mean(ori);
                  
      % perform cyclic proximal point algorithm
      qOut = qIn;
      qOut(isnan(qOut)) = mean(qOut);
      for k = 1:F.maxit
        
        qOut = proxTVSquare(qOut, F.lambda(k), F.alpha);
        qOut = proxDist(qOut, qIn, F.lambda(k));
        
        %qOut = proxLaplace(qOut, F.lambda(k) *  F.alpha);
        
      end
                        
      % project back to orientation space
      ori = orientation(qOut,ori.CS,ori.SS);
            
    end
  end
  
end
