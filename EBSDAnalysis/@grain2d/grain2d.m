classdef grain2d < phaseList & dynProp
  % class representing two dimensional grains
  %
  % Syntax
  %   grains = grain2d(V, poly, ori, CSList, phaseId, phaseMap, 'id', idList)
  %
  % Input
  %  V    - n x 3 list of vertices
  %  poly - cell array of the polyhedrons
  %  ori  - array of mean orientations
  %  CSList   - cell array of symmetries
  %  phaseId  - list of phaseId for each grain
  %  phaseMap -
  %  idList   - option to provide grain ids
  %
  % Example
  %
  %   V = [0 0; 1 0; 2 0; 0 1; 1 1; 2 1];
  %   poly = {[1 2 5 4 1];[2 3 6 5 2]};
  %   rot = rotation.rand(2,1);
  %   grains = grain2d(V,poly,rot,crystalSymmetry.load('quartz'))
  %   plot(grains,grains.meanOrientation)
  %
  % Class Properties
  %  phaseId - phase identifier of each grain
  %  id            - id of each grain
  %  poly          - cell list of the vertex ids of each grain (index to V)
  %  V             - list of vertices (x,y coordinates)
  %  boundary      - @grainBoundary
  %  innerBoundary - @grainBoundary
  %  triplePoints  - @triplePoints
  %  grainSize     - number if pixels belonging to the grain
  %  GOS           - grain orientation spread
  %  meanOrientation - average grain orientation (<GrainOrientationParameters.html only single phase>)
  %
  % See also
  % GrainReconstruction GrainSpatialPlots SelectingGrains ShapeParameter
  
  % properties with as many rows as data
  properties
    poly={}    % cell list of polygons forming the grains
    id=[]      % id of each grain    
    grainSize = [] % number of measurements per grain
  end
  
  properties (Hidden = true)
    inclusionId = []; % number of elements in poly that model inclusions    
  end
  
  % general properties
  properties    
    boundary = grainBoundary % boundary of the grains
    innerBoundary = grainBoundary % inner grain boundary
  end
    
  properties (Dependent = true)
    meanOrientation  % mean orientation
    V                % reduced list vertices @vector3d
    allV             % full list vertices @vector3d
    scanUnit         % unit of the spatial coordinates
    GOS              % intragranular average misorientation angle    
    x                % x coordinates of the vertices of the grains
    y                % y coordinates of the vertices of the grains
    triplePoints     % triple points
  end
  
  properties (Dependent = true, Access = protected)
    idV        % active vertices
    rot2Plane  % rotation to xy plane
    plottingConvention % plotting convention
    N          % normal direction of the pseudo3d data    
  end
  
  methods

    function grains = grain2d(V, poly, varargin)
      % constructor
      % 
      % Input
      %  V    - @vector3d
      %  poly - cell array of the polyhedrons
      %  ori  - array of mean orientations
      %  CSList   - cell array of symmetries
      %  phaseId  - list of phaseId for each grain
      %  phaseMap - 
      
      if nargin == 0, return;end

      grains.poly = poly;
      grains.inclusionId = cellfun(@(p) length(p) - find(p(2:end)==p(1),1),poly)-1;

      if check_option(varargin,'id')
        grains.id = reshape(get_option(varargin,'id'),size(poly));
        varargin = delete_option(varargin,'id',1);
      else
        grains.id = (1:length(poly)).';
      end

      if length(varargin)>=1 && ~isempty(varargin{1})
        grains.prop.meanRotation = varargin{1};
      else
        grains.prop.meanRotation = rotation.nan(length(poly),1);        
      end

      if length(varargin)>=2
        grains.CSList = ensurecell(varargin{2});
      else
        grains.CSList = {'notIndexed'};
      end

      if length(varargin)>=3
        grains.phaseId = varargin{3};
      else
        grains.phaseId = ones(length(poly),1);
      end
      
      if length(varargin)>=4
        grains.phaseMap = varargin{4};
      else
        grains.phaseMap = 1:length(grains.CSList);
      end

      grains.grainSize = ones(size(poly));
      
      if isa(V,'grainBoundary') % grain boundary already given
        grains.boundary = V;
      else % otherwise compute grain boundary
        
        % compute boundary segments
        F = arrayfun(@(i) poly{i}([1:end-grains.inclusionId(i)-1;2:end-grains.inclusionId(i)]),...
          1:length(poly),'uniformOutput',false);
        F = [F{:}].';

        lBnd = cellfun(@(p) length(p),poly) - grains.inclusionId -1;

        grainIds = repelem(1:length(grains),lBnd);

        [~,iF,iG] = unique(sort(F,2),'rows','stable');
        F = F(iF,:);
        
        % compute boundary grainIds
        grainId = zeros(size(F));
        grainId(:,1) = grainIds(iF); % first column - first apperance

        % second column - second appearance
        col2 = true(size(iG,1),1);
        col2(iF) = false;
        grainId(iG(col2),2) = grainIds(col2);
        
        % compute misorientation from mean orientations of the grain
        mori = rotation.nan(size(F,1),1);
        isNotBoundary = all(grainId,2);
        mori(isNotBoundary) = ...
          inv(grains.prop.meanRotation(grainId(isNotBoundary,2))) ...
          .* grains.prop.meanRotation(grainId(isNotBoundary,1));

        grains.boundary = grainBoundary(V,F,grainId,grains.id,...
          grains.phaseId,mori,grains.CSList,grains.phaseMap);
        
      end

      % determine a normal direction such that the area is positive
      grains.N = perp(grains.allV - grains.allV(1));
      grains.N.antipodal = false;
      if sum(grains.area) < 0, grains.N = -grains.N; end

      % check for 3d plane
      d=dot(grains.allV(1),grains.N);
      assert(max(abs(dot(grains.allV,grains.N)-d))<abs(d)*1e-5 ...
        || max(abs(dot(grains.allV,grains.N)-d))<1e-11,'grains are not within one plane');

    end
    
    function V = get.allV(grains)
      V = grains.boundary.allV;
    end

    function V = get.V(grains)
      error('implement this!')
      V = grains.boundary.V;
    end

    function N = get.N(grains)
      N = grains.boundary.N;
    end

    function x = get.x(grains)
      x = grains.allV.x;
    end
    
    function y = get.y(grains)
      y = grains.allV.y;
    end
    
    function grains = set.allV(grains,V)
      grains.boundary.allV = V;
      grains.innerBoundary.allV = V;
    end

    function grains = set.N(grains,N)
      grains.boundary.N = N;
      grains.innerBoundary.N = N;
    end
    
    function idV = get.idV(grains)
      
      isCell = cellfun('isclass',grains.poly,'cell');
      polygons = grains.poly;
      polygons(isCell) = cellfun(@(x) [x{:}] ,grains.poly(isCell),'UniformOutput',false);
      idV = unique([polygons{:}]);
      
    end
    
    function rot = get.rot2Plane(grains)
      rot = rotation.map(grains.N,vector3d.Z);
    end

    function pC = get.plottingConvention(grains)
      pC = grains.allV.plottingConvention;
    end

    function grains = set.plottingConvention(grains,pC)
      grains.allV.plottingConvention = pC;
    end


    function varargout = size(grains,varargin)
      [varargout{1:nargout}] = size(grains.id,varargin{:});
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
      end
      
    end

    function gos = get.GOS(grains)
      gos = grains.prop.GOS;
    end
    
    function unit = get.scanUnit(grains)
      unit = grains.boundary.scanUnit;
    end

    function grains = set.scanUnit(grains,unit)
      grains.boundary.scanUnit = unit;
      grains.innerBoundary.scanUnit = unit;
    end
    
    function tP = get.triplePoints(grains)
      tP = grains.boundary.triplePoints;
    end
    
    function grains = set.triplePoints(grains,tP)
      grains.boundary.triplePoints = tP;
    end
    
    function grains = update(grains)
      
      grains.boundary = grains.boundary.update(grains);
      grains.innerBoundary = grains.innerBoundary.update(grains);
      grains.triplePoints = grains.triplePoints.update(grains);
      
    end
    
  end

  methods (Static = true)
    
    [grain2d] = load(fname)
    
    function grains = loadobj(s)
      % called by Matlab when an object is loaded from an .mat file
      % this overloaded method ensures compatibility with older MTEX
      % versions
      
      % transform to class if not yet done
      if isa(s,'grain2d')
        grains = s; 
      else
        grains = EBSD(vector3d,s.rot,s.phaseId,s.CSList,s.prop);
        grains.opt = s.opt;
        grains.scanUnit = s.scanUnit;
      end
      
      % ensure V is vector3d
      if isa(grains.allV,'double')
        grains.allV = vector3d(grains.allV(:,1),grains.allV(:,2),0);
      end

    end

  end

end

