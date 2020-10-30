classdef grainBoundary < phaseList & dynProp
%
% Variables of type grainBoundary represent lists of grain boundary
% segments. Those are typically generated during grain reconstruction and
% are accessible via
%
%   grains.boundary
%
% Each grain boundary segement stores many properties: its position within
% the map, the ids of the adjacent grains, the ids of the adjacent EBSD
% measurements, the grain boundary misorientation, etc. These properties
% are explained in more detail in the section <BoundaryProperties.html
% boundary properties>.
%
% Class Properties
%  V            - [x,y] list of vertices 
%  scanUnit     - scaning unit (default - um)
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
%  A_F            - adjecency matrix edges - edges
%  A_V            - adjecency matrix vertices - vertices
%  componentId    - connected component id
%  componentSize  - number of segments that belong to the component
%  x              - x coordinates of the vertices of the grains
%  y              - y coordinates of the vertices of the grains    
%

  
  % properties with as many rows as data
  properties
    F = zeros(0,2)       % list of faces - indeces to V    
    grainId = zeros(0,2) % id's of the neigbouring grains to a face
    ebsdId = zeros(0,2)  % id's of the neigbouring ebsd data to a face
    misrotation = rotation % misrotations
  end
  
  % general properties
  properties
    scanUnit = 'um' % unit of the vertice coordinates
    triplePoints    % triple points
  end
  
  properties (Dependent = true)
    misorientation % misorientation between adjecent measurements to a boundary
    direction      % direction of the boundary segment
    midPoint       % x,y coordinates of the midpoint of the segment
    I_VF           % incidence matrix vertices - edges
    I_FG           % incidence matrix edges - grains
    A_F            % adjecency matrix edges - edges
    A_V            % adjecency matrix vertices - vertices
    componentId    % connected component id
    componentSize  % number of faces that form a segment
    x              % x coordinates of the vertices of the grains
    y              % y coordinates of the vertices of the grains
    V              % vertices x,y coordinates
  end
  
  methods
    function gB = grainBoundary(V,F,I_FD,ebsd,grainsPhaseId)
      %
      % Input
      %  V - [x,y] list of vertices
      %  F - [v1,v2] list of boundary segments
      %  I_FD - incidence matrix boundary segments vs. cells
      %  ebsd -
      %  grainPhaseId - 
      %
      %
      
      if nargin == 0, return; end
      
      % remove empty lines from I_FD and F
      isBoundary = any(I_FD,2);
      gB.F = F(full(isBoundary),:);
                        
      % compute ebsdID
      [eId,fId] = find(I_FD.');
      
      % scale fid down to 1:length(gB)
      d = diff([0;fId]);      
      fId = cumsum(d>0) + (d==0)*size(gB.F,1);
            
      % set the ebsdId temporary to the index - this will be replaced by
      % the id down in the code
      gB.ebsdId = zeros(size(gB.F,1),2);
      gB.ebsdId(fId) = eId;
            
      % compute grainId
      gB.grainId = zeros(size(gB.F,1),2);
      gB.grainId(fId) = ebsd.grainId(eId);
      
      % compute phaseId
      gB.phaseId = zeros(size(gB.F,1),2);
      isNotBoundary = gB.ebsdId>0;
      gB.phaseId(isNotBoundary) = ebsd.phaseId(gB.ebsdId(isNotBoundary));
      gB.phaseMap = ebsd.phaseMap;
      gB.CSList = ebsd.CSList;
      
      % sort ebsdId such that first phaseId1 <= phaseId2
      doSort = gB.phaseId(:,1) > gB.phaseId(:,2) | ...
        (gB.phaseId(:,1) == gB.phaseId(:,2) & gB.grainId(:,1) > gB.grainId(:,2));
      gB.phaseId(doSort,:) = fliplr(gB.phaseId(doSort,:));
      gB.ebsdId(doSort,:) = fliplr(gB.ebsdId(doSort,:));
      gB.grainId(doSort,:) = fliplr(gB.grainId(doSort,:));
      
      % compute misrotations
      gB.misrotation = rotation.id(size(gB.F,1),1);
      isNotBoundary = all(gB.ebsdId,2);
      gB.misrotation(isNotBoundary) = ...
        inv(ebsd.rotations(gB.ebsdId(isNotBoundary,2))) ...
        .* ebsd.rotations(gB.ebsdId(isNotBoundary,1));

      % compute triple points
      gB.triplePoints = gB.calcTriplePoints(V,grainsPhaseId);
      
      % store ebsd_id instead of index
      gB.ebsdId(gB.ebsdId>0) = ebsd.id(gB.ebsdId(gB.ebsdId>0));
      
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
      v1 = vector3d(gB.V(gB.F(:,1),1),gB.V(gB.F(:,1),2),zeros(length(gB),1),'antipodal');
      v2 = vector3d(gB.V(gB.F(:,2),1),gB.V(gB.F(:,2),2),zeros(length(gB),1));
      dir = normalize(v1-v2);
    end
    
    
    function V = get.V(gB)
      V = gB.triplePoints.allV;
    end
    
    function gB = set.V(gB,V)
      if isa(gB.triplePoints,'triplePointList')
        gB.triplePoints.allV = V;
      else
        gB.prop.V = V;
      end
    end
    
    function x = get.x(gB)
      x = gB.V(unique(gB.F(:)),1);
    end
    
    function y = get.y(gB)
      y = gB.V(unique(gB.F(:)),2);
    end
    
    function xy = get.midPoint(gB)
      xyA = gB.V(gB.F(:,1),:);
      xyB = gB.V(gB.F(:,2),:);
      xy = 0.5 * (xyA + xyB);
    end
    
    function I_VF = get.I_VF(gB)
      [i,~,f] = find(gB.F);
      I_VF = sparse(f,i,1,size(gB.V,1),size(gB.F,1));
    end

    function I_FG = get.I_FG(gB)
      ind = gB.grainId>0;
      iF = repmat(1:size(gB.F,1),1,2);
      I_FG = sparse(iF(ind),gB.grainId(ind),1);
    end   
    
    function A_F = get.A_F(gB)
      I_VF = gB.I_VF; %#ok<PROP>
      A_F = I_VF.' * I_VF; %#ok<PROP>
      n = length(A_F);
      A_F(sub2ind(size(A_F),1:n,1:n)) = 0;
    end
    
    function A_V = get.A_V(gB)
      A_V = sparse(gB.F(:,1),gB.F(:,2),1:size(gB.F,1),size(gB.V,1),size(gB.V,1)) ...
        + sparse(gB.F(:,2),gB.F(:,1),1:size(gB.F,1),size(gB.V,1),size(gB.V,1));
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
      % called by Matlab when an object is loaded from an .mat file
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
