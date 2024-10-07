classdef gnonomicProjection < sphericalProjection
  % gnonomic projection
  
  methods 
        
     function proj = gnonomicProjection(varargin)
      proj = proj@sphericalProjection(varargin{:});
    end
    
    function [x,y] = project(sP,v,varargin)
      % compute polar angles
  
      [rho,theta] = project@sphericalProjection(sP,v,varargin{:});

      % formula for stereographic projection
      r =  tan(theta);
            
      % compute coordinates
      x = reshape(cos(rho) .* r,size(v));
      y = reshape(sin(rho) .* r,size(v));
      
    end
    
    function v = iproject(sP,x,y)
      rho = atan2(y,x);
      theta = atan(sqrt(x.^2 + y.^2));
      v = vector3d.byPolar(theta,rho);
      if sP.isLower, v.z = -v.z; end
      v = sP.pC.rot * v;
    end
    
  end
  
end
