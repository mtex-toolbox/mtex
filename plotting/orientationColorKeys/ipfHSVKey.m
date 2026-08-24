classdef ipfHSVKey < ipfColorKey
% converts orientations to rgb values by the MTEX inverse pole figure key
%
% The MTEX default inverse pole figure coloring: white in the center of the
% fundamental sector, the primary colors at its vertices. Its parameters
% are those of the underlying @HSVDirectionKey and are forwarded to it.
%
% Syntax
%   oM = ipfHSVKey(cs)
%   oM = ipfHSVKey(ebsd('phaseName'))
%   rgb = oM.orientation2color(ori)
%
% Input
%  cs   - @crystalSymmetry
%  ebsd - @EBSD
%  ori  - @orientation
%
% Output
%  oM  - @ipfHSVKey
%  rgb - list of RGB triplets
%
% Class Properties
%  ipfDirection      - the specimen direction the inverse pole figure is of
%  whiteCenter       - @vector3d that becomes white
%  colorStretching   - saturation exponent
%  grayValue         - [min max] gray of the two subsectors
%  grayGradient      - how fast the gray fades away from the center
%  maxAngle          - restrict the key to a ball around whiteCenter
%  colorPostRotation - @rotation applied to the color space
%
% Example
%
%   mtexdata titanium
%   oM = ipfHSVKey(ebsd);
%   plot(oM)
%
% See also
% ipfColorKey HSVDirectionKey ipfTSLKey EBSDIPFMap
%
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
