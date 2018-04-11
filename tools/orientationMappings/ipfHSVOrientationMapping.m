classdef ipdfHSVOrientationMapping < ipdfOrientationMapping & HSVOrientationMapping
% defines an orientation mapping based on a certain inverse pole figure
  
  
  methods
    function oM = ipdfHSVOrientationMapping(varargin)
      oM = oM@HSVOrientationMapping(varargin{:});
      
       if isa(oM.CS2,'crystalSymmetry')
        oM.inversePoleFigureDirection = Miller(oM.whiteCenter,oM.CS2);
      else
        oM.inversePoleFigureDirection = zvector;
      end
    end
    
    function rgb = Miller2color(oM,h)
      rgb = oM.h2color(h);
    end        
    
  end
  
end
