classdef sphericalProjection
  %sphericalProjection
  
  properties    
    sR = sphericalRegion
    pC = plottingConvention
  end

  properties (Dependent = true)
    antipodal
  end
    
  methods
    
    
    function sP = sphericalProjection(sR,pC)
      
      if nargin > 0, sP.sR = sR; end
      if nargin > 1, sP.pC = pC; end

    end
    
    function [rho,theta] = project(sP,v,varargin)
      % compute polar angles
      
      % map such that projection is towards xy plane
      % and compute there spherical coordinates
      v(~sP.sR.checkInside(v,varargin{:})) = NaN;
      v = v.rmOption('theta','rho');
      [theta,rho] = polar(inv(sP.pC.rot) * v); %#ok<MINV,POLAR>
      
      % map to upper hemisphere
      ind = theta > pi/2+10^(-10);
      theta(ind)  = pi - theta(ind);

      % turn around antipodal vectors
      sP.sR.antipodal = false; v.antipodal = false;
      ind = ~sP.sR.checkInside(v);
      rho(ind) = rho(ind) + pi;

    end
    
    function a = get.antipodal(sP)
      a = sP.sR.antipodal;
    end
    
    function sP = set.antipodal(sP,a)
      sP.sR.antipodal = a;
    end
    
    function out = isUpper(sP)
      out = sP.sR.isUpper(sP.pC);
    end

    function out = isLower(sP)
      out = sP.sR.isLower(sP.pC);
    end

  end
    
end
