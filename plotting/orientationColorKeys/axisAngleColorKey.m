classdef axisAngleColorKey < orientationColorKey
  % 
  %   Detailed explanation goes here
  
  properties
    dirMapping % direction mapping
    oriRef 
    maxAngle = inf
  end
  
  methods
    function oM = axisAngleColorKey(varargin)
      oM = oM@orientationColorKey(varargin{:});
      oM.oriRef = get_option(varargin,'center',...
        orientation.id(oM.CS1,oM.CS2));
      
      if isa(oM.CS2,'specimenSymmetry')
        sym = specimenSymmetry;
      else
        sym = properGroup(disjoint(oM.CS1,oM.CS2));
      end
      oM.dirMapping = HSVDirectionKey(sym);

    end
  
    function rgb = orientation2color(oM,ori)
      
      omega = angle(ori,oM.oriRef);
      v = axis(ori,oM.oriRef);
      
      if isinf(oM.maxAngle)
        maxAngle = quantile(reshape(omega,[],1),0.8); %#ok<*PROPLC,*PROP>
      else
        maxAngle = oM.maxAngle;
      end
       
      gray = min(1,omega./maxAngle);
      %gray(gray > 1) = NaN;
      
      rgb = oM.dirMapping.direction2color(v,'grayValue',gray);
      
    end
    
    function plot(key,varargin)
      plot(key.dirMapping,varargin{:});
    end
    
  end
end
