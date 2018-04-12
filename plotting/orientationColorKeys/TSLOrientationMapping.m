classdef TSLOrientationMapping < ipfOrientationMapping
  % orientation mapping as it is used by TSL and HKL software
      
  methods
    function oM =TSLOrientationMapping(varargin)

      oM = oM@ipfOrientationMapping(varargin{:}); 
      oM.dirMap = TSLDirectionMapping(oM.CS1);
      
    end
  end
    
end
