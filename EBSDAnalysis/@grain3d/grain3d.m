classdef grain3d < phaseList & dynProp
  % class representing 3 dimensional grains

  properties  % with as many rows as data
    id=[]
    I_CF  %incidenc matrix cells x face
    grainSize = [] % number of measurements per grain
  end

  properties
    boundary
  end

  properties (Dependent)
    V     %verticies
    poly  %cell arry with all faces
  end

  methods

    function grains = grain3d(V,poly,I_CF, ori, CSList, phaseList)
      %contructor

      if nargin >= 3
        grains.id=(1:size(I_CF,1)).';
        grains.I_CF=I_CF;
        grains.boundary=grain3Boundary(V,poly);
      else
        error 'too less arguments'
      end

      if nargin>=4 && ~isempty(ori)
        grains.prop.meanRotation = ori;
      else
        grains.prop.meanRotation = rotation.nan(length(poly),1);        
      end

      if nargin>=5
        grains.CSList = ensurecell(CSList);
      else
        grains.CSList = {'notIndexed'};
      end

      if nargin>=6
        grains.phaseId = phaseList;
      else
        grains.phaseId = ones(length(grains.id),1);
      end

      grains.grainSize = ones(size(poly));

    end

    function V = get.V(grains)
      V = grains.boundary.V;
    end

    function poly = get.poly(grains)
      poly = grains.boundary.poly;
    end

  end

  methods (Static = true)
    [grain3d] = load(fname)
  end
end

