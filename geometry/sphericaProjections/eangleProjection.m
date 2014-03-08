classdef eangleProjection < sphericalProjection
  %equal area projection
  
  methods 
        
     function proj = eangleProjection(varargin)
      proj = proj@sphericalProjection(varargin{:});
    end
    
    function [x,y] = project(sP,v,varargin)
      % compute polar angles
  
      [rho,theta] = project@sphericalProjection(sP,v,varargin{:});

      % formula for equal area projection
      r =  tan(theta/2);
            
      % compute coordinates
      x = reshape(cos(rho) .* r,size(v));
      y = reshape(sin(rho) .* r,size(v));
      
    end
    
    function v = iproject(sP,x,y)
      v = vector3d('theta',x*degree,'rho',y*degree);
    end
    
  end
  
end
