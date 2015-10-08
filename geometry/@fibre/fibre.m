classdef fibre
  %FIBRE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    h
    r
  end
  
  properties (Dependent = true)
    CS
  end
  
  
  methods
    function f = fibre(h,r)      
      f.h = h;
      f.r = r;
    end
    
    function omega = angle(f,ori)
      % angle between a fibre and an orientation
      
      omega = angle(ori \ f.r,f.h);
      
    end
    
    function ori = orientation(f,npoints)
      
      if nargin == 1, npoints = 100; end
      
      omega = linspace(0,2*pi,npoints);
      
      ori = rotation('axis',f.r,'angle',omega) .* orientation('map',f.h,f.r);
      
    end
    
  end
  
  methods (Static = true)
       
    function f = alpha(cs)
      % the alpha fibre
      % from:Comprehensive Materials Processing 
      
      ori1 = orientation('Miller',[0 0 1],[1 1 0],cs);
      ori2 = orientation('Miller',[1 1 1],[1 1 0],cs);
            
      f = fibre.fit(ori1,ori2);
    end
    
    function f = beta(cs)
      % the beta fibre
      
      ori1 = orientation('Miller',[1 1 2],[1 1 0],cs);
      ori2 = orientation('Miller',[11 11 8],[4 4 11],cs);
            
      f = fibre.fit(ori1,ori2);
    end
    
    function f = gamma(cs)
      % the beta fibre
      
      ori1 = orientation('Miller',[1 1 1],[1 1 0],cs);
      ori2 = orientation('Miller',[1 1 1],[1 1 2],cs);
            
      f = fibre.fit(ori1,ori2);
    end
    
    function f = epsilon(cs)
    % the epsilon fibre
      
      ori1 = orientation('Miller',[0 0 1],[1 1 0],cs);
      ori2 = orientation('Miller',[1 1 1],[1 1 2],cs);
            
      f = fibre.fit(ori1,ori2);
    end
    
    function f = eta(cs)
    % the epsilon fibre
      
      ori1 = orientation('Miller',[0 0 1],[1 0 0],cs);
      ori2 = orientation('Miller',[0 1 1],[1 0 0],cs);
            
      f = fibre.fit(ori1,ori2);
    end
    
    function f = tau(cs)
      % the beta fibre
      
      ori1 = orientation('Miller',[0 0 1],[1 1 0],cs);
      ori2 = orientation('Miller',[0 1 1],[1 0 0],cs);
            
      f = fibre.fit(ori1,ori2);
    end
    
    
    function f = fit(ori1,ori2)
      % determines the fibre that fits best a list of orientations
      
      if nargin == 1
        
        [~,~,~,eigv] = mean(ori1);
      
        ori = orientation(quaternion(eigv(:,1:2)),ori1.CS,ori1.SS);
        ori1 = ori(1);
        ori2 = ori(2);
      end
        
      mori = rotation(ori1 * inv(ori2)); %#ok<MINV>
      
      r = mori.axis;
      h = ori1 \ r;
      
      f = fibre(h,r);
              
    end  
  end    
end
  