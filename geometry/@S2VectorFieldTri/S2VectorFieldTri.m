classdef S2VectorFieldTri < S2VectorField & S2Triangulation
% a class represeneting a function on the sphere
  
  properties
    vec = []  % function values
  end
  
  methods
    
    function sVF = S2VectorFieldTri(n,v)
      % initialize a spherical vector field
      
    if nargin == 0, return; end
      sVF.vec = v;
      
      if isa(n,'S2Triangulation')
      
        sVF.vertices = n.vertices;
        sVF.edges = n.edges;
        sVF.T= n.T;
        sVF.A_V= n.A_V;
        sVF.neighbours = n.neighbours;
        
      else
        sVF.vertices = n;
        sVF = sVF.update;
      end
      
           
    end
    
  end

end
  



