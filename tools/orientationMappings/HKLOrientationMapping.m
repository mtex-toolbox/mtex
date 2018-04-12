classdef HKLOrientationMapping < ipfOrientationMapping
  % defines an orientation mapping based on a certain inverse pole figure
  %   Detailed explanation goes here
    
  methods
    function oM = HKLOrientationMapping(varargin)
      oM = oM@ipfOrientationMapping(varargin{:});      
      oM.CS1 = oM.CS1.Laue;
      
      oM.dirMap = HKLDirectionMapping(oM.CS1);
    end
        
  end  
end
