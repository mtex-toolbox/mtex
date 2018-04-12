classdef axisAngleOrientationMapping < orientationMapping
  % 
  %   Detailed explanation goes here
  
  properties
    dirMapping % direction mapping
    oriRef 
    maxAngle = inf
  end
  
  methods
    function oM = axisAngleOrientationMapping(varargin)
      oM = oM@orientationMapping(varargin{:});
      oM.oriRef = get_option(varargin,'center',...
        orientation.id(oM.CS1,oM.CS2));
      
      oM.dirMapping = HSVDirectionMapping(specimenSymmetry);

    end
  
    function rgb = orientation2color(oM,ori)
      
      omega = angle(ori,oM.oriRef);
      v = axis(ori,oM.oriRef);
      
      if isinf(oM.maxAngle)
        maxAngle = quantile(reshape(omega,[],1),0.95); %#ok<*PROP>
      else
        maxAngle = oM.maxAngle;
      end
       
      gray = min(1,omega./maxAngle);
      %gray(gray > 1) = NaN;
      
      
      rgb = oM.dirMapping.direction2color(v,'grayValue',gray);
      
    end
  end
end
