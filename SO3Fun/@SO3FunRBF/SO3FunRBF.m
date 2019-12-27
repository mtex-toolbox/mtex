classdef SO3FunRBF < SO3Fun

  properties
    c0 = 0               % constant portion
    center = orientation % center of the components
    psi = deLaValeePoussinKernel % shape of the components
    weights = []         % coefficients
  end

  properties (Dependent = true)
    bandwidth % harmonic degree
    antipodal
    SLeft
    SRight
  end
  
  methods
    
    function SO3F = SO3FunRBF(center,psi,weights,c0)
                 
      if nargin == 0, return;end
      
      SO3F.center  = center;
      SO3F.psi     = psi;
      SO3F.weights = reshape(weights,size(center));
      if nargin > 3, SO3F.c0 = c0; end
      
    end

    
    function SO3F = set.SRight(SO3F,S)
      SO3F.center.CS = S;
    end
    
    function S = get.SRight(SO3F)
      try
        S = SO3F.center.CS;
      catch
        S = specimenSymmetry;
      end
    end
    
    function SO3F = set.SLeft(SO3F,S)
      SO3F.center.SS = S;
    end
    
    function S = get.SLeft(SO3F)
      try
        S = SO3F.center.SS;
      catch
        S = specimenSymmetry;
      end
    end
    
    function SO3F = set.antipodal(SO3F,antipodal)
      SO3F.center.antipodal = antipodal;
    end
        
    function antipodal = get.antipodal(SO3F)
      try
        antipodal = SO3F.center.antipodal;
      catch
        antipodal = false;
      end
    end
    
    function L = get.bandwidth(SO3F)
      L= SO3F.psi.bandwidth;
    end
    
    function SO3F = set.bandwidth(SO3F,L)
      SO3F.psi.bandwidth = L;
    end
    
  end
end
