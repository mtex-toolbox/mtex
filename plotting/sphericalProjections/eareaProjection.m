classdef eareaProjection < sphericalProjection
  %equal area projection
  
  methods 
        
    function proj = eareaProjection(varargin)
      proj = proj@sphericalProjection(varargin{:});
    end
    
    function [x,y] = project(sP,v,varargin)

      % compute polar angles
      [rho,theta] = project@sphericalProjection(sP,v,varargin{:});
      
      % formula for equal area projection
      r =  sqrt(2*(1-cos(theta)));
            
      % compute coordinates
      x = reshape(cos(rho) .* r,size(v));
      y = reshape(sin(rho) .* r,size(v));

    end
    
    function v = iproject(sP,x,y)
      rho = atan2(y,x);
      r = x.^2 + y.^2;
      theta = acos(1-r./2);
      v = vector3d.byPolar(theta,rho);
      if sP.isLower, v.z = -v.z; end
      v = sP.pC.rot * v;
    end
    
  end
  
end
