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
      
      % project to fundamental region
      h = project2FundamentalRegion(vector3d(h),oM.CS1);   %#ok<ASGLU>
      [theta,rho] = polar(h(:));
      rho = rho - rho_min;

      % get the bounds of the fundamental region
      sR = oM.CS1.fundamentalSector;


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
  
      if any(strcmp(cs.LaueName,{'m-3m','m-3'}))

        maxTheta = maxTheta(rho);
        
      else
        
        ma
        
      end

      % compute RGB values
      r = (1-theta./maxTheta);
      g = theta./maxTheta .* (maxRho - rho) ./ maxRho;
      b = theta./maxTheta .* rho ./ maxRho;

      rgb = [r(:) g(:) b(:)];
    end
  end
  
end
