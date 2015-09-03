classdef unimodalComponent < ODFComponent

  properties
    center
    psi = deLaValeePoussinKernel('halfwidth',10*degree);
    weights = 1;
  end

  properties (Dependent = true)
    CS % crystal symmetry
    SS % specimen symmetry
    antipodal % mori =? inv(mori)
  end
  
  methods
    
    function component = unimodalComponent(center,psi,weights)
                 
      if nargin == 0, return;end
      
      component.center = center;
      component.psi = psi;
      component.weights = weights;
      
    end
  
    function component = set.CS(component,CS)
      component.center.CS = CS;
    end
    
    function CS = get.CS(component)
      CS = component.center.CS;      
    end
    
    function component = set.SS(component,SS)
      component.center.SS = SS;
    end
    
    function SS = get.SS(component)
      SS = component.center.SS;
    end
    
    function component = set.antipodal(component,antipodal)
      component.center.antipodal = antipodal;
    end
        
    function antipodal = get.antipodal(component)
      antipodal = component.center.antipodal;      
    end
    
  end
end
