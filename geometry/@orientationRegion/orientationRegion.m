classdef orientationRegion
  % implements a region in orientation space
  % The region is bounded by planes normal to quaternions N i.e., all
  % quaternions q inside a region satisfy the condition dot(q, N) <= 0 or
  % dot(-q, N) <= 0 for all N
  %
  % The most common one is the fundamental region of a pair of symmetries,
  % which is what fundamentalRegion returns and what
  % <orientation.project2FundamentalRegion.html project2FundamentalRegion>
  % projects into. Setting antipodal identifies q and inv(q), i.e. adds
  % grain exchange symmetry.
  %
  % Syntax
  %   oR = fundamentalRegion(cs1,cs2)
  %   oR = orientationRegion(N)
  %   oR = orientationRegion(N,'antipodal')
  %
  % Input
  %  N        - @quaternion, the normals of the bounding faces
  %  cs1, cs2 - @crystalSymmetry
  %
  % Output
  %  oR - @orientationRegion
  %
  % Options
  %  antipodal - identify q and inv(q)
  %
  % Class Properties
  %  N          - @quaternion, the normals of the bounding faces
  %  V          - @orientation, the vertices
  %  F          - the faces as indices into V
  %  E          - the edges
  %  faceCenter - @orientation, center of each face
  %  CS1, CS2   - the two @symmetry
  %  antipodal  - identify q and inv(q)
  %
  % Example
  %
  %   oR = fundamentalRegion(crystalSymmetry('432'))
  %
  % See also
  % fundamentalRegion orientation/project2FundamentalRegion
  %

  properties
    N = quaternion  % the normal vectors of the bounding faces
    V = orientation % list of vertices
    F = {}          % list of faces             
    antipodal = false % whether to identify q and inv(q)
  end
    
  properties (Dependent = true)
    CS1
    CS2
    E % list of edges
    faceCenter
  end
  
  methods
        
    function oR = orientationRegion(varargin)
      %

      if nargin > 0 
        if isa(varargin{1},'quaternion') && ~isa(varargin{1},'symmetry') && ~check_option(varargin,'complete') 
          oR.N = varargin{1};
          varargin{1} = [];
        end
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
    
    function E = get.E(oR)
      
      % extract the vertices
      left = oR.F;
      right = cellfun(@(x) circshift(x,1), oR.F,'UniformOutput',false);
      E = [vertcat(left{:}),vertcat(right{:})];
      
    end
    
    function c = get.faceCenter(oR)
      
      if oR.antipodal
        c = orientation.nan(oR.CS1,oR.CS2,'antipodal');
      else
        c = orientation.nan(oR.CS1,oR.CS2);
      end
      for j = 1:length(oR.F)
        
        c(j) = mean(oR.V(unique(oR.F{j})),'noSymmetry');
        
      end
      
    end
    
  end
  
end
