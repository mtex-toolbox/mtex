classdef grain3Boundary %< phaseList & dynProp

  properties  %with as many rows as data
    I_CF  %incidenc matrix cells x face
  end
  properties
    V     %verticies
    poly  %cell arry with all faces
  end

  methods

    function gB = grain3Boundary(V,poly,I_CF)
      gB.V=V;
      gB.poly=poly;
      gB.I_CF=I_CF;
    end

  end

end