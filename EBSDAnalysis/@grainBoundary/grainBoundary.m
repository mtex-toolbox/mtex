classdef grainBoundary < phaseList & dynProp
%
% Variables of type grainBoundary represent lists of grain boundary
% segments. Those are typically generated during grain reconstruction and
% are accessible via
%
%   grains.boundary
%
% Each grain boundary segment stores many properties: its position within
% the map, the ids of the adjacent grains, the ids of the adjacent EBSD
% measurements, the grain boundary misorientation, etc. These properties
% are explained in more detail in the section <BoundaryProperties.html
% boundary properties>.
%
% Class Properties
%  V            - [x,y] list of vertices 
%  scanUnit     - scanning unit (default - um)
%  triplePoints - @triplePointList
%  F            - list of boundary segments as ids to V
%  grainId      - id's of the neighboring grains to a boundary segment
%  ebsdId       - id's of the neighboring ebsd data to a boundary segment
%  misrotation  - misrotation between neighboring ebsd data to a boundary segment
%
% Dependent Class Properties
%  misorientation - disorientation between neighboring ebsd data to a boundary segment
%  direction      - direction of the boundary segment as @vector3d
%  midPoint       - x,y coordinates of the midpoint of the segments
%  I_VF           - incidence matrix vertices - edges
%  I_FG           - incidence matrix edges - grains
%  A_F            - adjacency matrix edges - edges
%  A_V            - adjacency matrix vertices - vertices
%  componentId    - connected component id
%  componentSize  - number of segments that belong to the component
%  x              - x coordinates of the vertices of the grains
%  y              - y coordinates of the vertices of the grains    
%  z              - z coordinates of the vertices of the grains    
%

  
  % properties with as many rows as data
  properties
    F = zeros(0,2)       % list of faces - indices to V    
    grainId = zeros(0,2) % id's of the neighboring grains to a face
    ebsdId = zeros(0,2)  % id's of the neighboring ebsd data to a face
    misrotation = rotation % misrotations
  end
  
  % general properties
  properties
    scanUnit = 'um' % unit of the vertex coordinates
    triplePoints = triplePointList  % triple points
  end
  
  properties (Dependent = true)
    misorientation % misorientation between adjacent measurements to a boundary
    direction      % direction of the boundary segment
    midPoint       % x,y coordinates of the midpoint of the segment
    I_VF           % incidence matrix vertices - edges
    I_FG           % incidence matrix edges - grains
    A_F            % adjacency matrix edges - edges
    A_V            % adjacency matrix vertices - vertices
    componentId    % connected component id
    componentSize  % number of faces that form a segment
    x              % x coordinates of the vertices of the grains
    y              % y coordinates of the vertices of the grains
    z              % z coordinates of the vertices of the grains
    allV           % list of all vertices
    V              % vertices that are part of the grain boundary
    N              % normal direction of the pseudo3d data    
    plottingConvention % default plotting convention
  end
  
  methods
    function gB = grainBoundary(V,F,ebsdInd,grainId,phaseId,mori,CSList,phaseMap,ebsdId,varargin)
      %
      % Input
      %  V       - [x,y] list of vertices
      %  F       - [v1,v2] list of boundary segments
      %  ebsdInd - [Id1,Id2] list of adjacent EBSD pixels for each segment
      %  mori    - misorientation between adjacent EBSD pixels for each segment
      %  grainId - ebsd.grainId
      %  phaseId - ebsd.phaseId
      %  CSList   - 
      %  phaseMap - 
      
      if nargin == 0, return; end

      % ensure V is vector3d
      if ~isa(V,'vector3d'), V = vector3d.byXYZ(V); end
      
      % assign properties
      gB.triplePoints = struct('allV',V,'N',zvector);
      gB.F = F;
      gB.misrotation = mori;
      gB.CSList = CSList;
      gB.phaseMap = phaseMap;
      gB.misrotation = mori;
      gB.ebsdId = ebsdInd;
      if nargin == 9 % store ebsd_id instead of index
        gB.ebsdId(ebsdInd>0) = ebsdId(ebsdInd(ebsdInd>0));
      end

      % compute boundary grainId and phaseId
      gB.grainId = zeros(size(F,1),2);
      gB.grainId(ebsdInd>0) = grainId(ebsdInd(ebsdInd>0));
      
      gB.phaseId = zeros(size(F,1),2);
      gB.phaseId(ebsdInd>0) = phaseId(ebsdInd(ebsdInd>0));

      % sort columns such that first phaseId1 <= phaseId2
      doSort = gB.phaseId(:,1) > gB.phaseId(:,2) | ...
        (gB.phaseId(:,1) == gB.phaseId(:,2) & gB.grainId(:,1) > gB.grainId(:,2));
      if any(doSort)
        gB.phaseId(doSort,:) = fliplr(gB.phaseId(doSort,:));
        gB.ebsdId(doSort,:) = fliplr(gB.ebsdId(doSort,:));
        gB.grainId(doSort,:) = fliplr(gB.grainId(doSort,:));
        gB.misrotation(doSort) = inv(gB.misrotation(doSort));
      end

      % compute triple points
      if ~check_option(varargin,'noTriplePoints')
        gB.triplePoints = gB.calcTriplePoints;
      end
    end

    function gB = cat(dim,varargin)
      
      gB = cat@dynProp(dim,varargin{:});

      for k = 2:numel(varargin)

        ngB = varargin{k};
        
        gB.F = [gB.F;ngB.F];
        gB.grainId = [gB.grainId; ngB.grainId];
        gB.ebsdId = [gB.ebsdId; ngB.ebsdId];
        gB.misrotation = [gB.misrotation;ngB.misrotation];
        gB.phaseId = [gB.phaseId; ngB.phaseId];        
  
      end
      
      % remove duplicates
      [~,ind] = unique(gB.F,'rows');      
      gB = gB.subSet(ind);
      
    end
    
    
    function mori = get.misorientation(gB)
            
      mori = orientation(gB.misrotation,gB.CS{:});
      mori.antipodal = equal(checkSinglePhase(gB),2);
      
      % set not indexed orientations to nan
      if ~all(gB.isIndexed), mori(~gB.isIndexed) = NaN; end
      
    end
    
    function dir = get.direction(gB)      
      
      dir = normalize(gB.allV(gB.F(:,1)) - gB.allV(gB.F(:,2)));
      dir.antipodal = true;
      
    end
    
    function pC = get.plottingConvention(gB)
      pC = gB.allV.plottingConvention;
    end

    function gB = set.plottingConvention(gB,pC)
      gB.allV.plottingConvention = pC;
    end

    function V = get.allV(gB)
      V = gB.triplePoints.allV;
    end
    
    function gB = set.allV(gB,V)
      gB.triplePoints.allV = V;
    end
    
    function V = get.V(gB)
      error('implement this!')
      %V = reshape(gB.triplePoints.allV(gB.F),length(gB),2);
    end
    
    function N = get.N(gB)
      N = gB.triplePoints.N;
    end
    
    function gB = set.N(gB,N)
      gB.triplePoints.N = N;
    end

    function x = get.x(gB)
      x = gB.allV.x(unique(gB.F(:)));
    end
    
    function y = get.y(gB)
      y = gB.allV.y(unique(gB.F(:)));
    end

    function y = get.z(gB)
      y = gB.allV.z(unique(gB.F(:)));
    end
    
    function m = get.midPoint(gB)      
      m = mean(gB.allV(gB.F),2);
    end
    
    function I_VF = get.I_VF(gB)
      [i,~,f] = find(gB.F);
      I_VF = sparse(f,i,true,size(gB.allV,1),size(gB.F,1));
    end

    function I_FG = get.I_FG(gB)
      ind = gB.grainId>0;
      iF = repmat(1:size(gB.F,1),1,2);
      I_FG = logical(sparse(iF(ind),gB.grainId(ind),1));
    end   
    
    function A_F = get.A_F(gB)
      I_VF = gB.I_VF; %#ok<PROP>
      A_F = I_VF.' * I_VF; %#ok<PROP>
      n = length(A_F);
      A_F(sub2ind(size(A_F),1:n,1:n)) = 0;
    end
    
    function A_V = get.A_V(gB)
      A_V = sparse(gB.F(:,1),gB.F(:,2),1:size(gB.F,1),size(gB.allV,1),size(gB.allV,1)) ...
        + sparse(gB.F(:,2),gB.F(:,1),1:size(gB.F,1),size(gB.allV,1),size(gB.allV,1));
    end
    
    %function tp = get.triplePoints(gB)
       
    %end
    
    function componentId = get.componentId(gB)
      componentId = connectedComponents(gB.A_F).';
    end
    
    function componentSize = get.componentSize(gB)
      segId = gB.componentId;
      
      [~,~,ind] = unique(segId);
      counts = accumarray(ind,1);
      componentSize = counts(ind);
      
    end
    
    function out = hasPhase(gB,phase1,phase2)
      
      if nargin == 2
        out = gB.hasPhaseId(gB.name2id(phase1));
      else
        out = hasPhaseId(gB,gB.name2id(phase1),gB.name2id(phase2));
      end

    end
    
    function out = hasPhaseId(gB,phaseId,phaseId2)
      
      if isempty(phaseId), out = false(size(gB)); return; end
      
      if nargin == 2
        out = any(gB.phaseId == phaseId,2);
      
        % not indexed phase should include outer border as well
        if phaseId > 0 && ischar(gB.CSList{phaseId}), out = out | any(gB.phaseId == 0,2); end
               
      elseif isempty(phaseId2)
        
        out = false(size(gB));
        
      elseif phaseId == phaseId2
        
        out = all(gB.phaseId == phaseId,2);
        
      else
        
        out = gB.hasPhaseId(phaseId) & gB.hasPhaseId(phaseId2);
        
      end
      
    end

    function out = hasGrain(gB,grainId,grainId2)
      
      if isa(grainId,'grain2d'), grainId = grainId.id;end
      
      if nargin == 2
        
        out = any(ismember(gB.grainId,grainId),2);
        
      else
        
        out = gB.hasGrain(grainId) & gB.hasGrain(grainId2);
        
      end
      
    end
    
    function gB = update(gB,grains)
      
      gB.phaseId = zeros(size(gB.F,1),2);
      isBoundary = gB.grainId > 0;
      gB.phaseId(isBoundary) = grains.phaseId(grains.id2ind(gB.grainId(isBoundary)));      
      
    end
  end

  methods (Static = true)
      function gB = loadobj(gB)
      % called by MATLAB when an object is loaded from an .mat file
      % this overloaded method ensures compatibility with older MTEX
      % versions
      
      % maybe there is nothing to do
      %if isa(s,'grainBoundary'), gB = s; return; end
      
      if isfield(gB.prop,'V')
        gB.triplePoints.allV = gB.prop.V;
        gB.prop = rmfield(gB.prop,'V');
      end
      
    end
    
    
  end
  
end
