classdef SO3FunBingham < SO3Fun
  
  properties
    A
    kappa = [1,0,0,0];
    antipodal = false;
  end
 
  properties (Dependent = true)    
    bandwidth % harmonic degree
    SLeft
    SRight
  end
  
  methods
    
    function SO3F = BinghamSO3F(kappa,A)
        
      if nargin == 0, return;end
      
      SO3F.kappa = kappa(:);
      SO3F.A = A;

    end
    
    function SO3F = set.SRight(SO3F,S)
      SO3F.A.CS = S;
    end
    
    function S = get.SRight(SO3F)
      S = SO3F.A.CS;      
    end
    
    function SO3F = set.SLeft(SO3F,S)
      SO3F.A.SS = S;
    end
    
    function S = get.SLeft(SO3F)
      S = SO3F.A.SS;
    end
  
    function L = get.bandwidth(SO3F) %#ok<MANU>
      L = inf;
    end
    
    function SO3F = set.bandwidth(SO3F,~)      
    end
    
  end
  
end
