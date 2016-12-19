classdef orientationRegion
  %sphericalRegion implements a region in orientation space
  % The region is bounded by planes normal to quaternions N i.e., all
  % quaternions q inside a region satisfy the condition dot(q, N) <= 0 or
  % dot(-q, N) <= 0 for all N
  
  properties
    N = quaternion % the nornal vectors of the bounding circles
    V = orientation % list of vertices
    F = {}         % list of faces             
    antipodal = false % whether to identify q and inv(q)
  end
    
  properties (Dependent = true)
    CS1
    CS2
  end
  
  methods
        
    function oR = orientationRegion(N,varargin)
      %

      if nargin > 0 && ~check_option(varargin,'complete') 
        oR.N = N;
      end
      
      % compute vertices
      oR.V = orientation.id(0,varargin{:});
      oR.antipodal = check_option(varargin,'antipodal');
      oR = oR.cleanUp;

    end

    function CS = get.CS1(oR)
      CS = oR.V.CS;
    end
    
    function CS = get.CS2(oR)
      CS = oR.V.SS;
    end
    
  end
  
  end
