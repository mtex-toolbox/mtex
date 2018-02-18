classdef HKLOrientationMapping < ipdfOrientationMapping
  % defines an orientation mapping based on a certain inverse pole figure
  %   Detailed explanation goes here
    
  properties
    convention = 'theta'
  end
  
  methods
    function oM = HKLOrientationMapping(varargin)
      oM = oM@ipdfOrientationMapping(varargin{:});      
      oM.CS1 = oM.CS1.Laue;
    end
    
    function rgb = Miller2color(oM,h)
      
      % get the bounds of the fundamental region
      sR = oM.CS1.fundamentalSector;
      
      % project to fundamental region
      h = project2FundamentalRegion(vector3d(h),oM.CS1);
      [theta,rho] = polar(h(:));
      
      % special case Laue -1
      if strcmp(oM.CS1.LaueName,'-1')
        maxrho = pi*2/3;
        rrho =  rho+maxrho;
        rrho( rrho> maxrho) = rrho(rrho> maxrho)-pi*2;
        brho = (rho-maxrho);
        brho( brho < -2*maxrho) = brho(brho< -2*maxrho)+pi*2;
        ntheta = abs (pi/2-theta)/(pi/2);
  
        r = (1-ntheta) .*  (maxrho-abs(rrho))/maxrho;
        g = (1-ntheta) .*  (maxrho-abs(rho))/maxrho;
        b = (1-ntheta) .*  (maxrho-abs(brho))/maxrho;
  
        r(r<0) = 0; g(g<0) = 0; b(b<0) = 0;
        rgb = [r(:) g(:) b(:)];
        return
      end
  
      [~, maxTheta] = sR.thetaRange;
      [minRho,maxRho] = sR.rhoRange;
      
      % compute RGB values
      r = (1-theta./maxTheta);
      g = theta./maxTheta .* (maxRho - rho) ./ (maxRho-minRho);
      b = theta./maxTheta .* (rho - minRho) ./ (maxRho-minRho);

      rgb = [r(:) g(:) b(:)];
    end
  end
  
end
