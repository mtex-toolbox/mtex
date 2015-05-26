classdef orientationRegion
  %sphericalRegion implements a region in orientation space
  % The region is bounded by planes normal to quaternions N i.e., all
  % quaternions q inside a region satisfy the condition dot(q, N) <= 0 or
  % dot(-q, N) <= 0 for all N
  
  properties
    N = quaternion % the nornal vectors of the bounding circles
    V = quaternion % list of vertices
    F = {}         % list of faces             
    antipodal = false
  end
    
  methods
        
    function oR = orientationRegion(N,varargin)
      %

      if ~check_option(varargin,'complete')
        oR.N = N;
      end  
      
      % compute vertices
      oR = oR.cleanUp;
      
    end            
    
  end
end

