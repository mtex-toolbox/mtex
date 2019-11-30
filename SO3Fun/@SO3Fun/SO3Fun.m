classdef SO3Fun
% a class representing a function on the rotational group

  properties (Abstract = true)
    SLeft  % symmetry that acts from the left
    SRight % symmetry that acts from the right
  end    
  
  properties (Dependent = true)
    CS
    SS 
  end
  
  methods
        
    function CS = get.CS(SO3F)
      CS = SO3F.SRight;
    end
    
    function SS = get.SS(SO3F)
      SS = SO3F.SLeft;
    end
    
    function SO3F = set.CS(SO3F,CS)
      SO3F.SRight = CS;
    end
    
    function SO3F = set.SS(SO3F,SS)
      SO3F.SLeft = SS;
    end
    
  end
  
  
  methods (Abstract = true)
    
    f = eval(F,v,varargin)
    
  end
  
end