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
    
    function shape = shape2d(V,CS)
      % list of vertices [x y]
      
      if nargin == 0, return;end

      N = size(V,1);
      shape.poly = {[1:N,1].'};
      shape.inclusionId = zeros(N,1);

      if nargin>=2
        shape.CSList = {CS};
      else
        shape.CSList = {'notIndexed'};
      end

      shape.phaseId = 1;
      shape.phaseMap = 1;
      shape.id = 1;
      shape.grainSize = 1;
      
      if isa(V,'grainBoundary') % grain boundary already given
        shape.boundary = V;
      else % otherwise compute grain boundary
                
        F = [1:N;[2:N 1]].';
        grainId = [zeros(N,1),ones(N,1)];
        
        shape.boundary = grainBoundary(V,F,grainId,1,...
          1,nan,shape.CSList,shape.phaseMap,1,'noTriplePoints');
        
      end

    end

    function Vs = get.Vs(shape)
      Vs = shape.boundary.allV;
    end
    
    function theta = get.theta(shape)
      theta = angle(vector3d.X,shape.boundary.allV,shape.N);
    end
    
    function rho = get.rho(shape)
      rho = norm(shape.boundary.allV);
    end
  end
    
  methods (Static = true)
    shape = byRhoTheta(rho,theta)
    shape = byFV(F,V,varargin)
  end
  
end
