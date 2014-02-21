classdef fibreComponent < ODFComponent
% defines an fibre symmetric component

  properties
    h
    r
    psi = deLaValeePoussinKernel('halfwidth',10*degree);
    weights = 1;
    SS = symmetry;
  end

  properties (Dependent = true)
    CS % crystal symmetry
  end
  
  methods
    function component = fibreComponent(h,r,weights,psi,SS)
      
      if nargin == 0, return;end
      
      component.h = h;
      component.r = r;
      component.weights = weights;
      component.psi = psi;
      component.SS = SS;
                  
    end
    
    function component = set.CS(component,CS)
      component.h.CS = CS;
    end
    
    function CS = get.CS(component)
      CS = component.h.CS;      
    end
    
    
  end

end
