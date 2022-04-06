classdef femComponent < ODFComponent
% defines an ODF by finite elements
%

  properties
    center = DelaunaySO3;   % 
    weights = [];           %
    antipodal = false
  end
  
  properties (Dependent = true)
    CS        % crystal symmetry
    SS        % specimen symmetry
    bandwidth % harmonic degree (always inf)
  end
 
 
  methods
    
    function odf = femODF(center,weights)
                      
      if nargin == 0, return;end
      
      % get center
      odf.center = center;
      
      % get weights
      odf.weights = weights;
      assert(numel(odf.weights) == length(odf.center),...
        'Number of orientations and weights must be equal!');
            
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

    function L = get.bandwidth(component) %#ok<MANU>
      L = inf;
    end
    
    function component = set.bandwidth(component,~)      
    end
    
  end  
end
