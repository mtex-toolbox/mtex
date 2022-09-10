classdef shape2d < grain2d


  properties (Dependent=true)
    Vs      % list of vertices
    rho     % radius of polar coords
    theta   % angle of polar coords
  end


  % 1) should be constructed from calcTDF / circdensity (density function from a set of lines)
  % characteristicshape
  % surfor, paror
  % 2) purpose: take advantage of grain functions (long axis direction, aspect ratio..)
  %
  % additional functions I will try to put here: measure of asymmetry
  % nice plotting wrapper (replacing plotTDF)
  
  methods
    
    function shape = shape2d(Vs)
      % list of vertices [x y]
            
      shape = shape@grain2d(Vs,{[1:size(Vs,1),1].'});
      
    end

    function Vs = get.Vs(shape)
      Vs = shape.boundary.V;
    end
    
    function theta = get.theta(shape)
      theta = atan2(shape.boundary.V(:,2),shape.boundary.V(:,1));
    end
    
    function rho = get.rho(shape)
      rho = sqrt(shape.boundary.V(:,2).^2 + shape.boundary.V(:,1).^2);
    end
  end
    
  methods (Static = true)
    v = byRhoTheta(rho,theta)
  end
  
end
