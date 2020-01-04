classdef l1TVFilter < EBSDFilter
  % smoothes quaternions by projecting them into tangential space and
  % performing there smoothing spline approximation
  
  properties
    alpha = 0.4  % regularization parameter
    maxit = 1000; % maximum number of iterations
    lambda       % 
  end
  
  methods
    
    function F = l1TVFilter(alpha)
      if nargin > 0, F.alpha = alpha;end
      F.lambda = 2.8*(1:10000).^(-1.2);
    end
    
    function ori = smooth(F,ori)
      
      % project into fundamental region
      [~,qIn] = mean(ori);
                  
      % perform cyclic proximal point algorithm
      qOut = qIn;
      qOut(isnan(qOut)) = mean(qOut);
      
      %F.lambda(1) * F.alpha ./ degree
      for k = 1:F.maxit
       
        if F.isHex
          qOut = proxTVhex(qOut, F.lambda(k), F.alpha);
        else
          qOut = proxTVSquare(qOut, F.lambda(k), F.alpha);
          %qOut = proxLaplace(qOut, F.lambda(k) *  F.alpha);
        end
        
        qOut = proxl1(qOut, qIn, F.lambda(k));
        %qOut = proxl2(qOut, qIn, F.lambda(k));
        
      end
                        
      % project back to orientation space
      ori = orientation(qOut,ori.CS,ori.SS);
        
    end
    
  end
  
end