classdef axisAngleColorKey < orientationColorKey
  %
  % The axisAngleColorKey allows to assign colors to orientations and
  % misorientations according to rotational axes and rotational angles.
  %
  % Syntax
  %
  %   colorKey = axisAngleColorKey(CS1,CS2)
  %
  %   rgb = colorKey.orientation2color(mori);
  %
  %   rgb = colorKey.orientation2color(ori,oriRef);
  %
  % Input
  %  CS1, CS2 - @crystalSymmetry, two are only required for misorientations 
  %  ori      - @orientation
  %  oriRef   - (list of) reference @orientation
  %
  % Output
  %  rgb - list of RGB triplets
  %
  % Class Properties
  %  dirMapping - @directionColorKey
  %  oriRef     - reference @orientation
  %  maxAngle   - misorientation angle at which the colors are maximum saturated
  %  thresholdAngle - misorientation angle at which colors are set to NaN 
  %  
  % Description
  %
  % The rotational angle determines the saturation of the color. The
  % saturation increases linearly from 0 (gray) to 1 (full saturated color)
  % within the range |[0,maxAngle]|. Within the range
  % |[maxAngle,thresholdAngle]| the saturation is constant |1|. For angles
  % large than |thresholdAngle| the color is set to NaN.
  %
  % The rotational axis determines the saturated color as defined in the
  % property <directionColorKey.html |dirMapping|>. Be default this is the
  % @HSVDirectionKey which circles through the rainbow colors at the
  % equator and fades to white at the north pole and black at the south
  % pole.
  %
  % If a reference orientation |oriRef| is defined the disorientation angle
  % and the disorientation axis with respect to this reference orientation
  % is considered. If orientations are colorized the disorientation axis is
  % considered in specimen coordinates. If misorientations are colorized
  % the axis is in crystal coordinates.
  % 
  % The reference orientation may be single fixed orientation or a list of
  % orientations. A typical application is to use as the reference
  % orientation the mean orientation of the grain the orientation belongs
  % to
  %
  %  rgb = colorKey.orientation2color(ebsd.orientations, grains(ebsd.grainId).meanOrientation)
  %
  % Reference: Thomsen et al.: Quaternion-based disorientation coloring of
  % orientation maps, 2017
  %
  
  
  properties
    dirMapping % direction mapping
    oriRef     % the reference orientation 
    maxAngle = inf % misorientation angle at which the colors are maximum saturated
    thresholdAngle = inf % misorientation angle at which colors are set to NaN
  end
  
  methods
    function oM = axisAngleColorKey(varargin)
      oM = oM@orientationColorKey(varargin{:});
      oM.oriRef = get_option(varargin,'oriRef');
      
      if isa(oM.CS2,'specimenSymmetry')
        sym = specimenSymmetry;
      else
        sym = properGroup(disjoint(oM.CS1,oM.CS2));
      end
      oM.dirMapping = HSVDirectionKey(sym);

    end
  
    function rgb = orientation2color(oM,ori,oriRef)
      
      if nargin == 3 
        omega = angle(ori,oriRef);
        v = axis(ori,oriRef);
      elseif isempty(oM.oriRef)
        omega = angle(ori);
        v = axis(ori);
      else      
        omega = angle(ori,oM.oriRef);
        v = axis(ori,oM.oriRef);
      end
      
      if isinf(oM.maxAngle)
        maxAngle = quantile(reshape(omega,[],1),0.8); %#ok<*PROPLC,*PROP>
      else
        maxAngle = oM.maxAngle;
      end
       
      gray = min(1,omega./maxAngle);
      gray(omega > oM.thresholdAngle) = NaN;
      
      rgb = oM.dirMapping.direction2color(v,'grayValue',gray);
      
    end
    
    function plot(key,varargin)
      plot(key.dirMapping,varargin{:});
    end
    
  end
end
