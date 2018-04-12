classdef ipfHSVKey < ipfColorKey
% defines an orientation mapping based on a certain inverse pole figure
  
properties (Dependent = true)
  colorPostRotation
  colorStretching
  whiteCenter
  grayValue
  grayGradient
  maxAngle
end
 
methods
    
  function oM = ipfHSVKey(varargin)
    oM = oM@ipfColorKey(varargin{:});
  end
  
  
  function rot = get.colorPostRotation(oM)
    rot = oM.dirMap.colorPostRotation;
  end
  
  function set.colorPostRotation(oM,rot)
    oM.dirMap.colorPostRotation=rot;
  end
  
  function cS = get.colorStretching(oM)
    cS = oM.dirMap.colorStretching ;
  end
  
  function set.colorStretching(oM,cS)
    oM.dirMap.colorStretching=cS;
  end
  
  function wC = get.whiteCenter(oM)
    wC = oM.dirMap.whiteCenter;
  end
  
  function set.whiteCenter(oM,wC)
    oM.dirMap.whiteCenter=wC;
  end
  
  function gV = get.grayValue(oM)
    gV = oM.dirMap.grayValue;
  end
  
  function set.grayValue(oM,gV)
    oM.dirMap.grayValue=gV;
  end
  
  function gG = get.grayGradient(oM)
    gG = oM.dirMap.grayGradient;
  end
  
  function set.grayGradient(oM,gG)
    oM.dirMap.grayGradient=gG;
  end
  
  function omega = get.maxAngle(oM)
    omega = oM.dirMap.maxAngle;
  end
  
  function set.maxAngle(oM,omega)
    oM.dirMap.maxAngle=omega;
  end
end

end
