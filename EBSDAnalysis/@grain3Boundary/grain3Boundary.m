classdef grain3Boundary < phaseList & dynProp

  properties  %with as many rows as data
    poly  %cell arry with all faces
  end
  
  properties
    V     %verticies
  end

  methods

    function gB = grain3Boundary(V,poly)
      
      if isa(V, 'vector3d')

      elseif (isnumeric(V) && (size(V,2)==3))
        V=vector3d(V);
      else
        error 'invalid V'
      end

      gB.V=V;
      gB.poly=poly;
      
    end

  end

end