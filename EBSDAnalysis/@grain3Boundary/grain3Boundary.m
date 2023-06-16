classdef grain3Boundary < phaseList & dynProp

  properties  %with as many rows as data
    poly  %cell arry with all faces
  end
  
  properties
    V     %verticies
  end

  methods

    function gB = grain3Boundary(V,poly)
      gB.V=V;
      gB.poly=poly;
    end

  end

end