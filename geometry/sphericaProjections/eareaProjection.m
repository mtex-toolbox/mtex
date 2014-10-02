classdef eareaProjection < sphericalProjection
  %equal area projection
  
  methods 
        
    function proj = eareaProjection(varargin)
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
      v = vector3d('theta',theta,'rho',rho);
    end
    
  end
  
end
