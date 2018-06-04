classdef BungeColorKey < orientationColorKey
  % assigns rgb values to orientations according the the Euler angles
  
  
  properties
    center = quaternion.id
    phi1Range
    phi2Range
    PhiRange
  end
  
  
  methods
    function oM = BungeColorKey(varargin)
      
      oM = oM@orientationColorKey(varargin{:});
      
      [maxphi1,maxPhi,maxphi2] = fundamentalRegionEuler(oM.CS1,oM.CS2);
      
      oM.phi1Range = [0,maxphi1];
      oM.phi2Range = [0,maxphi2];
      oM.PhiRange = [0,maxPhi];
      
    end
  end
  
  methods
    function rgb = orientation2color(oM,ori)
            
      % convert to euler angles angles
      [phi1,Phi,phi2] = project2EulerFR(quaternion(ori),oM.CS1,oM.CS2,'Bunge');
                       
      % colorize Euler angles with red green blue
      r = (phi1 - oM.phi1Range(1))./(oM.phi1Range(2)-oM.phi1Range(1));
      g = (Phi - oM.PhiRange(1))./(oM.PhiRange(2)-oM.PhiRange(1));
      b = (phi2 - oM.phi2Range(1))./(oM.phi2Range(2)-oM.phi2Range(1));
      
      rgb = [r(:),g(:),b(:)];
      
    end
  end
end
