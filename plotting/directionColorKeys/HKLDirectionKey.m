classdef HKLDirectionKey < directionColorKey
  
  methods
    
    function dM = HKLDirectionKey(varargin)
      dM@directionColorKey(varargin{:});
      dM.sym = dM.sym.Laue;
      dM.sR = dM.sym.fundamentalSector;
      
      if ismember(dM.sym.id,[2,5,8,11,18,21,24,27,35,42])
        warning('Not a topological correct colormap! Green to blue colorjumps possible');
      end
      
    end
  
    function rgb = direction2color(dM,h,varargin)      
      
      % project to fundamental region
      h = project2FundamentalRegion(vector3d(h),dM.sym);
      [theta,rho] = polar(h(:));
      
      % special case Laue -1
      if strcmp(dM.sym.LaueName,'-1')
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
  
      [~, maxTheta] = dM.sR.thetaRange;
      [minRho,maxRho] = dM.sR.rhoRange;
      
      % compute RGB values
      r = (1-theta./maxTheta);
      g = theta./maxTheta .* (maxRho - rho) ./ (maxRho-minRho);
      b = theta./maxTheta .* (rho - minRho) ./ (maxRho-minRho);

      rgb = [r(:) g(:) b(:)];
    end
  end    
end