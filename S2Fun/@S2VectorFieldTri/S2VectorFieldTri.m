classdef S2VectorFieldTri < S2VectorField
% a class represeneting a function on the sphere
  
  properties
    tri       % S2Triangulation
    vec = []  % function values
  end
  
  methods
    
    function sVF = S2VectorFieldTri(n,v)
      % initialize a spherical vector field
      
      if nargin == 0, return; end
      
      sVF.vec = v;
      
      if isa(n,'tririangulation')
        sVF.tri = n;
      else
        sVF.tri = S2Triangulation(n);
      end
           
    end
    
  end

end
  



