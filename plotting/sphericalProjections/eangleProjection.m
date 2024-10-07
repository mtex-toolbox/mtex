classdef eangleProjection < sphericalProjection
  % stereographic, conformal or equal angle projection
  
  methods 
        
     function proj = eangleProjection(varargin)
      proj = proj@sphericalProjection(varargin{:});
    end
    
    function [x,y] = project(sP,v,varargin)
      % compute polar angles
  
      [rho,theta] = project@sphericalProjection(sP,v,varargin{:});
      
      % formula for stereographic projection
      r =  tan(theta/2);
            
      % compute coordinates
      x = reshape(cos(rho) .* r,size(v));
      y = reshape(sin(rho) .* r,size(v));
      
    end
    
    function v = iproject(sP,x,y)
      rho = atan2(y,x);
      theta = 2*atan(sqrt(x.^2 + y.^2));
      v = vector3d.byPolar(theta,rho);
      if sP.isLower, v.z = -v.z; end
      v = sP.pC.rot * v;
    end
    
  end
  
end
