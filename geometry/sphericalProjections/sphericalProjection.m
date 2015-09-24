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
  
  methods (Static = true)
    
    function proj = new(sR,varargin)

      switch get_option(varargin,'projection','earea')
        
        case 'plain'
    
          proj = plainProjection(sR);
    
        case {'stereo','eangle'} % equal angle
    
          proj = eangleProjection(sR);

        case 'edist' % equal distance
    
          proj = edistProjection(sR);

        case {'earea','schmidt'} % equal area

          proj = eareaProjection(sR);
        
        case 'orthographic'

          proj = orthographicProjection(sR);
    
        otherwise
    
          error('%s\n%s','Unknown projection specified! Valid projections are:',...
            'plain, stereo, eangle, edist, earea, schmidt, orthographic')
    
      end

      if ~isa(proj,'plainProjection') && sR.isUpper && sR.isLower
        proj = [proj,proj];
        proj(1).sR = proj(1).sR.restrict2Upper;
        proj(2).sR = proj(2).sR.restrict2Lower;
      end
      
    end
    
  end
end
