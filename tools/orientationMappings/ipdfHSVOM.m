classdef ipdfHSVOM < ipdfOrientationMapping
  % defines an orientation mapping based on a certain inverse pole figure
  %   Detailed explanation goes here
    
  methods
    function oM = ipdfHSVOM(varargin)
      oM = oM@ipdfOrientationMapping(varargin{:});
    end
    
    function rgb = Miller2color(oM,h)
      rgb = h2HSV(h,oM.CS1);
    end
  end
  
end
