classdef strainComponent < ODFComponent
% defines an ODF by ...
%

  properties
    sS = slipSystem  % slip system
    E  = tensor      % strain tensor
  end
  
  properties (Dependent = true)
    CS        % crystal symmetry
    SS        % specimen symmetry
    bandwidth % harmonic degree (always inf)
    antipodal % always false
  end
 
 
  methods
    
    function component = strainComponent(sS,E)
                      
      if nargin == 0, return;end
      
      % get slip system
      component.sS = sS;
      component.E = E;
            
    end
    
    function component = set.CS(component,CS)
      component.sS.CS = CS;
    end
    
    function CS = get.CS(component)
      CS = component.sS.CS;      
    end
    
    function component = set.SS(component,SS)

    end
    
    function SS = get.SS(component)
      SS = specimenSymmetry;
    end
    
    function SS = get.antipodal(component)
      SS = false;
    end

    
  end  
end

% Testing Code
% cs = crystalSymmetry('1');
% sS = slipSystem(Miller(1,0,0,cs,'uvw'),Miller(0,1,0,cs,'hkl'))
% sS1 = slipSystem(Miller(0,1,0,cs,'uvw'),Miller(1,0,0,cs,'hkl'))
% sS2 = slipSystem(Miller(0,0,1,cs,'uvw'),Miller(1,0,0,cs,'hkl'))
% sS3 = slipSystem(Miller(0,1,0,cs,'uvw'),Miller(0,0,1,cs,'hkl'))
% odf1 = ODF(strainComponent(sS1),1)
% odf2 = ODF(strainComponent(sS2),1)
% odf3 = ODF(strainComponent(sS3),1)