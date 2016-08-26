classdef fibre
  % fibre is a class representing a fibre in orientation space. Examples
  % are alpha, beta or gamma fibres. In general a fibre is defined by a
  % crystal direction h of type <Miller_index.html Miller> and a specimen
  % direction of type <vector3d_index.html vector3d>.
  %
  % Syntax
  %   cs = crystalSymmetry('432')
  %   f = fibre.alpha(cs) % the alpha fibre
  %
  %   plotPDF(f,Miller(1,0,0,cs))
  %
  % *Predefined fibres*
  %
  %  * fibre.alpha
  %  * fibre.beta
  %  * fibre.gamma
  %  * fibre.tau
  %  * fibre.eta
  %  * fibre.epsion
  %
  
  properties
    h % reference direction 1
    r % reference direction 2
    o1 % starting point
    o2 % end point
  end
  
  properties (Dependent = true)
    CS
    SS
    csL
    csR
    antipodal
  end 
  
  methods
    function f = fibre(h,r)      
      f.h = h;
      f.r = r;
    end

    function n = numArgumentsFromSubscript(varargin)
      n = 0;
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
      elseif isa(f.o1,'orientation')
        ss = f.o1.SS;
      else
        specimenSymmetry;
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
    
    function a = get.antipodal(f)
      a = f.h.antipodal || f.r.antipodal;
    end
        
  end
  
  
  methods (Static = true)
       
    function f = alpha(varargin)
      % the alpha fibre
      % from: Comprehensive Materials Processing 
      
      ori1 = orientation('Miller',[0 0 1],[1 1 0],varargin{:});
      ori2 = orientation('Miller',[1 1 1],[1 1 0],varargin{:});
            
      f = fibre.fit(ori1,ori2,varargin{:});
    end
    
    function f = beta(varargin)
      % the beta fibre
      
      ori1 = orientation('Miller',[1 1 2],[1 1 0],varargin{:});
      ori2 = orientation('Miller',[11 11 8],[4 4 11],varargin{:});
            
      f = fibre.fit(ori1,ori2,varargin{:});
    end
    
    function f = gamma(varargin)
      % the beta fibre
      
      ori1 = orientation('Miller',[1 1 1],[1 1 0],varargin{:});
      ori2 = orientation('Miller',[1 1 1],[1 1 2],varargin{:});
            
      f = fibre.fit(ori1,ori2,varargin{:});
    end
    
    function f = epsilon(varargin)
    % the epsilon fibre
      
      ori1 = orientation('Miller',[0 0 1],[1 1 0],varargin{:});
      ori2 = orientation('Miller',[1 1 1],[1 1 2],varargin{:});
            
      f = fibre.fit(ori1,ori2,varargin{:});
    end
    
    function f = eta(varargin)
    % the epsilon fibre
      
      ori1 = orientation('Miller',[0 0 1],[1 0 0],varargin{:});
      ori2 = orientation('Miller',[0 1 1],[1 0 0],varargin{:});
            
      f = fibre.fit(ori1,ori2,varargin{:});
    end
    
    function f = tau(varargin)
      % the beta fibre
      
      ori1 = orientation('Miller',[0 0 1],[1 1 0],varargin{:});
      ori2 = orientation('Miller',[0 1 1],[1 0 0],varargin{:});
            
      f = fibre.fit(ori1,ori2,varargin{:});
    end
        
    function f = fit(ori1,ori2,varargin)
      % determines the fibre that fits best a list of orientations
      % 
      % Syntax
      %   f = fibre.fit(ori1,ori2) % fibre from ori1 to ori2
      %   f = fibre.fit(ori) % fit fibre to a list of orientations
      %
      % Input
      %  ori1, ori2, ori - @orientation
      %
      % Output
      %  f - @fibre
      %
      
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
      
      f.o1 = ori1;
      
      if nargin >= 2 && ~check_option(varargin,'full')
        f.o2 = ori2;
      end
              
    end 
    
  end    
end
