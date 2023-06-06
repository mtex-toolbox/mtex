classdef grain3d ...< phaseList & dynProp
  % class representing 3 dimensional grains

  properties  % with as many rows as data
    id=[]
  end

  properties
    boundary
  end

  properties (Dependent)
    V     %verticies
    poly  %cell arry with all faces
    I_CF  %incidenc matrix cells x face
  end

  methods

    function grains = grain3d(V,poly,I_CF)
      %contructor

      grains.id=(1:size(I_CF,1)).';
      grains.boundary=grain3Boundary(V,poly,I_CF);
    end

    function V = get.V(grains)
      V = grains.boundary.V;
    end

    function poly = get.poly(grains)
      poly = grains.boundary.poly;
    end

    function I_CF = get.I_CF(grains)
      I_CF = grains.boundary.I_CF;
    end

  end

  methods (Static = true)
    [grain3d] = load(fname)
  end
end

