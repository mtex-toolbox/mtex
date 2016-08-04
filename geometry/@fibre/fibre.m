classdef fibre
  %fibre is a class representing a fibre in orientation space. Examples are
  %alpha, beta or gamma fibres. In general a fibre is defined by a crystal
  %direction h of type <Miller_index.html Miller> and a specimen direction
  %of type <vector3d_index.html vector3d>.
  
  properties
    h
    r
  end
  
  properties (Dependent = true)
    CS
    SS
    csL
    csR
  end
  
  
  methods
    function f = fibre(h,r)      
      f.h = h;
      f.r = r;
    end
    
    function omega = angle(f,ori)
      % angle fibre to orientation or fibre to fibre
      %
      %
      
      if isa(ori,'orientation')
        omega = angle(ori .\ f.r,f.h);
      else
        error('not yet implemented')
      end
      
    end
    
    function ori = orientation(f,varargin)
      
      npoints = get_option(varargin,'points',100);
            
      omega = linspace(0,2*pi,npoints);
      
      ori = rotation('axis',f.r,'angle',omega) .* rotation('map',f.h,f.r);
      
      if isa(f.CS,'crystalSymmetry') || isa(f.SS,'crystalSymmetry')
        ori = orientation(ori,f.CS,f.SS);
      end
      
    end
   
    function cs = get.CS(f)
      
      if isa(f.h,'Miller')
        cs = f.h.CS;
      else
        cs = specimenSymmetry;
      end
      
    end
    
    function f = set.CS(f,cs)      
      if isa(cs,'crystalSymmetry')
        f.h = Miller(f.h,cs);
      else
        f.h = vector3d(f.h);
      end      
    end
    
    function ss = get.SS(f)      
      if isa(f.r,'Miller')
        ss = f.r.CS;
      else
        ss = specimenSymmetry;
      end      
    end
    
    function f = set.SS(f,ss)      
      if isa(ss,'crystalSymmetry')
        f.r = Miller(f.r,ss);
      else
        f.r = vector3d(f.r);
      end      
    end
    
    function csL = get.csL(f)
      csL = f.SS;
    end
    
    function f = set.csL(f,csL)
      f.SS = csL;
    end
    
    function csR = get.csR(f)
      csR = f.CS;
    end
    
    function f = set.csR(f,csR)
      f.CS = csR;
    end
        
  end
  
  
  methods (Static = true)
       
    function f = alpha(cs)
      % the alpha fibre
      % from: Comprehensive Materials Processing 
      
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
        
      mori = ori1 * inv(ori2); %#ok<MINV>
      
      r = mori.axis('noSymmetry');
      h = ori1 \ r;
      
      f = fibre(h,r);
              
    end 
    
  end    
end
  