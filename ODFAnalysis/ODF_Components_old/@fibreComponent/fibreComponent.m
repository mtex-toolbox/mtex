classdef fibreComponent < ODFComponent
% defines an fibre symmetric component

  properties
    h
    r
    psi = deLaValleePoussinKernel('halfwidth',10*degree); %todo: replace with S2DelaValleePoussin
    weights = 1;
    SS = specimenSymmetry;
    antipodal = false
  end

  properties (Dependent = true)
    CS        % crystal symmetry
    bandwidth % harmonic degree
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
    
    function L = get.bandwidth(component)
      L= component.psi.bandwidth;
    end
    
    function component = set.bandwidth(component,L)
      component.psi.bandwidth = L;
    end
    
    
  end

end
