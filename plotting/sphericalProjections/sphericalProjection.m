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
      
      [theta,rho] = polar(v);

      % restrict to plotable domain
      if ~check_option(varargin,'complete')
        ind = ~sP.sR.checkInside(v,varargin{:});
        rho(ind) = NaN; theta(ind) = NaN;
      end
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
