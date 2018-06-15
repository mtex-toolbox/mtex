classdef squareProjection < sphericalProjection
  %equal area projection
  
  methods 
        
    function proj = squareProjection(varargin)
      proj = proj@sphericalProjection(varargin{:});
    end
    
    function [x,y] = project(sP,v,varargin)
      
      % remove points outside the plotting region
      v = v.normalize;
      sP.sR.antipodal = false; v.antipodal = false;
      v(~sP.sR.checkInside(v)) = NaN;
      
      % map to upper hemisphere
      v(v.z<0) = -v(v.z<0);
      
      [a,b,c] = double(v);
           
      x = zeros(size(v)); y = x;
      id = abs(a) > abs(b);
      
      % formula for equal area projection
      lambda = sign(a(id)) .* sqrt(2*(1-c(id))); 
      x(id) = sqrt(pi)/2 * lambda;
      y(id) = 2/sqrt(pi) * lambda .* atan(b(id)./a(id));
   
      id = ~id;
      lambda = sign(b(id)) .* sqrt(2*(1-c(id))); 
      x(id) = 2/sqrt(pi) * lambda .* atan(a(id)./b(id));
      y(id) = sqrt(pi)/2 * lambda;
      
      
      
    end
    
    function v = iproject(sP,x,y)
      
      id = abs(x) > abs(y);
      a(id) = 2*x(id)./pi.*sqrt(pi-x(id).^2) .* cos(pi*y(id)./4./x(id));
      b(id) = 2*x(id)./pi.*sqrt(pi-x(id).^2) .* sin(pi*y(id)./4./x(id));
      c(id) = 1-2/pi*x(id).^2;
      
      id = ~id;
      a(id) = 2*y(id)./pi.*sqrt(pi-y(id).^2) .* sin(pi*x(id)./4./y(id));
      b(id) = 2*y(id)./pi.*sqrt(pi-y(id).^2) .* cos(pi*x(id)./4./y(id));
      c(id) = 1-2/pi*y(id).^2;
      
      v = reshape(vector3d(a,b,c),size(x));
    end
    
  end

  methods (Static=true)
    
    function test
      
      [x,y] = meshgrid(linspace(-sqrt(pi/2),sqrt(pi/2),25));
      
      sP = squareProjection;
      v = sP.iproject(x,y);
      
      %plot(v,'upper')
      
      id = (v.z < 0.01);
      vv = [v,-v(~id)]
      
      plot(vv,'pcolor','halfwidth',2*degree,'upper')
      
    end
    
    
  end
  
end
