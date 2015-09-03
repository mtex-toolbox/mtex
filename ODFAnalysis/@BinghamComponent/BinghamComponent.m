classdef BinghamComponent < ODFComponent
  
  properties
    A
    kappa = [1,0,0,0];
    antipodal = false;
  end
 
  properties (Dependent = true)
    CS % crystal symmetry
    SS % specimen symmetry
  end
  
  methods
    
    function component = BinghamComponent(kappa,A)
        
      if nargin == 0, return;end
      
      component.kappa = kappa(:);
      component.A = A;

    end
    
    function component = set.CS(component,CS)
      component.A.CS = CS;
    end
    
    function CS = get.CS(component)
      CS = component.A.CS;      
    end
    
    function component = set.SS(component,SS)
      component.A.SS = SS;
    end
    
    function SS = get.SS(component)
      SS = component.A.SS;
    end
    
  end
  
end
