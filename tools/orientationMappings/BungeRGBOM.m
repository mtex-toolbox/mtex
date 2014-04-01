classdef BungeRGBOM < orientationMapping
  % 
  %   Detailed explanation goes here
  
  properties
    center = idquaternion
    phi1Range
    phi2Range
    PhiRange
  end
  
  
  methods
    function oM = BungeRGBOM(varargin)
      
      oM = oM@orientationMapping(varargin{:});
      
      [maxphi1,maxPhi,maxphi2] = getFundamentalRegion(oM.CS1,oM.CS2);
      
      oM.phi1Range = [0,maxphi1];
      oM.phi2Range = [0,maxphi2];
      oM.PhiRange = [0,maxPhi];
      
    end
  end
  
  methods
    function rgb = orientation2color(oM,ori)
      
      % get reference orientation
      if oM.center ~= idquaternion

        % restrict to fundamental region
        ori = project2FundamentalRegion(ori,oM.center);
      end

      [maxphi1,maxPhi,maxphi2] = getFundamentalRegion(oM.CS1,oM.CS2);
            
      % convert to euler angles angles
      [phi1,Phi,phi2] = Euler(ori,'Bunge');
      phi1 = mod(phi1,maxphi1);
      phi2 = mod(phi2,maxphi2);
      % this is not realy correct
      % it should change phi1 or phi2 as well
      ind = Phi>maxPhi;
      Phi(ind) = pi - Phi(ind);
      
      r = (phi1 - oM.phi1Range(1))./(oM.phi1Range(2)-oM.phi1Range(1));
      g = (Phi - oM.PhiRange(1))./(oM.PhiRange(2)-oM.PhiRange(1));
      b = (phi2 - oM.phi2Range(1))./(oM.phi2Range(2)-oM.phi2Range(1));
      
      rgb = [r(:),g(:),b(:)];
      
    end
  end
end
