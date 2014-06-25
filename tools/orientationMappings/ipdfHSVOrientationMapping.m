classdef ipdfHSVOrientationMapping < ipdfOrientationMapping
  % defines an orientation mapping based on a certain inverse pole figure
  %   Detailed explanation goes here
    
  methods
    function oM = ipdfHSVOrientationMapping(varargin)
      oM = oM@ipdfOrientationMapping(varargin{:});
    end
    
    function rgb = Miller2color(oM,h)
      rgb = oM.h2HSV(h);
    end
  end
  
end
