classdef (InferiorClasses = {?rotation,?quaternion}) DelaunaySO3 < orientation
% 
% Syntax
%   
%   % define a Delaunay trinangulation from a list of orientations
%   DSO3 = DelaunaySO3(ori) 
%
  properties
        
    tetra          % list of vertices of the tetrahegons
    tetraNeighbour % neigbouring tetraeders orderd as faces
    lookup         % lookup table orientation -> tetrahedrons
                       
  end
    
  methods
    
    function DSO3 = DelaunaySO3(varargin)
      
      DSO3 = DSO3@orientation(varargin{:});
    
      if nargin == 0, return; end
      
      % pertube data a bit
      % it would be better if this would be needed only for the
      % triangulation, but for some reason we cant skip it
      [DSO3.a,DSO3.b,DSO3.c,DSO3.d] = double(perturbe(DSO3,0.05*degree));
      
      % compute tetrahegons
      DSO3.tetra = calcDelaunay2(DSO3);
     
      % compute neighbouring list
      DSO3.tetraNeighbour = calcNeighbour(DSO3.tetra);
      
      % compute lookup table
      res = 40*degree;
      for i = 1:4
        res = res / 2;
        DSO3.lookup = calcLookUp(DSO3,res);
      end
    end
          
end

end
