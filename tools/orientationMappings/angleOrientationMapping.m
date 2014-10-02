classdef angleOrientationMapping < orientationMapping
  % 
  %   Detailed explanation goes here
  
  
  methods
    function oM = angleOrientationMapping(varargin)
      oM = oM@orientationMapping(varargin{:});
    end
  end
  
  methods
    function c = orientation2color(oM,ori)
      ori.CS = oM.CS1;
      ori.SS = oM.CS2;
      c = angle(ori) ./ degree;
    end
  end
end
