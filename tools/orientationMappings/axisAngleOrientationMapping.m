classdef axisAngleOrientationMapping < orientationMapping & HSVOrientationMapping
  % 
  %   Detailed explanation goes here
  
  properties
    center = idquaternion
    maxAngle = 'auto'
  end
  
  methods
    function oM = axisAngleOrientationMapping(varargin)
      oM = oM@HSVOrientationMapping(varargin{:});
      oM.center = get_option(varargin,'center',idquaternion);      
    end
  
    function rgb = orientation2color(oM,ori)
      
      ori = ori.project2FundamentalRegion(oM.center);
      
      if ischar(oM.maxAngle)
        maxAngle = max(reshape(ori.angle,[],1)); %#ok<*PROP>
      else
        maxAngle = oM.maxAngle;
      end
       
      gray = ori.angle./maxAngle;
      gray(gray > 1) = NaN;
      
      rgb = h2color(oM,ori.axis,'grayValue',gray);
      
    end
  end
end
