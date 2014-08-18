classdef ipdfHSVOrientationMapping < ipdfOrientationMapping & HSVOrientationMapping
  % defines an orientation mapping based on a certain inverse pole figure
  %   Detailed explanation goes here

  
  
  methods
    function oM = ipdfHSVOrientationMapping(varargin)
      oM = oM@HSVOrientationMapping(varargin{:});      
    end
    
    function rgb = Miller2color(oM,h)
      rgb = oM.h2color(h);
    end        
    
  end
  
end
