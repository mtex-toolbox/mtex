classdef axisAngleColorKey < orientationColorKey
  % 
  %
  % Colorizes orientations according to their misorientation axis and
  % misorientation angle in specimen coordinates with respect to some
  % refererence orientation. The angle determines the saturation of the
  % color, i.e., a misorientation angle of 0 corresponds to gray and the
  % misorientation ange at maximum corresponds to fully saturated colors.
  % The saturated color is determined by the misorientation axis. In the
  % X-Y plane the colors circle through the rainbow colors and goes to
  % white and black for z to +/-1.
  % 
  % The reference orientation may be single fixed orientation or a list of
  % orientations. A typical example is to set the reference orientation as
  % the mean orientation of the grain the pixel orientation belongs to.
  %
  % Reference: Thomsen et al.: Quaternion-based disorientation coloring of
  % orientation maps, 2017
  %
  
  
  properties
    dirMapping % direction mapping
    oriRef     % the reference orientation 
    maxAngle = inf % misorientation angle at which the colors are maximum saturated
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
