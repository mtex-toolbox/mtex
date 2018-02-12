classdef eangleProjection < sphericalProjection
  % stereographic, conformal or equal angle projection
  
  methods 
        
     function proj = eangleProjection(varargin)
      proj = proj@sphericalProjection(varargin{:});
    end
    
    function [x,y] = project(sP,v,varargin)
      % compute polar angles
  
      [rho,theta] = project@sphericalProjection(sP,v,varargin{:});

      % map to upper hemisphere
      ind = find(theta > pi/2+10^(-10));
      theta(ind)  = pi - theta(ind);

      % turn around antipodal vectors
      sP.sR.antipodal = false; v.antipodal = false;
      ind = ~sP.sR.checkInside(v);
      rho(ind) = rho(ind) + pi;
      
      % formula for stereographic projection
      r =  tan(theta/2);
            
      % compute coordinates
      x = reshape(cos(rho) .* r,size(v));
      y = reshape(sin(rho) .* r,size(v));
      
    end
    
    function v = iproject(sP,x,y)
      rho = atan2(y,x);
      theta = 2*atan(sqrt(x.^2 + y.^2));
      v = vector3d('theta',theta,'rho',rho);
    end
    
  end
  
end
