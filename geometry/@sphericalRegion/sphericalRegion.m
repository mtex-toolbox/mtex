classdef sphericalRegion
  %sphericalRegion implements a region region on the sphere
  %   The region is bounded by small circles given by there normal vectors
  %   and the maximum inner product, i.e., all points v inside a region
  %   satisfy the conditions dot(v, N) <= alpha
  
  properties
    N % the nornal vectors of the bounding circles
    alpha % the cosine of the bounding circle
  end
  
  methods
    
    
    function sR = sphericalRegion(N,alpha)
      
      sR.N = N;
      sR.alpha = alpha;
      
    end
    
  end
  
end

