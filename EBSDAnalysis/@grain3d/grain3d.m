classdef grain3d < phaseList & dynProp
  % class representing 3 dimensional grains

  properties  % with as many rows as data
    id = []
    I_CF            % incidenc matrix cells x face
    grainSize = []  % number of measurements per grain
  end

  properties
    boundary
  end

  properties (Dependent)
    V     %verticies
    poly  %
    meanOrientation
  end

  methods

    function grains = grain3d(V, poly, I_CF, ori, CSList, phaseList)
      %contructor

      if nargin >= 3
        grains.id=(1:size(I_CF,1)).';
        grains.I_CF=I_CF;
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

      if nargin>=7
        grains.phaseMap = phaseMap;
      else
        grains.phaseMap = 1:length(grains.CSList);
      end

      grains.grainSize = ones(size(poly));

      % compute neighbouring grains to a boundary segment
      grainId = zeros(size(I_CF,2),2);
      [a,b] = find(I_CF == 1);
      grainId(b,1) = a;
      [a,b] = find(I_CF == -1);
      grainId(b,2) = a;

      % boundary
      grains.boundary=grain3Boundary(V, poly, grainId, grains.phaseId, ...
        grains.CSList, grains.phaseMap);

    end

    function V = get.V(grains)
      V = grains.boundary.V;
    end

    function poly = get.poly(grains)
      poly = grains.boundary.poly;
    end

    function ori = get.meanOrientation(grains)
      if isempty(grains)
        ori = orientation;
      else
        ori = orientation(grains.prop.meanRotation,grains.CS);
        
        % set not indexed orientations to nan
        if ~all(grains.isIndexed), ori(~grains.isIndexed) = NaN; end
      end
    end

  end

  methods (Static = true)
    [grain3d] = load(fname)
  end
end

