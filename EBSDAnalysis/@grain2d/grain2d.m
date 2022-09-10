classdef grain2d < phaseList & dynProp
  % class representing two dimensional grains
  %
  % Syntax
  %   grains = grain2d(ebsd,V,F,I_DG,I_FD,A_Db)
  %
  % Input
  %   ebsd - EBSD data set
  %   V    - list of vertices
  %   F    - list of edges
  %   I_DG - incidence matrix - ebsd cells x grains
  %   I_FD - incidence matrix - edges x ebsd cells
  %   A_Db - adjacense matrix of cells
  %
  % Class Properties
  %  phaseId - phase identifier of each grain
  %  id            - id of each grain
  %  poly          - cell list of the vertex ids of each grain (index to V)
  %  V             - list of verticies (x,y coordinates)
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
    V                % vertices with x,y coordinates
    scanUnit         % unit of the vertice coordinates
    GOS              % intragranular average misorientation angle    
    x                % x coordinates of the vertices of the grains
    y                % y coordinates of the vertices of the grains
    triplePoints     % triple points
  end
  
  properties (Dependent = true, Access = protected)
    idV % active vertices    
  end
  
  methods

    function grains = grain2d(poly, phaseId, CSList, phaseMap, varargin)
      % constructor
      % 
      % Input
      %  V    - n x 2 list of vertices
      %  poly - cell array of the polyhedrons
      %  inclusionId - id within poly where the inclusions start, 0 - for no inclusion
      %  phaseId     - list of phaseId for each grain
      %  CSList      -
      %  phaseMap    - 
      
      if nargin == 0, return;end

      grains.poly = poly;
      grains.inclusionId = cellfun(@(p) length(p) - find(p(2:end)==p(1),1),poly,'uniformOutput',true)-1;


      grains.phaseId = phaseId;
      grains.CSList = CSList;
      grains.phaseMap = phaseMap;

      grains.id = (1:numel(grains.phaseId)).';
      grains.grainSize = ones(size(poly));
      
      %grains.boundary = boundary;
      %grains.innerBoudary = innerBoundary;

    end
        
    function V = get.V(grains)
      V = grains.boundary.V;
    end
    
    function x = get.x(grains)
      x = grains.boundary.x;
    end
    
    function y = get.y(grains)
      y = grains.boundary.y;
    end
    
    function grains = set.V(grains,V)
      
      grains.boundary.V = V;
      grains.innerBoundary.V = V;
      
    end
    
    function idV = get.idV(grains)
      
      isCell = cellfun('isclass',grains.poly,'cell');
      polygons = grains.poly;
      polygons(isCell) = cellfun(@(x) [x{:}] ,grains.poly(isCell),'UniformOutput',false);
      idV = unique([polygons{:}]);
      
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
  
end

