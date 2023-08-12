classdef eareaProjection < sphericalProjection
  %equal area projection
  
  methods 
        
    function proj = eareaProjection(varargin)
      proj = proj@sphericalProjection(varargin{:});
    end
    
    function [x,y,z] = project(sP,v,varargin)
      % compute polar angles
  
      % map such that projection is towards xy plane
      % and compute there spherical coordinats
      v(~sP.sR.checkInside(v,varargin{:})) = NaN;
      [rho,theta] = project@sphericalProjection(sP,inv(sP.pC.rot) * v,'complete',varargin{:});

      % map to upper hemisphere
      ind = theta > pi/2+10^(-10);
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

      % rotate back and turn into coordinates
      [x,y,z] = double(sP.pC.rot * vector3d(x,y,0));

    end
    
    function v = iproject(sP,x,y)
      rho = atan2(y,x);
      r = x.^2 + y.^2;
      theta = acos(1-r./2);
      v = vector3d('theta',theta,'rho',rho);
    end
    
  end
  
end
