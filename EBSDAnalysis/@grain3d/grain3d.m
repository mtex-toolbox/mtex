classdef grain3d < phaseList & dynProp
  % class representing 3 dimensional grains

  properties  % with as many rows as data
    id = []
    I_GF            % incidence matrix grains x face 
                    % for -1 face normals are pointing inside
    grainSize = []  % number of measurements per grain
  end

  properties
    boundary
  end

  properties (Dependent)
    V     % vertices
    allV  % all vertices
    F     % n x 1 cell array or n x 3 array with all faces
    meanOrientation
    numFaces  % number of boundary faces per grain
    extent
  end

  methods

    function grains = grain3d(V, F, I_GF, ori, CSList, phaseList)
      % constructor

      if nargin >= 3
        grains.id=(1:size(I_GF,1)).';
        grains.I_GF=I_GF;
      else
        error 'too less arguments'
      end

      if nargin>=4 && ~isempty(ori)
        grains.prop.meanRotation = ori;
      else
        grains.prop.meanRotation = rotation.nan(length(F),1);        
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

      grains.grainSize = ones(length(F),1);

      % compute neighboring grains to a boundary segment
      grainId = zeros(size(I_GF,2),2);
      [a,b] = find(I_GF == 1);
      grainId(b,1) = a;
      [a,b] = find(I_GF == -1);
      grainId(b,2) = a;

      % compute misorientation from mean orientations of the grain
      mori = rotation.nan(size(grainId,1),1);
      isNotBoundary = all(grainId,2);
      mori(isNotBoundary) = ...
        inv(grains.prop.meanRotation(grainId(isNotBoundary,2))) ...
        .* grains.prop.meanRotation(grainId(isNotBoundary,1));

      % boundary
      grains.boundary = grain3Boundary(V, F, grainId, grainId, grains.phaseId, ...
        mori, grains.CSList, grains.phaseMap);

    end

    function ext= get.extent(grains)
      V = grains.boundary.V; %#ok<PROP>
      ext = [min(V.x) max(V.x) min(V.y) max(V.y) min(V.z) max(V.z)]; %#ok<PROP>
    end

    function V = get.V(grains)
      error('implement this!')
    end

    function V = get.allV(grains)
      V = grains.boundary.allV;
    end
   
    function grains = set.allV(grains,V)
      grains.boundary.allV = V;
    end

    function F = get.F(grains)
      F = grains.boundary.F;
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

    function num = get.numFaces(grains)
      num = sum(logical(grains.I_GF),2);
    end

  end

  methods (Static = true)
    grain3d = load(fname,varargin)
  end
end

