classdef grain3d < phaseList & dynProp 
  % class representing 3 dimensional grains

  properties  % with as many rows as data
    id = []
    I_GF            % incidence matrix grains x face 
                    % for -1 face normals are pointing inside
    numPixel = []  % number of measurements per grain
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
    how2plot % plotting convention
    grainSize % depreciated for numPixel
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
        grains.prop.meanRotation = rotation.nan(length(grains.id),1);        
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

      grains.numPixel = ones(length(grains.id),1);

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
      if iscell(grains.F)
        ind = unique([grains.F{:}]);
      else
        ind = unique(grains.F(:));
      end
      V = grains.allV(ind);
    end

    function V = get.allV(grains)
      V = grains.boundary.allV;
    end
   
    function grains = set.allV(grains,V)
      grains.boundary.allV = V;
    end

    function pC = get.how2plot(grains)
      pC = grains.allV.how2plot;
    end

    function grains = set.how2plot(grains,pC)
      grains.allV.how2plot = pC;
    end

    function F = get.F(grains)
      F = grains.boundary.F;
    end

    function ori = get.meanOrientation(grains)
      if isempty(grains)
        ori = orientation;
      else
        ori = orientation(grains.prop.meanRotation,grains.CS);
        ori.SS.how2plot = grains.how2plot;
        
        % set not indexed orientations to nan
        if ~all(grains.isIndexed), ori(~grains.isIndexed) = NaN; end
      end
    end

    function grains = set.meanOrientation(grains,ori)
      if ~isempty(grains)
      
        if isnumeric(ori) && all(isnan(ori(:)))
          grains.prop.meanRotation = rotation.nan(size(grains.prop.meanRotation));
        else
          % update rotation
          grains.prop.meanRotation = rotation(ori);
      
          % update phase
          grains.CS = ori.CS;
        end

        grains = grains.update;
      end
    end

    function num = get.numFaces(grains)
      num = sum(logical(grains.I_GF),2);
    end

    function n = get.grainSize(grains)
      warning('grains.grainSize is depreciated. Please use grains.numPixel instead');
      n = grains.numPixel;
    end

    function grains = set.grainSize(grains,n)
      warning('grains.grainSize is depreciated. Please use grains.numPixel instead');
      grains.numPixel = n;
    end

    function grains = update(grains)
      grains.boundary = grains.boundary.update(grains);
    end


  end

  methods (Static = true)
    grain3d = load(fname,varargin)
  end
end

