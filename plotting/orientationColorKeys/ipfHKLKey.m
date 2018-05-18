classdef ipfHKLKey < ipfColorKey
  % defines an orientation mapping based on a certain inverse pole figure
  %   Detailed explanation goes here
    
  methods
    function oM = ipfHKLKey(varargin)
      oM = oM@ipfColorKey(varargin{:});      
      oM.CS1 = oM.CS1.Laue;
      
      oM.dirMap = HKLDirectionKey(oM.CS1);
    end
        
  end  
end
