classdef sphericalProjection
  %sphericalProjection
  
  properties    
    sR = sphericalRegion
  end

  properties (Dependent = true)
    antipodal
  end
    
  methods
    
    
    function sP = sphericalProjection(sR)
      
      if nargin > 0, sP.sR = sR; end
      
    end
    
    function [rho,theta] = project(sP,v,varargin)
      % compute polar angles
      
      [theta,rho] = polar(v);

      % restrict to plotable domain
      ind = ~sP.sR.checkInside(v,varargin{:});
      rho(ind) = NaN; theta(ind) = NaN;
    end
    
    function a = antipodal.get(sP)
      a = sP.sR.antipodal;
    end
    
    function sP = antipodal.set(sP,a)
      sP.sR.antipodal = a;
    end
    
  end
    
end
